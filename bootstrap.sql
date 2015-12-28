CREATE DATABASE IF NOT EXISTS twitterdata;
USE twitterdata

create table tweets (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id VARCHAR(15) NOT NULL,
  tsubuyaki VARCHAR(140) NOT NULL,
  t_date DATETIME NOT NULL,
  PRIMARY KEY(id)
);
