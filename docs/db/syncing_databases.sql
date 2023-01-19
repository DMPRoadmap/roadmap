# INSTRUCTIONS FOR DUMPING A DB AND RESTORING IT INTO A DIFFERENT ENVIRONMENT (e.g. prod -> stage)
# We need to skip certain tables so as not to invalidate user passwords or API credentials
# between environments

# Dump all tables except for those that have a User or OauthApplication
# ---------
# DMPTool
# mysqldump dmp -h -u -p --no-create-db --no-tablespaces --set-gtid-purged=OFF --ignore-table=dmp.users --ignore-table=dmp.oauth_applications --ignore-table=dmp.oauth_access_tokens --ignore-table=dmp.oauth_access_grants --ignore-table=dmp.users_perms --ignore-table=dmp.external_api_access_tokens --ignore-table=dmp.api_logs > ../latest.sql

# DMPHub
# mysqldump dmphub -h -u -p --no-create-db --no-tablespaces --set-gtid-purged=OFF --ignore-table=dmphub.api_client_authorizations --ignore-table=dmphub.api_client_histories --ignore-table=dmphub.api_client_permissions --ignore-table=dmphub.api_clients --ignore-table=dmphub.provenances > ../latest.sql

# Manually dump the user table based on the created_at date

# Heal tables that may have orphaned User or OauthApplication
# ---------
UPDATE answers
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);

UPDATE exported_plans
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);

UPDATE identifiers
SET identifiable_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE identifiable_id NOT IN (SELECT id FROM users)
AND identifiable_type = 'User';

UPDATE notification_acknowledgements
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);

UPDATE notes
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);

UPDATE oauth_access_grants
SET application_id = (SELECT id FROM oauth_applications WHERE name = 'dmptool')
WHERE application_id NOT IN (SELECT id FROM users);

UPDATE oauth_access_grants
SET resource_owner_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE resource_owner_id NOT IN (SELECT id FROM users);

UPDATE oauth_access_tokens
SET application_id = (SELECT id FROM oauth_applications WHERE name = 'dmptool')
WHERE application_id NOT IN (SELECT id FROM users);

UPDATE oauth_access_tokens
SET resource_owner_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE resource_owner_id NOT IN (SELECT id FROM users);

UPDATE prefs
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);

UPDATE roles
SET user_id = (SELECT id FROM users WHERE email = 'dmptool.researcher@gmail.com')
WHERE user_id NOT IN (SELECT id FROM users);
