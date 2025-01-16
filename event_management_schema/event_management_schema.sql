/*
Smash Database Build
Purple Part

By jingrui & Cathy

Includes: tblRESTRICTION_TYPE; tblRESTRICTION; tblACTION, tblPERSON_EVENT_ACTION,
         tblPERSONEVENT, tblEVENT, EVENT_RESTRICTION, EVENT_TYPE
        tblACHIEVEMENT_TYPE, tblACHIEVEMENT, tblPERSON_EVENT_ACHIEVEMENT, PERSON_EVENT
        RATING, NOTE_TYPE, LOCATION_TYPE, LOCATION,

Look-up tables:
     RESTRICTION_TYPE --> tblRESTRICTION --> tblEVENT_RESTRICTION
     ACTION -->
     ACHIEVEMENT_TYPE --> tblACHIEVEMENT
     RATING
     NOTE_TYPE
     EVENT_TYPE
     LOCATION_TYPE  --> tblLOCATION --> tblEVENT

*/

CREATE TABLE tblRESTRICTION_TYPE
(
    RestrictTypeID INTEGER IDENTITY(1, 1) PRIMARY KEY,
    RestrictTypeName VARCHAR(50) NOT NULL,
    RestrictTypeDescr VARCHAR(500) NULL
)
GO


CREATE TABLE tblACTION
(
    ActionID INTEGER IDENTITY(1, 1) PRIMARY KEY,
    ActionName VARCHAR(50) NOT NULL,
    ActionDescr VARCHAR(500) NULL
)
GO


CREATE TABLE tblACHIEVEMENT_TYPE
(
    AchievementTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    AchievementTypeName VARCHAR(50) NOT NULL,
    AchievementTypeDescr VARCHAR(500) NULL
)
GO


CREATE TABLE tblRATING
(
    RatingID INTEGER IDENTITY(1,1) PRIMARY KEY,
    RatingName VARCHAR(50) NOT NULL,
    RatingNumeric NUMERIC(7, 2) NOT NULL,
    RatingDescr VARCHAR(500) NULL
)
GO

CREATE TABLE tblNOTE_TYPE
(
    NoteTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    NoteTypeName VARCHAR(50) NOT NULL,
    NoteTypeDescr VARCHAR(500) NULL
)
GO


CREATE TABLE tblLOCATION_TYPE
(
    LocationTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    LocationTypeName VARCHAR(50) NOT NULL,
    LocationTypeDescr VARCHAR(500) NULL
)
GO

CREATE TABLE tblEVENT_TYPE
(
    EventTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
    EventTypeName VARCHAR(50) NOT NULL,
    EventTypeDescr VARCHAR(500) NULL
)
GO

--Above are lookups

CREATE TABLE tblRESTRICTION
(
    RestrictionID INTEGER IDENTITY(1,1) PRIMARY KEY,
    RestrictionName VARCHAR(50) NOT NULL,
    RestrictionDescr VARCHAR(500) NULL
)GO

ALTER TABLE tblRESTRICTION
ADD CONSTRAINT FK_tblRESTRICTION_RestrictionTypeID
FOREIGN KEY(RestrictionTypeID)
REFERENCES tblRESTRICTION_TYPE(RestrictionTypeID)



CREATE TABLE tblLOCATION
(   LocationID INTEGER IDENTITY(1,1) PRIMARY KEY,
    LocationName VARCHAR(50) NOT NULL,
    /* Not sure LocStreetNumber's type */
    LocStreetNumber VARCHAR(500) NULL,
    LocationCity VARCHAR(500) NOT NULL,
    LocationState VARCHAR(500) NOT NULL,
    LocationZip INT NOT NULL,
    LocationDescr VARCHAR(500),
    LocationTypeID INT FOREIGN KEY REFERENCES tblLOCATION_TYPE(LocationTypeID) NOT NULL)
GO



