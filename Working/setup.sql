DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `tokens`;

DROP TABLE IF EXISTS `social_networks`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `posts`;


CREATE TABLE `users` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`login` VARCHAR(64) NOT NULL,
	`email` VARCHAR(256) NOT NULL,
	`password` VARCHAR(64) NOT NULL,
	`salt` VARCHAR(64) NOT NULL
);

CREATE TABLE `tokens` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`token_string` VARCHAR(64) NOT NULL,
	`user_id` VARCHAR(64) NOT NULL,
	`expires_in` TIMESTAMP,
	`token_destination` INT NOT NULL
);

CREATE TABLE `social_networks` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(64) NOT NULL
);

CREATE TABLE `categories` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`name` VARCHAR(64) NOT NULL,
	`social_network_id` INT NOT NULL
);

CREATE TABLE `posts` (
	`id` INT AUTO_INCREMENT PRIMARY KEY,
	`content` TEXT NOT NULL,
	`date` DATETIME NOT NULL,
	`photo_url` VARCHAR(256),
	`category_id` INT NOT NULL
);


INSERT INTO `social_networks` (`id`, `name`) VALUES (1, 'VK');
INSERT INTO `categories` (`id`, `name`) VALUES (1, 'Infinite Feed', 1);

ALTER TABLE `users` MODIFY `password` VARCHAR(128) NOT NULL;
ALTER TABLE `users` MODIFY `salt` VARCHAR(128) NOT NULL;
