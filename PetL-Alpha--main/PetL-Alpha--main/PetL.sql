CREATE TABLE IF NOT EXISTS `pet` (
  `identifier` varchar(60) NOT NULL,
  `petmodel` varchar(60) DEFAULT NULL,
  `food` int(2) NOT NULL DEFAULT 0,
  `thirst` int(2) NOT NULL DEFAULT 0,
  `nickname` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
