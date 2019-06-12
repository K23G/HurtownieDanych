CREATE PROCEDURE PRC.PlaneToMainRepo
AS
BEGIN
	IF (SELECT COUNT(*) FROM MainRepo.DimPlane where ID_Plane = -1) = 0
	BEGIN
		SET IDENTITY_INSERT MainRepo.DimPlane ON
		INSERT INTO MainRepo.DimPlane
			(
				ID_Plane,
				TailNumber
			) VALUES
			(
				-1,
				'Unknown'
			)
		SET IDENTITY_INSERT MainRepo.DimPlane OFF
	END
	
	INSERT INTO MainRepo.DimPlane 
	SELECT TAIL_NUMBER as TailNumber from Stage.Flights
	WHERE TAIL_NUMBER is not null
	EXCEPT
	select TailNumber
	from MainRepo.DimPlane
END;