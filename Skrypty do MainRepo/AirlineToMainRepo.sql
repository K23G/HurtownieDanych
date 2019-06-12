CREATE SCHEMA PRC;
CREATE PROCEDURE PRC.AirlineToMainRepo
AS
BEGIN
	SET ANSI_WARNINGS OFF;
	IF (SELECT COUNT(*) FROM MainRepo.DimAirline where ID_Airline = -1) = 0
	BEGIN
		SET IDENTITY_INSERT MainRepo.DimAirline ON
			INSERT INTO MainRepo.DimAirline (ID_Airline, IATACode, Name, ShortName, Callsign, Country, Active, ReplacedActive, [Unique])
			VALUES (-1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', CAST(0 as bit), CAST(1 as bit), CAST(1 as bit))
		SET IDENTITY_INSERT MainRepo.DimAirline OFF
	END

	INSERT INTO MainRepo.DimAirline
	SELECT DISTINCT IataCodes.IATACode AS IATACode,
	airlinesAtributes.Name, airlinesAtributes.ShortName, airlinesAtributes.Callsign, 
	airlinesAtributes.Country, airlinesAtributes.Active, airlinesAtributes.ReplacedActive, airlinesAtributes."Unique"
	FROM
	(
		SELECT AIRLINE AS IATACode from Stage.Flights
		UNION
		SELECT IATA AS IATACode from Stage.Airlines
	)
	AS IataCodes LEFT JOIN
	(
		SELECT IATACode,
		STRING_AGG(Name, '/') WITHIN GROUP (ORDER BY Name DESC) AS Name,
		STRING_AGG(ShortName, '/') WITHIN GROUP (ORDER BY Name DESC) AS ShortName,
		STRING_AGG(Callsign, '/') WITHIN GROUP (ORDER BY Name DESC) AS Callsign,
		STRING_AGG(Country, '/') WITHIN GROUP (ORDER BY Name DESC) AS Country,
		CAST (
			CASE 
				when count(*) > 1 then 0 
				else STRING_AGG(Active, '')
			END
		as bit) as Active,
		CAST (
			CASE 
				when count(*) > 1 then 1 
				else 0
			END
		as bit) as ReplacedActive,
		CAST (
			CASE 
				when count(*) > 1 then 0 
				else 1
			END
		as bit) as "Unique"
		FROM
			(
				select 
				IATA AS IATACode,
				CASE 
					when Name = '\N' then 'Unknown'
					when Name is null then 'Unknown'
					else Name
				END AS Name,
				CASE 
					when Alias = '\N' then 'Unknown'
					when Alias is null then 'Unknown'
					else Alias
				END AS ShortName,
				CASE 
					when Callsign = '\N' then 'Unknown'
					when Callsign is null then 'Unknown'
					else Callsign
				END AS Callsign,
				CASE 
					when Country = '\N' then 'Unknown'
					when Country is null then 'Unknown'
					else Country
				END AS Country,
				CASE 
					when Active = 'Y' then CAST(1 AS bit)
					when Active = 'N' then CAST(0 AS bit)
					else CAST(0 AS bit)
				END AS Active,
				CASE 
					when Active != 'Y' and Active != 'N' then CAST(1 AS bit)
					else CAST(0 AS bit)
				END AS ReplacedActive
				from stage.airlines
			) AS innerAirlinesAtributes
		where IATACode is not null
		group by IATACode
	) AS airlinesAtributes on airlinesAtributes.IATACode = IataCodes.IATACode
	where IataCodes.IATACode like '[a-zA-Z0-9][a-zA-Z0-9]'
	EXCEPT
	select 
	IATACode,
	Name, ShortName, Callsign, 
	Country, Active, ReplacedActive, "Unique"
	FROM MainRepo.DimAirline
	SET ANSI_WARNINGS ON;
END;