CREATE TABLE tblEVENT_RESTRICTION
(
    EventRestrictID INTEGER IDENTITY(1,1) PRIMARY KEY,
    RestrictionID INTEGER FOREIGN KEY REFERENCES tblRESTRICTION(RestrictionID) NOT NULL,
    EventID INT FOREIGN KEY REFERENCES tblEVENT(EventID) NOT NULL
)GO


CREATE TABLE tblEVENT
(
    EventID INTEGER IDENTITY(1,1) NOT NULL,
    EventName VARCHAR(50) NOT NULL,
    EventDate DATE NOT NULL,
    EventDescr VARCHAR(500) NULL,
    EventTypeID INT FOREIGN KEY REFERENCES tblEVENT_TYPE(EventTypeID) NOT NULL,
    LocationID INT FOREIGN KEY REFERENCES tblLOCATION(LocationID) NOT NULL
)

CREATE TABLE tblACHIEVEMENT
(
    AchievementID INTEGER IDENTITY(1,1) PRIMARY KEY,
    AchievementName VARCHAR(50) NOT NULL,
    AchievementDescr VARCHAR(500),
    AchievementTypeID INT FOREIGN KEY REFERENCES tblACHIEVEMENT_TYPE(AchievementID) NOT NULL
)

CREATE TABLE tblPERSON_EVENT
(
    PCEventID INTEGER IDENTITY(1,1) PRIMARY KEY,
    EventID INT FOREIGN KEY REFERENCES tblEVENT(EventID) NOT NULL,
    PersonContextID INT FOREIGN KEY REFERENCES tblPERSON_CONTEXT(PersonContextID) NOT NULL
)
GO

CREATE TABLE tblPERSON_EVENT_ACHIEVEMENT
(
    PEA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
    PCEventID INT FOREIGN KEY REFERENCES tblPERSON_EVENT(PCEventID) NOT NULL,
    AchievementID INT FOREIGN KEY REFERENCES tblACHIEVEMENT(AchievementID) NOT NULL,

)

CREATE TABLE tblNOTE
(
    NoteID INTEGER IDENTITY(1,1) PRIMARY KEY,
    NoteDateTime TIME NULL,
    NoteBody VARCHAR(500) NULL,
    PCEventID INT FOREIGN KEY REFERENCES tblPERSON_EVENT(PCEventID) NOT NULL,
    NoteTypeID INT FOREIGN KEY REFERENCES tblNOTE_TYPE(NoteTypeID) NOT NULL,
    RatingID INT FOREIGN KEY REFERENCES tblRATING(RatingID) NOT NULL,
)

CREATE TABLE tblPERSON_EVENT_ACTION
(
    PEA_ID INTEGER IDENTITY(1,1) PRIMARY KEY,
    ActionDateTime TIME NULL,
    PCEventID INT FOREIGN KEY REFERENCES tblPERSON_EVENT(PCEventID) NOT NULL,
    ActionID INT FOREIGN KEY REFERENCES tblACTION(ActionID) NOT NULL
)
GO


--StoreProcedures
CREATE OR ALTER PROCEDURE GetRestrictionTypeID
@RestrictTypeName VARCHAR(50),
@RestrictTypeID INT OUTPUT
AS

SET @RestrictTypeID = (SELECT RT.RestrictTypeID
                        FROM tblRESTRICTION_TYPE RT
                        WHERE RT.RestrictTypeName = @RestrictTypeName)
GO

CREATE OR ALTER PROCEDURE GetLocationTypeID
@LocationTypeName VARCHAR(50),
@LocationTypeID INT OUTPUT
AS

SET @LocationTypeID = (SELECT LT.LocationTypeID
                        FROM tblLOCATION_TYPE LT
                        WHERE LT.LocationTypeName = @LocationTypeName
)
GO


SET @NoteTypeID = (SELECT NT.NoteTypeID
                    FROM tblNOTE_TYPE NT
                    WHERE NT.NoteTypeName = @NoteTypeName)
