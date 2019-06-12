CREATE SCHEMA MainRepo;
-- Wymiar linia lotnicza --
CREATE TABLE MainRepo.DimAirline (ID_Airline int IDENTITY NOT NULL, IATACode varchar(255) NULL, Name varchar(255) NULL, ShortName varchar(255) NULL, Callsign varchar(255) NULL, Country varchar(255) NULL, Active bit NULL, ReplacedActive bit NOT NULL, [Unique] bit NULL, PRIMARY KEY (ID_Airline));
-- Wymiar odległość --
CREATE TABLE MainRepo.DimDistance (ID_Distance int IDENTITY NOT NULL, Distance int NULL, ReplacedDistance bit NOT NULL, DistanceGroup int NULL, DistanceGroupName varchar(255) NOT NULL, PRIMARY KEY (ID_Distance));
CREATE UNIQUE INDEX DimDistance_ID_Distance ON MainRepo.DimDistance (ID_Distance);
-- Wymiar statusu lotu --
CREATE TABLE MainRepo.DimFlightStatus (ID_FlightStatus int IDENTITY NOT NULL, Canceled bit NULL, ReplacedCancelled bit NOT NULL, CancellationCode varchar(255) NULL, Diverted bit NULL, ReplacedDiverted bit NOT NULL, DivertedLandings int NULL, ReplacedDivertedLandings bit NOT NULL, PRIMARY KEY (ID_FlightStatus));
CREATE UNIQUE INDEX DimFlightStatus_ID_FlightStatus ON MainRepo.DimFlightStatus (ID_FlightStatus);
-- Wymiar samolot --
CREATE TABLE MainRepo.DimPlane (ID_Plane int IDENTITY NOT NULL, TailNumber varchar(255) NULL, PRIMARY KEY (ID_Plane));
CREATE UNIQUE INDEX DimPlane_ID_Plane ON MainRepo.DimPlane (ID_Plane);
-- Wymiar lotnisko --
CREATE TABLE MainRepo.DimAirport (ID_Airport int IDENTITY NOT NULL, IATACode varchar(255) NULL, Name varchar(255) NULL, City varchar(255) NULL, State varchar(255) NULL, StateShort varchar(255) NULL, Country varchar(255) NULL, Latitude decimal(10, 4) NULL, ReplacedLatitude bit NOT NULL, Longitude decimal(10, 4) NULL, ReplacedLongitude bit NOT NULL, Altitude int NULL, ReplacedAltitude bit NOT NULL, Timezone decimal(10, 4) NULL, ReplacedTimezone bit NOT NULL, DST varchar(255) NULL, PRIMARY KEY (ID_Airport));
-- Wymiar typ opóźnienia--
CREATE TABLE MainRepo.DimDelayType (ID_DelayType int IDENTITY NOT NULL, WeatherDelay int NULL, ReplacedWeatherDelay bit NOT NULL, IsWeatherDelay bit NOT NULL, AirlineDelay int NULL, ReplacedAirlineDelay bit NOT NULL, IsAirlineDelay bit NOT NULL, AirSystemDelay int NULL, ReplacedAirSystemDelay bit NOT NULL, IsAirSystemDelay bit NOT NULL, SecurityDelay int NULL, ReplacedSecurityDelay bit NOT NULL, IsSecurityDelay bit NOT NULL, LateAircraftDelay int NULL, ReplacedLateAircraftDelay bit NOT NULL, IsLateAircraftDelay bit NOT NULL, PRIMARY KEY (ID_DelayType));
CREATE UNIQUE INDEX DimDelayType_ID_DelayType ON MainRepo.DimDelayType (ID_DelayType);
-- Wymiar data -- 
CREATE TABLE MainRepo.DimDateTime (ID_DateTime int IDENTITY NOT NULL, DateKey int NULL, FullDateUK char(10) NULL, FullDateUSA char(10) NULL, FullDatePL char(10) NULL, DayOfMonth varchar(2) NULL, DayName varchar(9) NULL, DayNamePL varchar(20) NULL, DayOfWeekUSA char(1) NULL, DayOfWeekUK char(1) NULL, DayOfYear varchar(3) NULL, Month varchar(2) NULL, MonthName varchar(9) NULL, MonthNamePL varchar(20) NULL, MonthOfQuarter varchar(2) NULL, Quarter char(1) NULL, QuarterName varchar(9) NULL, Year char(4) NULL, IsWeekday bit NULL, MilitaryHour int NULL, StandardHour int NULL, TheMinute int NULL, Standard varchar(2) NULL, PRIMARY KEY (ID_DateTime));
CREATE UNIQUE INDEX DimDateTime_ID_DateTime ON MainRepo.DimDateTime (ID_DateTime);
-- Tabela faktów LOT --
CREATE TABLE MainRepo.FactFlight (ID_FactFlight int IDENTITY NOT NULL, TaxiOut int NULL, ReplacedTaxiOut bit NOT NULL, TaxiIn int NULL, ReplacedTaxiIn bit NOT NULL, SheduledFlightTime int NULL, ReplacedSheduledFlightTime bit NOT NULL, FlightTime int NULL, ReplacedFlightTime bit NOT NULL, AirTime int NULL, ReplacedAirTime bit NOT NULL, Flights int NULL, ReplacedFlights bit NOT NULL, FlightNumber int NULL, DepartureDelay int NULL, ReplacedDepartureDelay int NULL, DepartureDelayMinutes int NULL, ArrivalDelay int NULL, ReplacedArrivalDelay int NULL, ArrivalDelayMinutes int NULL, IsFlightDelayed int NOT NULL, FKFlightStatus int NOT NULL, FKPlane int NOT NULL, FKDelayType int NOT NULL, FKSheduledDepartureDateTime int NOT NULL, FKSheduledArrivalDateTime int NOT NULL, FKDepartureDateTime int NOT NULL, FKArrivalDateTime int NOT NULL, FKWheelsOnDateTime int NOT NULL, FKWheelsOffDateTime int NOT NULL, FKAirline int NOT NULL, FKDestinationAirport int NOT NULL, FKOriginAirport int NOT NULL, FKDistance int NOT NULL, PRIMARY KEY (ID_FactFlight));
CREATE UNIQUE INDEX FactFlight_ID_FactFlight ON MainRepo.FactFlight (ID_FactFlight);

