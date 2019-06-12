CREATE PROCEDURE PRC.AirportToMainRepo
AS
BEGIN
	IF (SELECT COUNT(*) FROM MainRepo.DimAirport where ID_Airport = -1) = 0
	BEGIN
		SET IDENTITY_INSERT MainRepo.DimAirport ON
		INSERT INTO MainRepo.DimAirport (	
				ID_Airport,
				IATACode,
				Name,
				City,
				State,
				StateShort,
				Country,
				Latitude,
				ReplacedLatitude,
				Longitude,
				ReplacedLongitude,
				Altitude,
				ReplacedAltitude,
				Timezone,
				ReplacedTimezone,
				DST
			) VALUES 
			(
				-1,
				'Unknown', 
				'Unknown', 
				'Unknown', 
				'Unknown', 
				'Unknown', 
				'Unknown', 
				0.0,
				cast(1 as bit),
				0.0,
				cast(1 as bit),
				0.0,
				cast(1 as bit),
				0.0,
				cast(1 as bit),
				'Unknown'
			)
		SET IDENTITY_INSERT MainRepo.DimAirport OFF
	END
	
	INSERT INTO MainRepo.DimAirport
	select distinct IataCodes.IATA AS IATACode, 
	CASE 
		when airportOthersSet2.Name = '\N' then 'Unknown' 
		when airportOthersSet2.Name is null then 'Unknown'
		else airportOthersSet2.Name 
	END AS Name,
	CASE 
		when IATACitySet.City = '\N' then 'Unknown' 
		when IATACitySet.City is null then 'Unknown' 
		else IATACitySet.City 
	END AS City,
	--CASE 
	--	when statesSet.State = '\N' then 'Unknown' 
	--	when statesSet.State is null then 'Unknown' 
	---	else statesSet.State 
	--END AS State
	'Unknown' as State,
	CASE 
		when StateShortSet.StateShort = '\N' then 'Unknown'
		when StateShortSet.StateShort is null then 'Unknown'
		else StateShortSet.StateShort
	END AS StateShort,
	CASE 
		when airportOthersSet2.Country = '\N' then 'Unknown' 
		when airportOthersSet2.Country is null then 'Unknown' 
		else airportOthersSet2.Country 
	END AS Country,
	CASE 
		when airportOthersSet2.Latitude is null then cast(0.0 AS decimal(10,4))
		when airportOthersSet2.Latitude like '%/%' then cast(0.0 AS decimal(10,4))
		else cast(airportOthersSet2.Latitude AS decimal(10,4))
	END AS Latitude,
	CASE 
		when airportOthersSet2.Latitude is null then cast(1 as bit)
		when airportOthersSet2.Latitude like '%/%' then cast(1 as bit)
		else cast(0 as bit)
	END AS ReplacedLatitude,
	CASE 
		when airportOthersSet2.Longitude is null then cast(0.0 AS decimal(10,4))
		when airportOthersSet2.Longitude like '%/%' then cast(0.0 AS decimal(10,4))
		else cast(airportOthersSet2.Longitude AS decimal(10,4))
	END AS Longitude,
	CASE 
		when airportOthersSet2.Longitude is null then cast(1 as bit)
		when airportOthersSet2.Longitude like '%/%' then cast(1 as bit)
		else cast(0 as bit)
	END AS ReplacedLongitude,
	CASE 
		when airportOthersSet.Altitude is null then 0 
		else airportOthersSet.Altitude 
	END AS Altitude,
	CASE 
		when airportOthersSet.Altitude is null then cast(1 as bit)
		else cast(0 as bit)
	END AS ReplacedAltitude,
	CASE 
		when airportOthersSet.Timezone = '\N' then cast(0.0 AS decimal(10,4))
		when airportOthersSet.Timezone is null then cast(0.0 AS decimal(10,4))
		else cast(airportOthersSet.Timezone AS decimal(10,4)) 
	END AS Timezone,
	CASE 
		when airportOthersSet.Timezone is null then cast(1 as bit)
		else cast(0 as bit)
	END AS ReplacedTimezone,
	CASE 
		when airportOthersSet.DST = '\N' then 'Unknown' 
		when airportOthersSet.DST is null then 'Unknown' 
		else airportOthersSet.DST 
	END AS DST
	FROM
	(
		select IATA from stage.Airports
		union
		select ORIGIN_AIRPORT AS IATA from stage.Flights
		union
		select DESTINATION_AIRPORT AS IATA from stage.Flights
		union
		select IATA_CODE AS IATA from stage.DelayAirport
	) AS IataCodes left join
	(
		select innerIATACitySet.IATA AS IATA, string_agg(innerIATACitySet.City, '/') WITHIN GROUP (ORDER BY innerIATACitySet.City DESC) AS City
		from
		(
			select IATA, City from stage.Airports
			union
			select IATA_CODE AS IATA, CITY AS City from stage.DelayAirport
		) AS innerIATACitySet
		where innerIATACitySet.IATA like '[a-zA-Z][a-zA-Z][a-zA-Z]'
		group by innerIATACitySet.IATA
	) AS IATACitySet on IataCodes.IATA = IATACitySet.IATA left join
	(
		select InnerStateShortSet.IATA AS IATA, STRING_AGG(InnerStateShortSet.StateShort, '/') WITHIN GROUP (ORDER BY InnerStateShortSet.StateShort DESC) AS StateShort
		from
		(
			select IATA_CODE AS IATA, STATE AS StateShort from stage.DelayAirport
		) AS InnerStateShortSet
		where InnerStateShortSet.IATA like '[a-zA-Z][a-zA-Z][a-zA-Z]'
		group by InnerStateShortSet.IATA
	) AS StateShortSet on IataCodes.IATA = StateShortSet.IATA left join
	(
		select IATA, Altitude, Timezone, DST 
		from stage.Airports
		where IATA like '[a-zA-Z][a-zA-Z][a-zA-Z]'
	) AS airportOthersSet on airportOthersSet.IATA = IataCodes.IATA left join
	(
		select InnerAirportOthersSet2.IATA AS IATA, 
		STRING_AGG(InnerAirportOthersSet2.Name, '/') WITHIN GROUP (ORDER BY InnerAirportOthersSet2.Name DESC) AS Name, 
		STRING_AGG(InnerAirportOthersSet2.Country, '/') WITHIN GROUP (ORDER BY InnerAirportOthersSet2.Name DESC) AS Country,
		STRING_AGG(InnerAirportOthersSet2.Latitude, '/') WITHIN GROUP (ORDER BY InnerAirportOthersSet2.Name DESC) AS Latitude,
		STRING_AGG(InnerAirportOthersSet2.Longitude, '/') WITHIN GROUP (ORDER BY InnerAirportOthersSet2.Name DESC) AS Longitude
		from
		(
			select IATA, Name, Country, Latitude, Longitude 
			from stage.Airports
			union
			select IATA_CODE AS IATA, AIRPORT AS Name, COUNTRY AS Country, 
			LATITUDE AS Latitude, LONGITUDE AS Longitude 
			from stage.DelayAirport
		) AS InnerAirportOthersSet2
		where InnerAirportOthersSet2.IATA like '[a-zA-Z][a-zA-Z][a-zA-Z]'
		group by InnerAirportOthersSet2.IATA
	) AS airportOthersSet2 on airportOthersSet2.IATA = IataCodes.IATA
	where IataCodes.IATA like '[a-zA-Z][a-zA-Z][a-zA-Z]'
	EXCEPT
	select 
		IATACode,
		Name,
		City,
		State,
		StateShort,
		Country,
		Latitude,
		ReplacedLatitude,
		Longitude,
		ReplacedLongitude,
		Altitude,
		ReplacedAltitude,
		Timezone,
		ReplacedTimezone,
		DST
	from MainRepo.DimAirport
	order by IATACode
END;