GO



CREATE OR ALTER PROCEDURE GetEventTypeID
@EventTypeName VARCHAR(50),
@EventTypeID INT OUTPUT
AS

SET @EventTypeID = (SELECT ET.EventTypeID
                    FROM tblEVENT_TYPE ET
                    WHERE ET.EventTypeName = @EventTypeName)
GO


CREATE OR ALTER PROCEDURE GetRestrictionID
@RestrictionName VARCHAR(50),
@RestrictionTypeName VARCHAR(50),
@RestrictionID INT OUTPUT
AS

DECLARE @RT_ID INT

EXEC GetRestrictionTypeID
@RestrictTypeName = @RestrictionTypeName,
@RestrictTypeID = @RT_ID OUTPUT

SET @RestrictionID = (
    SELECT R.RestrictionID
    FROM tblRESTRICTION R
    WHERE R.RestrictionName = @RestrictionName
        AND R.RestrictionTypeID = @RT_ID
)
GO


CREATE OR ALTER PROCEDURE GetLocationID
@LocName VARCHAR(50),
@LocTypeName VARCHAR(50),
@LocCity VARCHAR(50),
@LocState VARCHAR(50),
@LocationID INT OUTPUT
AS

DECLARE @LT_ID INT

EXEC GetLocationTypeID
@LocationTypeName = @LocTypeName,
@LocationTypeID = @LT_ID OUTPUT

SET @LocationID = (
    SELECT L.LocationID
    FROM tblLOCATION L
    WHERE L.LocationName = @LocName
        AND L.LocationCity = @LocCity
        AND L.LocationState = @LocState
)
GO


CREATE OR ALTER PROCEDURE GetEventID
@EventName VARCHAR(50),
@EventDate DATE,
@ETName VARCHAR(50),
@LocationName VARCHAR(50),
@LocationTypeName VARCHAR(50),
@LocationCity VARCHAR(50),
@LocationState VARCHAR(50),
@EID INT OUTPUT
AS

DECLARE @L_ID INT, @ET_ID INT

--Getting LocationID
EXEC GetLocationID
@LocName = @LocationName,
@LocTypeName = @LocationTypeName,
@LocCity = @LocationCity,
@LocState = @LocationState,
@LocationID = @L_ID OUTPUT

EXEC GetEventTypeID
@EventTypeName = @ETName,
@EventTypeID = @ET_ID OUTPUT

SET @EID = (
    SELECT E.EventID
    FROM tblEVENT E
    WHERE E.EventTypeID = @ET_ID
        AND E.LocationID = @L_ID
        AND E.EventName = @EventName
        AND E.EventDate = @EventDate
)
GO

CREATE OR ALTER PROCEDURE GetEventRestrictionID
@RestrictionName VARCHAR(50),
@RestrictionTypeName VARCHAR(50),
@EName VARCHAR(50),
@EDate DATE,
@EventTypeName VARCHAR(50),
@LocName VARCHAR(50),
@LocTypeName VARCHAR(50),
@LocCity VARCHAR(50),
@LocState VARCHAR(50),
@RestrictName VARCHAR(50),
@ResctricTypeName VARCHAR(50),
@ER_ID INT OUTPUT
AS

DECLARE @EventID INT,  @R_ID INT

--Getting EventID
EXEC GetEventID
@EventName = @EName,
@EventDate = @EDate,
@ETName = @EventTypeName,
@LocationName = @LocName,
@LocationTypeName = @LocTypeName,
@LocationCity = @LocCity,
@LocationState = @LocState,
@EID = @EventID OUTPUT

--Getting RestrictionID
EXEC GetRestrictionID
@RestrictionName = @RestrictName,
@RestrictionTypeName = @ResctricTypeName,
@RestrictionID = @R_ID OUTPUT

