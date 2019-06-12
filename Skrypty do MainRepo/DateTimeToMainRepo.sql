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
	
	
	DECLARE @MaxRowNum int
	Set @MaxRowNum = (SELECT MAX(ID_DateTime) FROM MainRepo.DimDateTime)

	DECLARE @Iter int
	SET @Iter = 1

	DECLARE @Year int
	DECLARE @Month int
	DECLARE @Day int
	DECLARE @Hour int
	DECLARE @Minutes int

	WHILE @Iter <= @MaxRowNum
	BEGIN 
		SELECT @Year = ddt.Year, @Month = ddt.Month, @Day = ddt.DayOfMonth, @Hour = ddt.MilitaryHour, @Minutes = ddt.TheMinute
		FROM MainRepo.DimDateTime ddt
		WHERE ID_DateTime = @Iter

		DECLARE @Date Date
		DECLARE @Quarter int, @DateKey int
		DECLARE @FullDate char(10)
		DECLARE @DayName varchar(20)
		DECLARE @DayOfYear varchar(3)
		DECLARE @MonthName varchar(20)
		DECLARE @MonthOfQuarter varchar(2), @QuarterName varchar(9)
		DECLARE @IsWeekday bit

		SELECT @Date = CONVERT(DATE,CAST(@Year AS VARCHAR(4))+ '-' + CAST(@Month AS VARCHAR(2)) + '-' + CAST(@Day AS VARCHAR(2)))
		SELECT @DateKey = CONVERT(char(8), @Date, 112)
		SELECT @FullDate = CONVERT (char(10), @Date, 104)
		SELECT @DayName = CASE DATEPART(DW, @Date) WHEN 1 THEN 'Niedziela' WHEN 2 THEN 'Poniedziałek' WHEN 3 THEN 'Wtorek'
				WHEN 4 THEN 'Środa' WHEN 5 THEN 'Czwartek' WHEN 6 THEN 'Piątek' WHEN 7 THEN 'Sobota' END
		SELECT @DayOfYear = DATEPART(DY, @Date)
		SELECT @MonthName = CASE DATEPART(MM, @Date) WHEN 1 THEN 'Styczeń' WHEN 2 THEN 'Luty' WHEN 3 THEN 'Marzec' WHEN 4 THEN 'Kwiecień'
				WHEN 5 THEN 'Maj' WHEN 6 THEN 'Czerwiec' WHEN 7 THEN 'Lipiec' WHEN 8 THEN 'Sierpień' WHEN 9 THEN 'Wrzesień'
				WHEN 10 THEN 'Październik' WHEN 11 THEN 'Listopad' WHEN 12 THEN 'Grudzień' END
		SELECT @MonthOfQuarter = CASE
				WHEN DATEPART(MM, @Date) IN (1, 4, 7, 10) THEN 1
				WHEN DATEPART(MM, @Date) IN (2, 5, 8, 11) THEN 2
				WHEN DATEPART(MM, @Date) IN (3, 6, 9, 12) THEN 3
				END
		SELECT @Quarter = DATEPART(QQ, @Date)
		SELECT @QuarterName = CASE DATEPART(QQ, @Date) WHEN 1 THEN 'Pierwszy' WHEN 2 THEN 'Drugi' WHEN 3 THEN 'Trzeci' WHEN 4 THEN 'Czwarty' END
		SELECT @IsWeekday = CASE DATEPART(DW, @Date) WHEN 1 THEN 0 WHEN 2 THEN 1 WHEN 3 THEN 1
				WHEN 4 THEN 1 WHEN 5 THEN 1 WHEN 6 THEN 1 WHEN 7 THEN 0 END

		UPDATE MainRepo.DimDateTime 
		SET DateKey = @DateKey,
			FullDate = @FullDate,
			DayName = @DayName,
			DayOfYear = @DayOfYear,
			MonthName = @MonthName,
			MonthOfQuarter = @MonthOfQuarter,
			Quarter = @Quarter,
			QuarterName = @QuarterName,
			IsWeekday = @IsWeekday,
		WHERE ID_DateTime = @Iter
		SET @Iter = @Iter + 1
	END;
END