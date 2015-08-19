CREATE TABLE IF NOT EXISTS `nhlbi`.`mappings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `bam_id` INT(11) NOT NULL DEFAULT 0,
  `center_id` INT(11) NULL DEFAULT 0,
  `run_id` INT(11) NULL DEFAULT 0,
  `job_id` BIGINT NULL DEFAULT 0,
  `bam_host` VARCHAR(45) NULL DEFAULT NULL,
  `status` INT(2) NULL DEFAULT NULL,
  `cluster` VARCHAR(45) NULL DEFAULT NULL,
  `delay` INT(3) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  UNIQUE INDEX `idx_bam_id` (`bam_id` ASC),
  INDEX `idx_center_id` (`center_id` ASC),
  INDEX `idx_run_id` (`run_id` ASC),
  INDEX `idx_job_id` (`job_id` ASC),
  INDEX `idx_status` (`status` ASC),
  INDEX `idx_cluster` (`cluster` ASC)
);