SET @ER_ID = (
    SELECT ER.EventRestrictID
    FROM tblEVENT_RESTRICTION ER
    WHERE ER.EventID = @EventID
        AND ER.RestrictionID = @ER_ID
)
GO


/* The lower part of the purple section of the ERD;

*/

CREATE OR ALTER PROCEDURE GetActionID
@ActionName varchar(50),
@ActionID INT OUTPUT
AS
SET @ActID =
(SELECT A.ActionID
FROM tblACTION A
WHERE A.ActionName = @ActionName)
GO


CREATE OR ALTER PROCEDURE GetAchieveTypeID
@AchieveTypeName varchar(50),
@AchieveTypeID INT OUTPUT
AS
SET @AchieveTypeID =
(SELECT AchievementTypeID
FROM tblACHIEVEMENT_TYPE
WHERE AchievementTypeName = @AchieveTypeName)
GO


CREATE OR ALTER PROCEDURE GetRatingID
@RateName varchar(50),
@RatingID INT OUTPUT
AS
SET @RateID =
(SELECT R.RatingID
FROM tblRATING R
WHERE RatingName = @RateName)
GO


CREATE OR ALTER PROCEDURE GetNoteTypeID
@NoteTypeName VARCHAR(50),
@NoteTypeID INT OUTPUT
AS
SET @NoteTypeID = (
    SELECT NT.NoteTypeID
    FROM tblNOTE_TYPE NT
    WHERE NT.NoteTypeName = @NoteTypeName
)
GO

CREATE OR ALTER PROCEDURE GetAchieveID
@AchieveName varchar(50),
@ATName VARCHAR(50),
@AchievementName VARCHAR(50),
@AchieveID INT OUTPUT
AS

DECLARE @AT_ID INT

EXEC GetAchieveTypeID
@AchieveTypeName = @ATName,
@AchieveTypeID = @AT_ID OUTPUT

SET @AchieveID =
    (SELECT A.AchievementID
        FROM tblACHIEVEMENT A
        WHERE AchievementName = @AchieveName
            AND A.AchievementTypeID = @AT_ID)
GO



CREATE OR ALTER PROCEDURE GetPersonEventActionID
@ActName varchar(50),
@EName varchar(50),
@EDate Date,
@ETName varchar(50),
@AchieveName varchar(50),
@AchieveTName varchar(50),
@NoteType varchar(50),
@RateName varchar(50),
@PEA_ID2 INT OUTPUT
AS


DECLARE @PCE_ID INT, @ActID INT


-- Get PersonEventID
EXEC GetPersonEventID
@EventName = @EName,
@EventDate = @EDate,
@EventTypeName = @ETName,
@AchievementName = @AchieveName,
@AchievementTypeName = @AchieveTName,
@NoteTypeName = @NoteType,
@RatingName = @RateName,
@PCEventID = @PCE_ID OUTPUT


-- Get ActionID
EXEC GetActionID
@ActionName = @ActName,
@ActionID = @ActID OUTPUT


SET @PEA_ID2 = (
    SELECT @PEA_ID
    FROM tblPERSON_EVENT_ACTION
    WHERE PCEventID = @PCE_ID
        AND ActionID = @ActID
)
GO


CREATE OR ALTER PROCEDURE GetPersonEventID
--Parameters for GetEventID
@EventName VARCHAR(50),
@EventDate DATE,
@EeventTypeName VARCHAR(50),
@LocationName VARCHAR(50),
@LocationTypeName VARCHAR(50),
@LocationCity VARCHAR(50),
@LocationState VARCHAR(50),
--Parameters for GetContexID
@ContName VARCHAR(50),
--Parameters for GetPersonID
@PFname VARCHAR(50),
@PLName VARCHAR(50),
@PDOB DATE,
@PCE_ID INT OUTPUT
AS

DECLARE @EventID INT, @PC_ID INT

