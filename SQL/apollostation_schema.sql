SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
CREATE SCHEMA IF NOT EXISTS `apollostation` DEFAULT CHARACTER SET latin1 ;
USE `mydb` ;
USE `apollostation` ;

-- -----------------------------------------------------
-- Table `apollostation`.`death`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `apollostation`.`death` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `pod` TEXT NOT NULL COMMENT 'Place of death' ,
  `coord` TEXT NOT NULL COMMENT 'X, Y, Z POD' ,
  `tod` DATETIME NOT NULL COMMENT 'Time of death' ,
  `job` TEXT NOT NULL ,
  `special` TEXT NOT NULL ,
  `name` TEXT NOT NULL ,
  `byondkey` TEXT NOT NULL ,
  `laname` TEXT NOT NULL COMMENT 'Last attacker name' ,
  `lakey` TEXT NOT NULL COMMENT 'Last attacker key' ,
  `gender` TEXT NOT NULL ,
  `bruteloss` INT(11) NOT NULL ,
  `brainloss` INT(11) NOT NULL ,
  `fireloss` INT(11) NOT NULL ,
  `oxyloss` INT(11) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

-- -----------------------------------------------------
-- Table `apollostation`.`library`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `apollostation`.`library` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `author` TEXT NOT NULL ,
  `title` TEXT NOT NULL ,
  `content` TEXT NOT NULL ,
  `category` TEXT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

-- -----------------------------------------------------
-- Table `apollostation`.`acc_items`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `apollostation`.`acc_items` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `ckey` TEXT NOT NULL ,
  `item` TEXT NOT NULL ,
  `time` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

-- -----------------------------------------------------
-- Table `apollostation`.`population`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `apollostation`.`population` (
  `id` INT(11) NOT NULL AUTO_INCREMENT ,
  `playercount` INT(11) NULL DEFAULT NULL ,
  `admincount` INT(11) NULL DEFAULT NULL ,
  `time` DATETIME NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
