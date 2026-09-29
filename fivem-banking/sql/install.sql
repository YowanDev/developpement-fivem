CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(64) NOT NULL,
    `type` ENUM('deposit', 'withdraw', 'transfer_in', 'transfer_out') NOT NULL,
    `amount` INT UNSIGNED NOT NULL,
    `label` VARCHAR(128) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