--Getting EventID
EXEC GetEventID
@EName = @EventName,
@EDate = @EventDate,
@ETName = @EeventTypeName,
@LocName = @LocationName,
@LocTypeName = @LocationTypeName,
@Locity = @LocationCity,
@LocState = @LocationState,
@EID = @EventID OUTPUT


/*Needs Adjustment(of variable names) according to the GetPersonContextID procedure
  wrote by yellow part team;
*/
EXEC GetPersonContextID
@ContextName = @ContName,
@FName = @PFname,
@LName = @PLName,
@DOB = @PDOB,
@PCID = @PC_ID OUTPUT

SET @PCE_ID = (
    SELECT PE.PCEventID
    FROM tblPERSON_EVENT PE
    WHERE PE.EventID = @EventID
        AND PE.PersonContextID = @PC_ID
)
GO

CREATE OR ALTER PROCEDURE GetPEAID
--Parameters for GetEventID
@EName VARCHAR(50),
@EDate DATE,
@ETName VARCHAR(50),
@LocName VARCHAR(50),
@LTName VARCHAR(50),
@LocCity VARCHAR(50),
@LocState VARCHAR(50),
--Parameters for GetContexID
@ContextName VARCHAR(50),
--Parameters for GetPersonID
@Fname VARCHAR(50),
@LName VARCHAR(50),
@DOB DATE,
--Parameters for GetAchievementID
@AName varchar(50),
@ATName VARCHAR(50),
@AName VARCHAR(50),
@PEA_ID INT OUTPUT
AS

DECLARE @PCE_ID2 INT, @AID INT


EXEC GetPersonEventID
--Parameters for GetEventID
@EventName = @EName,
@EventDate = @EDate,
@EeventTypeName = @ETName,
@LocationName = @LocName,
@LocationTypeName = @LTName,
@LocationCity = @LocCity,
@LocationState = @LocState,
--Parameters for GetContexID
@ContName = @ContextName,
--Parameters for GetPersonID
@PFname = @Fname,
@PLName = @LName,
@PDOB = @DOB,
@PCE_ID = @PCE_ID2 OUTPUT


EXEC GetAchieveID
@AchieveName = @AName,
@AchievementTypeName = @ATName,
@AchievementName = @AName,
@AchieveID = @AID OUTPUT

SET @PEA_ID = (
    SELECT PEA.PEA_ID
    FROM tblPERSON_EVENT_ACHIEVEMENT PEA
    WHERE PEA.PCEventID = @PCE_ID2
        AND PEA.AchievementID = @AID
)
GO


CREATE OR ALTER PROCEDURE GetNoteID
@NoteTime TIME,
--Getting PCEventID
----Parameters for GetEventID
@EName VARCHAR(50),
@EDate DATE,
@ETName VARCHAR(50),
@LocName VARCHAR(50),
@LocTypeName VARCHAR(50),
@LocCity VARCHAR(50),
@LocState VARCHAR(50),
----Parameters for GetContexID
@ContextName VARCHAR(50),
----Parameters for GetPersonID
@Fname VARCHAR(50),
@LName VARCHAR(50),
@DOB DATE,
----Parameters for GetNoteTypeID
@NTName VARCHAR(50),
@RatingName VARCHAR(50),
@NoteID INT OUTPUT
AS

DECLARE @PE_ID INT, @NT_ID INT, @R_ID INT


EXEC GetPersonEventID
--Parameters for GetEventID
@EventName = @EName,
@EventDate = @EDate,
@EeventTypeName = @ETName,
@LocationName = @LocName,
@LocationTypeName = @LocTypeName,
@LocationCity = @LocCity,
@LocationState = @LocState,
--Parameters for GetContexID
@ContName = @ContextName,
--Parameters for GetPersonID
@PFname = @Fname,
@PLName = @LName,
@PDOB = @DOB,
@PCE_ID = @PE_ID OUTPUT


EXEC  GetNoteTypeID
@NoteTypeName = @NTName,
@NoteTypeID = @NT_ID OUTPUT

