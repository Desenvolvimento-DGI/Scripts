
CREATE TABLE IF NOT EXISTS `RapideyeScene` (
  `SceneId` varchar(32) NOT NULL DEFAULT '',
  `OffNadirAngle` float DEFAULT NULL,
  `SunAzimuth` float DEFAULT NULL,
  `SunElevation` float DEFAULT NULL,
  `Gralha` varchar(64) DEFAULT NULL,
  `DRD` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`SceneId`),
  KEY `gralha` (`Gralha`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

