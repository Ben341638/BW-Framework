-- BW Framework Database Schema

-- Players Table
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `money` longtext DEFAULT NULL,
  `charinfo` longtext DEFAULT NULL,
  `job` longtext DEFAULT NULL,
  `gang` longtext DEFAULT NULL,
  `position` longtext DEFAULT NULL,
  `metadata` longtext DEFAULT NULL,
  `inventory` longtext DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bans Table
CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vehicles Table
CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license` varchar(50) DEFAULT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `hash` varchar(50) DEFAULT NULL,
  `mods` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `plate` varchar(15) NOT NULL,
  `fakeplate` varchar(50) DEFAULT NULL,
  `garage` varchar(50) DEFAULT NULL,
  `fuel` int(11) DEFAULT 100,
  `engine` float DEFAULT 1000,
  `body` float DEFAULT 1000,
  `state` int(11) DEFAULT 1,
  `depotprice` int(11) NOT NULL DEFAULT 0,
  `drivingdistance` int(50) DEFAULT NULL,
  `status` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `plate` (`plate`),
  KEY `citizenid` (`citizenid`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Apartments Table
CREATE TABLE IF NOT EXISTS `apartments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default admin user
INSERT INTO `players` (`license`, `name`, `money`, `charinfo`, `job`, `gang`, `position`, `metadata`) 
VALUES 
('license:admin', 'Admin', '{"cash":5000,"bank":50000,"crypto":0}', '{"firstname":"Admin","lastname":"User","birthdate":"2000-01-01","gender":0,"nationality":"USA"}', '{"name":"unemployed","label":"Civilian","payment":10,"onduty":true}', '{"name":"none","label":"No Gang"}', '{"x":195.55,"y":-933.36,"z":30.69}', '{"hunger":100,"thirst":100,"stress":0,"armor":0,"health":200,"phone":"123456789","ishandcuffed":false,"injail":0,"jailitems":[],"status":[],"commandbinds":[],"bloodtype":"A+","dealerrep":0,"craftingrep":0,"attachmentcraftingrep":0,"currentapartment":"apartment1","inlaststand":false,"isdead":false}')
ON DUPLICATE KEY UPDATE `name` = 'Admin';