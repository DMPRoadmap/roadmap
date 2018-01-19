## Convert all varchar(255) limits to the latest Mysql varchar(65535) limit.

## exported_plans
ALTER TABLE `exported_plans` MODIFY format VARCHAR(65535 );

##answers
ALTER TABLE `answers` MODIFY label_id VARCHAR(65535 );

##guidance_groups
ALTER TABLE `guidance_groups` MODIFY name VARCHAR(65535 );

##identifier_schemes
ALTER TABLE `identifier_schemes` 
MODIFY  `name` VARCHAR(65535 ), 
MODIFY  `description` VARCHAR(65535 ), 
MODIFY  `logo_url` VARCHAR(65535 ), 
MODIFY  `user_landing_url` VARCHAR(65535 );

##languages
ALTER TABLE `languages` 
MODIFY  `name` VARCHAR(65535 ), 
MODIFY  `description` VARCHAR(65535 ), 
MODIFY  `abbreviation` VARCHAR(65535 );

##question_formats
ALTER TABLE `question_formats` 
MODIFY  `title` VARCHAR(65535 );

##org_identifiers
ALTER TABLE `org_identifiers` 
MODIFY  `identifier` VARCHAR(65535 ), 
MODIFY  `attrs` VARCHAR(65535 ); 

##file_types
ALTER TABLE `file_types` 
MODIFY  `name` VARCHAR(65535 ),
MODIFY  `icon_name` VARCHAR(65535 ),  
MODIFY  `icon_location` VARCHAR(65535 ); 

##file_uploads
ALTER TABLE `file_uploads` 
MODIFY  `name` VARCHAR(65535 ),
MODIFY  `title` VARCHAR(65535 ),  
MODIFY  `location` VARCHAR(65535 ); 

##orgs
ALTER TABLE `orgs` 
MODIFY  `name` VARCHAR(65535 ),
MODIFY  `abbreviation` VARCHAR(65535 ),  
MODIFY  `target_url` VARCHAR(65535 ),
MODIFY  `wayfless_entity` VARCHAR(65535 ),
MODIFY  `sort_name` VARCHAR(65535 ),  
MODIFY  `logo_file_name` VARCHAR(65535 ),
MODIFY  `logo_uid` VARCHAR(65535 ),
MODIFY  `logo_name` VARCHAR(65535 ),  
MODIFY  `contact_email` VARCHAR(65535 ),
MODIFY  `links` VARCHAR(65535 ),
MODIFY  `feedback_email_subject` VARCHAR(65535 ),  
MODIFY  `contact_name` VARCHAR(65535 ); 

##phases
ALTER TABLE `phases` 
MODIFY  `title` VARCHAR(65535 ),
MODIFY  `slug` VARCHAR(65535 );

##plans
ALTER TABLE `plans` 
MODIFY  `title` VARCHAR(65535 ),
MODIFY  `slug` VARCHAR(65535 ),  
MODIFY  `grant_number` VARCHAR(65535 ),
MODIFY  `identifier` VARCHAR(65535 ),  
MODIFY  `principal_investigator` VARCHAR(65535 ),
MODIFY  `principal_investigator_identifier` VARCHAR(65535 ),
MODIFY  `data_contact` VARCHAR(65535 ),  
MODIFY  `funder_name` VARCHAR(65535 ),
MODIFY  `data_contact_email` VARCHAR(65535 ),
MODIFY  `data_contact_phone` VARCHAR(65535 ),  
MODIFY  `principal_investigator_email` VARCHAR(65535 ), 
MODIFY  `principal_investigator_phone`  VARCHAR(65535 ); 

##question_format_labels
ALTER TABLE `question_format_labels` 
MODIFY  `description` VARCHAR(65535 );

##question_options
ALTER TABLE `question_options` 
MODIFY  `text` VARCHAR(65535 );

##regions
ALTER TABLE `regions` 
MODIFY  `abbreviation` VARCHAR(65535 ),
MODIFY  `description` VARCHAR(65535 ),
MODIFY  `name` VARCHAR(65535 );

##sections
ALTER TABLE `sections` 
MODIFY  `title` VARCHAR(65535 );

##splash_logs
ALTER TABLE `splash_logs` 
MODIFY  `destination` VARCHAR(65535 );

##templates
ALTER TABLE `templates` 
MODIFY  `title` VARCHAR(65535 ),
MODIFY  `locale` VARCHAR(65535 ),
MODIFY  `links` VARCHAR(65535 );

##themes 
ALTER TABLE `themes` 
MODIFY  `title` VARCHAR(65535 ),
MODIFY  `locale` VARCHAR(65535 );

##token_permission_types
ALTER TABLE `token_permission_types` 
MODIFY  `token_type` VARCHAR(65535 );

##user_identifiers
ALTER TABLE `user_identifiers` 
MODIFY  `identifier` VARCHAR(65535 );


## For the below tables the Indexes needed to be dropped and recreated 
##to prevent the limit error "Specified key was too long; max key length."

##users
ALTER TABLE `users` DROP INDEX `index_users_on_email`;
  
ALTER TABLE `users` 
MODIFY  `firstname` VARCHAR(65535 ),
MODIFY  `surname` VARCHAR(65535 ),  
MODIFY  `email` VARCHAR(65535 ),
MODIFY  `orcid_id` VARCHAR(65535 ),  
MODIFY  `shibboleth_id` VARCHAR(65535 ),
MODIFY  `encrypted_password` VARCHAR(65535 ),
MODIFY  `reset_password_token` VARCHAR(65535 ),  
MODIFY  `current_sign_in_ip` VARCHAR(65535 ),
MODIFY  `last_sign_in_ip` VARCHAR(65535 ),
MODIFY  `confirmation_token` VARCHAR(65535 ),  
MODIFY  `invitation_token` VARCHAR(65535 ), 
MODIFY  `api_token` VARCHAR(65535 ),  
MODIFY  `invited_by_type` VARCHAR(65535 ), 
MODIFY  `other_organisation`  VARCHAR(65535 );

ALTER TABLE `users`ADD INDEX `index_users_on_email` (email(3072));

##perms
ALTER TABLE `perms` DROP INDEX `index_perms_on_name`;
ALTER TABLE `perms` DROP INDEX `index_roles_on_name_and_resource_type_and_resource_id`;

ALTER TABLE `perms` 
MODIFY `name` VARCHAR(65535);

ALTER TABLE `perms` ADD INDEX `index_perms_on_name` (name(3072));
ALTER TABLE `perms` ADD INDEX `index_roles_on_name_and_resource_type_and_resource_id` (name(3072));


##settings
ALTER TABLE `settings` DROP INDEX `index_settings_on_target_type_and_target_id_and_var`;

ALTER TABLE `settings` 
MODIFY `var` VARCHAR(65535),
MODIFY `target_type` VARCHAR(65535);

ALTER TABLE `settings` ADD UNIQUE INDEX `index_settings_on_target_type_and_target_id_and_var` (target_type(100), target_id, var(100));

