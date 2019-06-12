CREATE PROCEDURE PRC.DateTimeToMainRepo
AS
BEGIN
	IF NOT EXISTS (select * from MainRepo.DimDateTime where ID_DateTime = -1)
	BEGIN
		SET IDENTITY_INSERT MainRepo.DimDateTime ON
		INSERT INTO MainRepo.DimDateTime 
		(ID_DateTime, DayOfMonth, Month, Year, MilitaryHour, TheMinute)
		VALUES (-1, 0, 0, 0, 0, 0)
		SET IDENTITY_INSERT MainRepo.DimDateTime OFF
	END
	
	INSERT INTO MainRepo.DimDateTime (Year, Month, DayOfMonth, MilitaryHour, TheMinute)
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when SCHEDULED_DEPARTURE is null then 0 
		when cast(LEFT(SCHEDULED_DEPARTURE, 2) AS int) = 24 then 0 
		else cast(LEFT(SCHEDULED_DEPARTURE, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when SCHEDULED_DEPARTURE is null then 0 
		else CAST(RIGHT(SCHEDULED_DEPARTURE, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 
	UNION
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when DEPARTURE_TIME is null then 0 
		when cast(LEFT(DEPARTURE_TIME, 2) AS int) = 24 then 0 
		else cast(LEFT(DEPARTURE_TIME, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when DEPARTURE_TIME is null then 0 
		else CAST(RIGHT(DEPARTURE_TIME, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 
	UNION
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when SCHEDULED_ARRIVAL is null then 0 
		when cast(LEFT(SCHEDULED_ARRIVAL, 2) AS int) = 24 then 0 
		else cast(LEFT(SCHEDULED_ARRIVAL, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when SCHEDULED_ARRIVAL is null then 0 
		else CAST(RIGHT(SCHEDULED_ARRIVAL, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 
	UNION
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when ARRIVAL_TIME is null then 0 
		when cast(LEFT(ARRIVAL_TIME, 2) AS int) = 24 then 0 
		else cast(LEFT(ARRIVAL_TIME, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when ARRIVAL_TIME is null then 0 
		else CAST(RIGHT(ARRIVAL_TIME, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 
	UNION
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when WHEELS_OFF is null then 0 
		when cast(LEFT(WHEELS_OFF, 2) AS int) = 24 then 0 
		else cast(LEFT(WHEELS_OFF, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when WHEELS_OFF is null then 0 
		else CAST(RIGHT(WHEELS_OFF, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 
	UNION
	SELECT
	CASE when YEAR is null then 0 else YEAR END AS Year,
	CASE when MONTH is null then 0 else MONTH END AS Month,
	CASE when DAY is null then 0 else DAY END AS DayOfMonth,
	CASE
		when WHEELS_ON is null then 0 
		when cast(LEFT(WHEELS_ON, 2) AS int) = 24 then 0 
		else cast(LEFT(WHEELS_ON, 2) AS int) 
	END AS MilitaryHour,
	CASE
		when WHEELS_ON is null then 0 
		else CAST(RIGHT(WHEELS_ON, 2) AS int) 
	END AS TheMinute
	FROM stage.Flights 

	EXCEPT
	SELECT Year, Month, DayOfMonth, MilitaryHour, TheMinute
	FROM MainRepo.DimDateTime
END