EXEC GetRatingID
@RateName = @RatingName,
@RatingID = @R_ID OUTPUT

SET @NoteID = (SELECT N.NoteID
               FROM tblNOTE N
               WHERE N.PCEventID = @PE_ID
                AND N.NoteDateTime = @NoteTime
                AND N.NoteType = @NT_ID
                AND N.RatingID = @R_ID
                )
GO


/*
Insertion Procedures, for Lookup tables
Includes:
    tblRESTRICTION_TYPE
    tblEVENT_TYPE
    tblLOCATION_TYPE
    tblNOTE_TYPE
    tblACHIEVEMENT_TYPE
    tblRATING
*/
BEGIN TRANSACTION
INSERT INTO tblRESTRICTION_TYPE(RestrctionTypeName, RestrictionTypeDescr)
VALUES('Demographic', " "), ('Membership', " "),('Financial', " "), ('Competence', " ")
COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO tblEVENT_TYPE(EventTypeName, EventTypeDescr)
VALUES('Competition', " "), ('Teaching', " "),('Peer Study Collaboration', " "), ('Interview', " ")
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO tblLOCATION_TYPE(LocationTypeName, LocationTypeDescr)
VALUES('Academic Campus', " "), ('Restaurant', " "),('Library', " "), ('Private Company', " "), ('Other', " ")
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO tblNOTE_TYPE(NoteTypeName, NoteTypeDescr)
VALUES('Experience Feedback', " "), ('Structural Criticism', " "),('Academic Criticism', " ")
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO tblACHIEVEMENT_TYPE(AchievementTypeName, AchievementTypeDescr)
VALUES('Badge', " "), ('Trophy', " "),('Ribbon', " ")
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO tblACTION(ActionName, ActionDescr)
VALUES('Contributed via Microphone', " "), ('Contributed via Chat', " "),('Lead Discussion', " ")
COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO tblRATING(RatingName, RatingNumeric, RatingDescr)
VALUES('Wonderful', 5.0, " "), ('Very Good', 4.0,  " "),('Good', 3.0,  " "), ('Fair', 2.0,  " "), ('Not Good', 1.0,  " "), ('Horrible', 0.0,  " ")
COMMIT TRANSACTION
GO

/*
Transactional stored procedure
Includes:
    tblRESTRICTION
    tblLOCATION
    tblACHIEVEMENT
*/




CREATE OR ALTER PROCEDURE INSERT_LOCATION
@LocationName VARCHAR(50),
@LocStreetNum VARCHAR(500),
@LocCity VARCHAR(50),
@LocState VARCHAR(50),
@LocZip INT,
@LocDescr VARCHAR(500),
--Parameters for GetLocType
@LTName VARCHAR(50)
AS

DECLARE @LT_ID INT

EXEC GetLocationTypeID
@LocationTypeName = @LTName,
@LocationTypeID = @LT_ID OUTPUT

IF @LT_ID IS NULL
	BEGIN
		PRINT 'variable @LT_ID is empty; check spelling';
		THROW 54321, '@LT_ID cannot be NULL; statement is terminating',1;
	END

BEGIN TRANSACTION G1
INSERT INTO tblLOCATION (LocationName, LocationTypeID, LocStreetNumber, LocCity, LocState, LocZip, LocationDescr)
VALUES (@LocationName, @LT_ID, @LocStreetNum, @LocCity, @LocState, @LocZip, @LocDescr)
IF @@ERROR <> 0
	BEGIN
		PRINT 'global error...rolling back transaction';
		ROLLBACK TRANSACTION G1
	END
ELSE
	COMMIT TRANSACTION G1
GO


BEGIN TRANSACTION G1
INSERT INTO tblRESTRICTION_TYPE (RestrictionTypeName, RestrictionTypeDescription)
VALUES (@RestrictionTypeName, @RTDescr)
IF @@ERROR <> 0
	BEGIN
		PRINT 'global error...rolling back transaction';
		ROLLBACK TRANSACTION G1
	END
