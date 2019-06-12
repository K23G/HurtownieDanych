CREATE PROCEDURE PRC.DelayTypeToMainRepo
AS
BEGIN
	INSERT INTO MainRepo.DimDelayType
	select CASE when ISNUMERIC(WEATHER_DELAY) <> 1 then 0 else WEATHER_DELAY END AS WeatherDelay,
	CASE when ISNUMERIC(WEATHER_DELAY) <> 1 then CAST(1 AS bit) else CAST(0 AS bit) END AS ReplacedWeatherDelay,
	CASE 
		when ISNUMERIC(WEATHER_DELAY) <> 1 then CAST(0 AS bit)
		when WEATHER_DELAY > 0 then CAST(1 AS bit) 
		else CAST(0 AS bit) 
	END AS IsWeatherDelay,
	CASE when ISNUMERIC(AIRLINE_DELAY) <> 1 then 0 else AIRLINE_DELAY END AS AirlineDelay,
	CASE when ISNUMERIC(AIRLINE_DELAY) <> 1 then CAST(1 AS bit) else CAST(0 AS bit) END AS ReplacedAirlineDelay,
		CASE 
		when ISNUMERIC(AIRLINE_DELAY) <> 1 then CAST(0 AS bit)
		when AIRLINE_DELAY > 0 then CAST(1 AS bit) 
		else CAST(0 AS bit) 
	END AS IsAirlineDelay,
	CASE when ISNUMERIC(AIR_SYSTEM_DELAY) <> 1 then 0 else AIR_SYSTEM_DELAY END AS AirSystemDelay,
	CASE when ISNUMERIC(AIR_SYSTEM_DELAY) <> 1 then CAST(1 AS bit) else CAST(0 AS bit) END AS ReplacedAirSystemDelay,
		CASE 
		when ISNUMERIC(AIR_SYSTEM_DELAY) <> 1 then CAST(0 AS bit)
		when AIR_SYSTEM_DELAY > 0 then CAST(1 AS bit) 
		else CAST(0 AS bit) 
	END AS IsAirSystemDelay,
	CASE when ISNUMERIC(SECURITY_DELAY) <> 1 then 0 else SECURITY_DELAY END AS SecurityDelay,
	CASE when ISNUMERIC(SECURITY_DELAY) <> 1 then CAST(1 AS bit) else CAST(0 AS bit) END AS ReplacedSecurityDelay,
		CASE 
		when ISNUMERIC(SECURITY_DELAY) <> 1 then CAST(0 AS bit)
		when SECURITY_DELAY > 0 then CAST(1 AS bit) 
		else CAST(0 AS bit) 
	END AS IsSecurityDelay,
	CASE when ISNUMERIC(LATE_AIRCRAFT_DELAY) <> 1 then 0 else LATE_AIRCRAFT_DELAY END AS LateAircraftDelay,
	CASE when ISNUMERIC(LATE_AIRCRAFT_DELAY) <> 1 then CAST(1 AS bit) else CAST(0 AS bit) END AS ReplacedLateAircraftDelay,
	CASE 
		when ISNUMERIC(LATE_AIRCRAFT_DELAY) <> 1 then CAST(0 AS bit)
		when LATE_AIRCRAFT_DELAY > 0 then CAST(1 AS bit) 
		else CAST(0 AS bit) 
	END AS IsLateAircraftDelay
	from stage.Flights
	EXCEPT
	select WeatherDelay, ReplacedWeatherDelay, IsWeatherDelay, AirlineDelay, ReplacedAirlineDelay, IsAirlineDelay,
	AirSystemDelay, ReplacedAirSystemDelay, IsAirSystemDelay, SecurityDelay, ReplacedSecurityDelay, IsSecurityDelay, LateAircraftDelay,
	ReplacedLateAircraftDelay, IsLateAircraftDelay
	from MainRepo.DimDelayType
END;