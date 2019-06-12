CREATE PROCEDURE PRC.FlightStatusToMainRepo
AS
BEGIN
	INSERT INTO MainRepo.DimFlightStatus
	select CASE when CANCELLED is null then cast(0 AS bit) else CANCELLED END AS Cancelled, 
	CASE when CANCELLED is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedCancelled,
	CASE when CANCELLATION_REASON is null then 'Unknown' else CANCELLATION_REASON END AS CancellationCode,
	CASE when DIVERTED is null then cast(0 AS bit) else DIVERTED END AS Diverted, 
	CASE when DIVERTED is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedDiverted,
	0 AS DivertedLandings,
	cast(1 AS bit) AS ReplacedDivertedLandings
	from stage.Flights
	EXCEPT
	select 
		Canceled, ReplacedCancelled, CancellationCode, Diverted, ReplacedDiverted, DivertedLandings, ReplacedDivertedLandings
	from MainRepo.DimFlightStatus
END;