ELSE
	COMMIT TRANSACTION G1
GO

CREATE OR ALTER PROCEDURE INSERT_RESTRICTION
@RestrictionDesc VARCHAR(500),
@RestrictionName VARCHAR(50),
--Parameter for GetRestricionTypeID
@RTName VARCHAR(50)
AS

DECLARE @RT_ID INT

--Getting RestrictionTypeID
EXEC GetRestrictionTypeID
@RestrictTypeName = @RTName,
@RestrictTypeID = @RT_ID OUTPUT

IF @RT_ID IS NULL
	BEGIN
		PRINT 'variable @RT_ID is empty; check spelling';
		THROW 54321, '@RT_ID cannot be NULL; statement is terminating',1;
	END

BEGIN TRANSACTION G1
INSERT INTO tblRESTRICTION (RestrictionTypeID, RestrictionName, RestrictionDesc)
VALUES (@RT_ID, @RestrictionName, @RestrictionDesc)
IF @@ERROR <> 0
	BEGIN
		PRINT 'global error...rolling back transaction';
		ROLLBACK TRANSACTION G1
	END
ELSE
	COMMIT TRANSACTION G1

GO



CREATE OR ALTER PROCEDURE GetRestrictionTypeID
@RestrictTypeName VARCHAR(50),
@RestrictTypeID INT OUTPUT
AS

SET @RestrictTypeID = (SELECT RT.RestrictTypeID
                        FROM tblRESTRICTION_TYPE RT
                        WHERE RT.RestrictTypeName = @RestrictTypeName)
GO



CREATE OR ALTER PROCEDURE INSERT_RESTRICTION
@RestrictionDesc VARCHAR(500),
@RestrictionName VARCHAR(50),
--Parameter for GetRestricionTypeID
@RTName VARCHAR(50)
AS

DECLARE @RT_ID INT

--Getting RestrictionTypeID
EXEC GetRestrictionTypeID
@RestrictTypeName = @RTName,
@RestrictTypeID = @RT_ID OUTPUT

IF @RT_ID IS NULL
	BEGIN
		PRINT 'variable @RT_ID is empty; check spelling';
		THROW 54321, '@RT_ID cannot be NULL; statement is terminating',1;
	END

BEGIN TRANSACTION G1
INSERT INTO tblRESTRICTION (RestrictionTypeID, RestrictionName, RestrictionDescr)
VALUES (@RT_ID, @RestrictionName, @RestrictionDesc)
    IF @@ERROR <> 0
        BEGIN
            PRINT 'global error...rolling back transaction';
            ROLLBACK TRANSACTION G1
        END
    ELSE
COMMIT TRANSACTION G1

GO



CREATE OR ALTER PROCEDURE WRAPPER_INSERT_RESTRICTION
@RUN INT
AS
DECLARE @RestrictionDesc2 VARCHAR(500) = (SELECT 'This is great a restriction and we are taking steps to make it good!')
DECLARE @RestrictionName2 VARCHAR(50) = (SELECT 'Restriction_')
DECLARE @RAND INT
DECLARE @RAND2 CHAR(5)

DECLARE @RT_RowCount INT = (SELECT COUNT(*) FROM tblRESTRICTION_TYPE)
DECLARE @RT_ID INT

WHILE @RUN > 0
BEGIN

SET @RAND = (SELECT RAND() * 100000)
SET @RAND2 = @RAND

SET @RT_ID = (SELECT RAND() * @RT_RowCount + 1)
SET @RestrictionName2 = (@RestrictionName2 + @RAND2)
    EXEC INSERT_RESTRICTION
        @RestrictionDesc = @RestrictionDesc2,
        @RestrictionName = @RestrictionName2
SET @RUN = @RUN - 1
END
