CREATE PROCEDURE PRC.FlightFactToMainRepo
AS
BEGIN
	INSERT INTO MainRepo.FactFlight
	select
	CASE when TAXI_OUT is null then 0 else TAXI_OUT END AS TaxiOut, 
	CASE when TAXI_OUT is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedTaxiOut,
	CASE when TAXI_IN is null then 0 else TAXI_IN END AS TaxiIn, 
	CASE when TAXI_IN is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedTaxiIn,
	CASE when SCHEDULED_TIME is null then 0 else SCHEDULED_TIME END AS ScheduledFlightTime, 
	CASE when SCHEDULED_TIME is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedScheduledFlightTime,
	CASE when ELAPSED_TIME is null then 0 else ELAPSED_TIME END AS FlightTime,
	CASE when ELAPSED_TIME is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedFlightTime,
	CASE when AIR_TIME is null then 0 else AIR_TIME END AS AirTime, 
	CASE when AIR_TIME is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedAirTime,
	0 AS Flights, 
	cast(1 AS bit) AS ReplacedFlights,
	CASE when FLIGHT_NUMBER is null then 0 else FLIGHT_NUMBER END AS FlightNumber, 
	CASE when DEPARTURE_DELAY is null then 0 else DEPARTURE_DELAY END AS DepartureDelay,
	CASE when DEPARTURE_DELAY is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedDepartureDelay,
	CASE
		when DEPARTURE_DELAY is null then 0
		when DEPARTURE_DELAY < 0 then 0
		else DEPARTURE_DELAY
	END DepartureDelayMinutes,
	CASE when ARRIVAL_DELAY is null then 0 else ARRIVAL_DELAY END AS ArrivalDelay,
	CASE when ARRIVAL_DELAY is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedArrivalDelay,
	CASE
		when ARRIVAL_DELAY is null then 0
		when ARRIVAL_DELAY < 0 then 0
		else ARRIVAL_DELAY
	END ArrivalDelayMinutes,
	CASE
		when DEPARTURE_DELAY is null then cast(0 AS int)
		when DEPARTURE_DELAY > 0 then cast(1 AS int)
		else cast(0 AS int)
	END AS IsFlightDelayed,
	ID_FlightStatus, 
	Plane.ID_Plane, 
	DelayType.ID_DelayType, 
	ScheduledDepartureDateTimeSet.ID_DateTime AS ScheduledDepartureDateTime,
	ScheduledArrivalDateTimeSet.ID_DateTime AS ScheduledArrivalDateTime,
	DepartureDateTimeSet.ID_DateTime AS DepartureDateTime, 
	ArrivalDateTimeSet.ID_DateTime AS ArrivalDateTime,
	WheelsOnDateTimeSet.ID_DateTime AS WheelsOnDateTime,
	WheelsOffDateTimeSet.ID_DateTime AS WheelsOffDateTime,
	Airline.ID_Airline AS Airline,
	DestinationAirport.ID_Airport AS DestinationAirport,
	OriginAirport.ID_Airport AS OriginAirport,
	DistanceSet.ID_Distance AS Distance
	from stage.Flights AS Flights 
	left join MainRepo.DimFlightStatus AS flightStatus 
			on flightStatus.Canceled = 
				CASE when Flights.CANCELLED is null then CAST(0 AS bit) else Flights.CANCELLED END
			and flightStatus.ReplacedCancelled = 
				CASE when Flights.CANCELLED is null then CAST(1 AS bit) else CAST(0 AS bit) END
			and flightStatus.CancellationCode = 
				CASE 
					when Flights.CANCELLATION_REASON is null then 'Unknown' 
					else Flights.CANCELLATION_REASON END
			and flightStatus.Diverted = 
				CASE when Flights.DIVERTED is null then CAST(0 AS bit) else Flights.DIVERTED END
			and flightStatus.ReplacedDiverted = 
				CASE when Flights.DIVERTED is null then CAST(1 AS bit) else CAST(0 AS bit) END
			and flightStatus.DivertedLandings = CAST(0 AS bit)
			and flightStatus.ReplacedDivertedLandings = CAST(1 AS bit)
	left join MainRepo.DimPlane AS Plane on Plane.TailNumber = 
				CASE when Flights.TAIL_NUMBER is null then 'Unknown' else Flights.TAIL_NUMBER END
	left join MainRepo.DimDelayType AS DelayType 
			on  DelayType.WeatherDelay = 
				CASE 
					when Flights.WEATHER_DELAY is null then 0 
					else Flights.WEATHER_DELAY
				END
			and DelayType.ReplacedWeatherDelay = 
				CASE 
					when Flights.WEATHER_DELAY is null then cast(1 AS bit) 
					else cast(0 AS bit) 
				END
			and DelayType.AirlineDelay = 
				CASE 
					when Flights.AIRLINE_DELAY is null then 0 
					else Flights.AIRLINE_DELAY
				END
			and DelayType.ReplacedAirlineDelay = 
				CASE 
					when Flights.AIRLINE_DELAY is null then cast(1 AS bit) 
					else cast(0 AS bit) 
				END
			and DelayType.LateAircraftDelay = 
				CASE 
					when Flights.LATE_AIRCRAFT_DELAY is null then 0 
					else Flights.LATE_AIRCRAFT_DELAY
				END
			and DelayType.ReplacedLateAircraftDelay = 
				CASE 
					when Flights.LATE_AIRCRAFT_DELAY is null then cast(1 AS bit) 
					else cast(0 AS bit) 
				END
			and DelayType.AirSystemDelay = 
				CASE 
					when Flights.AIR_SYSTEM_DELAY is null then 0 
					else Flights.AIR_SYSTEM_DELAY 
				END
			and DelayType.ReplacedAirSystemDelay = 
				CASE 
					when Flights.AIR_SYSTEM_DELAY is null then cast(1 AS bit) 
					else cast(0 AS bit) 
				END
			and DelayType.SecurityDelay = 
				CASE 
					when Flights.SECURITY_DELAY is null then 0 
					else Flights.SECURITY_DELAY 
				END
			and DelayType.ReplacedSecurityDelay = 
				CASE 
					when Flights.SECURITY_DELAY is null then cast(1 AS bit) 
					else cast(0 AS bit) 
				END
	left join MainRepo.DimAirline AS Airline on Airline.IATACode = 
			CASE when Flights.AIRLINE like '[a-zA-Z0-9][a-zA-Z0-9]' then Flights.AIRLINE else 'Unknown' END
	left join MainRepo.DimDistance AS DistanceSet 
			on DistanceSet.Distance = CASE when Flights.DISTANCE is null then 0 else Flights.DISTANCE END
			and DistanceSet.ReplacedDistance =
				CASE when Flights.DISTANCE is null then cast(1 AS bit) else cast(0 AS bit) END
	left join MainRepo.DimAirport AS OriginAirport on OriginAirport.IATACode = 
				CASE when Flights.ORIGIN_AIRPORT like '[a-zA-Z][a-zA-Z][a-zA-Z]' then Flights.ORIGIN_AIRPORT else 'Unknown' END
	left join MainRepo.DimAirport AS DestinationAirport on DestinationAirport.IATACode = 
				CASE when Flights.DESTINATION_AIRPORT like '[a-zA-Z][a-zA-Z][a-zA-Z]' then Flights.DESTINATION_AIRPORT else 'Unknown' END


	left join MainRepo.DimDateTime ScheduledDepartureDateTimeSet 
			on ScheduledDepartureDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_DEPARTURE is null then 0 
					else Flights.YEAR 
				END
			and ScheduledDepartureDateTimeSet.Month  = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_DEPARTURE is null then 0 
					else Flights.MONTH 
				END
			and ScheduledDepartureDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_DEPARTURE is null then 0 
					else Flights.DAY 
				END
			and ScheduledDepartureDateTimeSet.MilitaryHour = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_DEPARTURE is null then 0 
					when cast(LEFT(Flights.SCHEDULED_DEPARTURE, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.SCHEDULED_DEPARTURE, 2) AS int) 
				END
			and ScheduledDepartureDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_DEPARTURE is null then 0 
					else CAST(RIGHT(Flights.SCHEDULED_DEPARTURE, 2) AS int) 
				END
	left join MainRepo.DimDateTime DepartureDateTimeSet 
			on DepartureDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.DEPARTURE_TIME is null then 0 
					else Flights.YEAR 
				END
			and DepartureDateTimeSet.Month  = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.DEPARTURE_TIME is null then 0 
					else Flights.MONTH 
				END
			and DepartureDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.DEPARTURE_TIME is null then 0 
					else Flights.DAY 
				END
			and DepartureDateTimeSet.MilitaryHour = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.DEPARTURE_TIME is null then 0 
					when cast(LEFT(Flights.DEPARTURE_TIME, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.DEPARTURE_TIME, 2) AS int) 
				END
			and DepartureDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.DEPARTURE_TIME is null then 0 
					else CAST(RIGHT(Flights.DEPARTURE_TIME, 2) AS int) 
				END
	left join MainRepo.DimDateTime ScheduledArrivalDateTimeSet 
			on ScheduledArrivalDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_ARRIVAL is null then 0 
					else Flights.YEAR 
				END
			and ScheduledArrivalDateTimeSet.Month  = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_ARRIVAL is null then 0 
					else Flights.MONTH 
				END
			and ScheduledArrivalDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_ARRIVAL is null then 0 
					else Flights.DAY 
				END
			and ScheduledArrivalDateTimeSet.MilitaryHour = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_ARRIVAL is null then 0 
					when cast(LEFT(Flights.SCHEDULED_ARRIVAL, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.SCHEDULED_ARRIVAL, 2) AS int) 
				END
			and ScheduledArrivalDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.SCHEDULED_ARRIVAL is null then 0 
					else CAST(RIGHT(Flights.SCHEDULED_ARRIVAL, 2) AS int) 
				END
	left join MainRepo.DimDateTime ArrivalDateTimeSet 
			on ArrivalDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.ARRIVAL_TIME is null then 0 
					else Flights.YEAR 
				END
			and ArrivalDateTimeSet.Month  = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.ARRIVAL_TIME is null then 0 
					else Flights.MONTH 
				END
			and ArrivalDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.ARRIVAL_TIME is null then 0 
					else Flights.DAY 
				END
			and ArrivalDateTimeSet.MilitaryHour = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.ARRIVAL_TIME is null then 0 
					when cast(LEFT(Flights.ARRIVAL_TIME, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.ARRIVAL_TIME, 2) AS int) 
				END
			and ArrivalDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.ARRIVAL_TIME is null then 0 
					else CAST(RIGHT(Flights.ARRIVAL_TIME, 2) AS int) 
				END
	left join MainRepo.DimDateTime WheelsOffDateTimeSet 
			on WheelsOffDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_OFF is null then 0 
					else Flights.YEAR 
				END
			and WheelsOffDateTimeSet.Month = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_OFF is null then 0 
					else Flights.MONTH 
				END
			and WheelsOffDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_OFF is null then 0 
					else Flights.DAY 
				END
			and WheelsOffDateTimeSet.MilitaryHour = 
				CASE
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_OFF is null then 0 
					when cast(LEFT(Flights.WHEELS_OFF, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.WHEELS_OFF, 2) AS int) 
				END 
			and WheelsOffDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_OFF is null then 0 
					else CAST(RIGHT(Flights.WHEELS_OFF, 2) AS int) 
				END
	left join MainRepo.DimDateTime WheelsOnDateTimeSet 
			on WheelsOnDateTimeSet.Year = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_ON is null then 0 
					else Flights.Year 
				END
			and WheelsOnDateTimeSet.Month = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_ON is null then 0 
					else Flights.MONTH 
				END
			and WheelsOnDateTimeSet.DayOfMonth = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_ON is null then 0 
					else Flights.DAY 
				END
			and WheelsOnDateTimeSet.MilitaryHour = 
				CASE
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_ON is null then 0 
					when cast(LEFT(Flights.WHEELS_ON, 2) AS int) = 24 then 0 
					else cast(LEFT(Flights.WHEELS_ON, 2) AS int) 
				END 
			and WheelsOnDateTimeSet.TheMinute = 
				CASE 
					when Flights.YEAR is null then 0 
					when Flights.MONTH is null then 0 
					when Flights.DAY is null then 0 
					when Flights.WHEELS_ON is null then 0 
					else CAST(RIGHT(Flights.WHEELS_ON, 2) AS int) 
				END
	EXCEPT
	select TaxiOut, ReplacedTaxiOut, TaxiIn, ReplacedTaxiIn, SheduledFlightTime, ReplacedSheduledFlightTime, 
		FlightTime, ReplacedFlightTime, AirTime, ReplacedAirTime, Flights, ReplacedFlights, FlightNumber, DepartureDelay,
		ReplacedDepartureDelay, DepartureDelayMinutes, ArrivalDelay, ReplacedArrivalDelay, ArrivalDelayMinutes , IsFlightDelayed,FKFlightStatus, 
		FKPlane, FKDelayType,  FKSheduledDepartureDateTime, FKSheduledArrivalDateTime, FKDepartureDateTime, FKArrivalDateTime, FKWheelsOnDateTime, 
		FKWheelsOffDateTime, FKAirline, FKDestinationAirport, FKOriginAirport, FKDistance
	from MainRepo.FactFlight
END