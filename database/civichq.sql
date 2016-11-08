SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for Apps
-- ----------------------------
DROP TABLE IF EXISTS `Apps`;
CREATE TABLE `Apps` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `AppName` varchar(100) DEFAULT NULL,
  `IsApproved` bit(1) NOT NULL,
  `AddedDate` datetime NOT NULL,
  `NgoId` int(11) NOT NULL,
  `CategoryId` int(11) NOT NULL,
  `Website` varchar(1000) DEFAULT NULL,
  `Facebook` varchar(1000) DEFAULT NULL,
  `GitHub` varchar(1000) DEFAULT NULL,
  `Description` varchar(1000) DEFAULT NULL,
  `CreationDate` date DEFAULT NULL,
  `Logo` varchar(150) DEFAULT NULL,
  `Tags` varchar(1000) DEFAULT NULL,
  `IsMaster` bit(1) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `AppName` (`AppName`),
  KEY `FK_Apps_Ngos` (`NgoId`),
  KEY `FK_Apps_Categories` (`CategoryId`),
  CONSTRAINT `FK_Apps_Categories` FOREIGN KEY (`CategoryId`) REFERENCES `Categories` (`Id`),
  CONSTRAINT `FK_Apps_Ngos` FOREIGN KEY (`NgoId`) REFERENCES `Ngos` (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Categories
-- ----------------------------
DROP TABLE IF EXISTS `Categories`;
CREATE TABLE `Categories` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `CatName` varchar(100) DEFAULT NULL,
  `IsActive` bit(1) NOT NULL,
  `Ordinal` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `CatName` (`CatName`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Ngos
-- ----------------------------
DROP TABLE IF EXISTS `Ngos`;
CREATE TABLE `Ngos` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `NgoName` varchar(100) DEFAULT NULL,
  `Phone` varchar(500) DEFAULT NULL,
  `Email` varchar(500) DEFAULT NULL,
  `Facebook` varchar(1000) DEFAULT NULL,
  `GooglePlus` varchar(1000) DEFAULT NULL,
  `LinkedIn` varchar(1000) DEFAULT NULL,
  `Twitter` varchar(1000) DEFAULT NULL,
  `Instagram` varchar(1000) DEFAULT NULL,
  `Description` varchar(1000) DEFAULT NULL,
  `Logo` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `NgoName` (`NgoName`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Tags
-- ----------------------------
DROP TABLE IF EXISTS `Tags`;
CREATE TABLE `Tags` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Tag` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Tag` (`Tag`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for Users
-- ----------------------------
DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(20) NOT NULL,
  `Password` varchar(10000) NOT NULL,
  `IsActive` bit(1) NOT NULL,
  `IsAdmin` bit(1) NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `UserName` (`UserName`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

-- ----------------------------
-- Procedure structure for AddApp
-- ----------------------------
DROP PROCEDURE IF EXISTS `AddApp`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `AddApp`(
	IN apname varchar(100) CHARSET utf8 ,
	IN categoryid int,
	IN appwebsite varchar(1000),
	IN appfacebook varchar(1000),
	IN appgithub varchar(1000),
	IN appdescription varchar(1000)  CHARSET utf8 ,
	IN appcreationdate date,
	IN applogo varchar(150),
	IN apptags varchar(1000),
	IN ngname varchar(100) CHARSET utf8  ,
	IN ngophone varchar(500),
	IN ngoemail varchar(500),
	IN ngofacebook varchar(1000),
	IN ngogoogleplus varchar(1000),
	IN ngolinkedin varchar(1000),
	IN ngotwitter varchar(1000),
	IN ngoinstagram varchar(1000),
	IN ngodescription varchar(500)  CHARSET utf8 ,
	IN ngologo varchar(150))
BEGIN
		DECLARE ngoId INT DEFAULT 0;
		DECLARE appId INT DEFAULT 0;
		DECLARE message VARCHAR(1999) DEFAULT '';

		DECLARE exit handler for sqlexception
			BEGIN
			-- ERROR


				GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
				@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
				SET message = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
				SELECT message as 'result';


				ROLLBACK;

			END;

		START TRANSACTION;

	    
		SELECT Id into ngoId from Ngos where NgoName = ngname;
		SET message := CONCAT(message, ' Ngo id este ',  coalesce(ngoId, 'null'));
		-- SELECT message AS msg;

		SET message := CONCAT(message, ' Getting app id ');
		SELECT Id into appId from Apps where AppName = apname;
		SET message := CONCAT(message, ' App id este ',  coalesce(appId, 'null'));
		-- SELECT message AS msg;

		IF ngoId = 0 THEN

			SET message := CONCAT(message, ' Insert Ngo ');

			INSERT Ngos(NgoName, Phone, Email, Facebook, GooglePlus, LinkedIn, Twitter, Instagram, Description, Logo)
			values (ngname, ngophone, ngoemail, ngofacebook, ngogoogleplus, ngolinkedin, ngotwitter, ngoinstagram, ngodescription, ngologo);

			SET ngoId := last_insert_id();
			SET message := CONCAT(message, ' Ngo id NOU este ',  coalesce(ngoId, 'null'));
			-- SELECT message AS msg;

		END IF;
    
   
		IF appId > 0 THEN

			SIGNAL SQLSTATE 'ERROR'
			SET MESSAGE_TEXT = 'Aplicatia exista deja!';

		END IF;
    
		INSERT INTO `Apps`
		(
		`AppName`,
		`IsApproved`,
		`AddedDate`,
		`NgoId`,
		`CategoryId`,
		`Website`,
		`Facebook`,
		`GitHub`,
		`Description`,
		`CreationDate`,
		`Logo`,
		`Tags`,
		`IsMaster`)
		VALUES
		(
		apname,
		0,
		NOW(),
		ngoId,
		categoryid,
		appwebsite,
		appfacebook,
		appgithub,
		appdescription,
		appcreationdate,
		applogo,
		apptags,
		0);
        
        CALL InsertTags(apptags);

	SET message = 'success';
	SELECT message as 'result';

	COMMIT;
	
END
;;
DELIMITER ;

-- ----------------------------
-- Procedure structure for InsertTags
-- ----------------------------
DROP PROCEDURE IF EXISTS `InsertTags`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `InsertTags`(
	IN theString varchar(1000) CHARSET utf8
)
BEGIN
	DECLARE message VARCHAR(1999) DEFAULT '';
    
    
	DECLARE exit handler for sqlexception
	BEGIN
    -- ERROR
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
		@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
		SET message = CONCAT(message, "ERROR ", @errno, " (", @sqlstate, "): ", @text);
		SELECT message as 'result';
        
	END;

	SET @delim = '#';
	SET theString := (SELECT SUBSTRING(theString, 2));
	-- SET message := CONCAT(message, ' newString2: ', theString);
	-- SELECT message as 'result';

	SET @Occurrences = LENGTH(theString) - LENGTH(REPLACE(theString, @delim, ''));
	-- SET message := CONCAT(message, ' Occurences: ', @Occurrences);
	-- SELECT message as 'result';
	myloop: WHILE (@Occurrences > 0)
        DO 
            SET @myValue = TRIM(SUBSTRING_INDEX(theString, @delim, 1));
            -- SET message := CONCAT(message, ' MyValue: ', @myValue);
            -- SELECT message as 'result';
            
            IF (@myValue != '') THEN
				
                IF NOT exists (select 1 from Tags where Tag = CONCAT('#', @myValue)) THEN
					INSERT Tags(Tag) VALUES (CONCAT('#', @myValue));
                END IF;
                
            ELSE
                LEAVE myloop; 
            END IF;
            SET @Occurrences = LENGTH(theString) - LENGTH(REPLACE(theString, @delim, ''));
            IF (@occurrences = 0) THEN 
                LEAVE myloop; 
            END IF;
            SET theString = SUBSTRING(theString,LENGTH(SUBSTRING_INDEX(theString, @delim, 1))+2);
	END WHILE;                  

END
;;
DELIMITER ;