-- Dodawanie kluczy --
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKAirline = ID_Airline] FOREIGN KEY (FKAirline) REFERENCES MainRepo.DimAirline (ID_Airline);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKArrivalDateTime = ID_DateTime] FOREIGN KEY (FKArrivalDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKDelayType = ID_DelayType] FOREIGN KEY (FKDelayType) REFERENCES MainRepo.DimDelayType (ID_DelayType);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKDepartureDateTime = ID_DateTime] FOREIGN KEY (FKDepartureDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKDestinationAirport = ID_Airport] FOREIGN KEY (FKDestinationAirport) REFERENCES MainRepo.DimAirport (ID_Airport);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKDistance = ID_Distance] FOREIGN KEY (FKDistance) REFERENCES MainRepo.DimDistance (ID_Distance);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKFlightStatus = ID_FlightStatus] FOREIGN KEY (FKFlightStatus) REFERENCES MainRepo.DimFlightStatus (ID_FlightStatus);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKOriginAirport = ID_Airport] FOREIGN KEY (FKOriginAirport) REFERENCES MainRepo.DimAirport (ID_Airport);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKPlane = ID_Plane] FOREIGN KEY (FKPlane) REFERENCES MainRepo.DimPlane (ID_Plane);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKSheduledArrivalDateTime - ID_DateTime] FOREIGN KEY (FKSheduledArrivalDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKSheduledDepartureDateTime = ID_DateTime] FOREIGN KEY (FKSheduledDepartureDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKWheelsOffDateTime = ID_DateTime] FOREIGN KEY (FKWheelsOffDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);
ALTER TABLE MainRepo.FactFlight ADD CONSTRAINT [FKWheelsOnDateTime = ID_DateTime] FOREIGN KEY (FKWheelsOnDateTime) REFERENCES MainRepo.DimDateTime (ID_DateTime);