CREATE TABLE `radars` (
    `id` INT NOT NULL AUTO_INCREMENT, 
    `position` LONGTEXT NOT NULL, 
    `mph` INT(3) NOT NULL, 
    `name` VARCHAR(200) NOT NULL, 
    PRIMARY KEY (`id`)
)ENGINE=InnoDB;

INSERT INTO `items`(`name`, `label`) VALUES ('coyote','Coyote');