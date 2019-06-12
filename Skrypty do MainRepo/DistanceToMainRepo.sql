CREATE PROCEDURE PRC.DistanceToMainRepo
AS
BEGIN
	IF (select COUNT(*) from MainRepo.DimDistance where ID_Distance = -1) = 0
	BEGIN
		SET IDENTITY_INSERT MainRepo.DimDistance ON
		INSERT INTO MainRepo.DimDistance
			(	
				ID_Distance,
				Distance,
				ReplacedDistance,
				DistanceGroup,
				DistanceGroupName
			) VALUES
			(
				-1,
				0, 
				cast(1 AS bit),
				0,
				'Unknown'
			)
		SET IDENTITY_INSERT MainRepo.DimDistance OFF
	END
	
	INSERT INTO MainRepo.DimDistance
	select CASE when DISTANCE is null then 0 else DISTANCE END AS Distance, 
	CASE when DISTANCE is null then cast(1 AS bit) else cast(0 AS bit) END AS ReplacedDistance,
	CASE 
		when DISTANCE is null then 0
		when (DISTANCE/250+1) > 11 then 11 
		else (DISTANCE/250+1) 
	END AS DistanceGroup,
	CASE
		when DISTANCE is null then 'Unknown'
		when (DISTANCE/250+1) = 1 then '<250'
		when (DISTANCE/250+1) = 2 then '250-499'
		when (DISTANCE/250+1) = 3 then '500-749'
		when (DISTANCE/250+1) = 4 then '750-999'
		when (DISTANCE/250+1) = 5 then '1000-1249'
		when (DISTANCE/250+1) = 6 then '1250-1499'
		when (DISTANCE/250+1) = 7 then '1500-1749'
		when (DISTANCE/250+1) = 8 then '1750-1999'
		when (DISTANCE/250+1) = 9 then '2000-2249'
		when (DISTANCE/250+1) = 10 then '2250-2499'
		when (DISTANCE/250+1) >= 11 then '>2500'
	END AS DistanceGroupName
	from stage.Flights
	EXCEPT
	select 
		Distance,
		ReplacedDistance,
		DistanceGroup,
		DistanceGroupName
	from MainRepo.DimDistance
	order by DISTANCE
END