begin;

-- update field firstname and surname
update users 
	set firstname = str_random_lipsum(1, null, null)
		, surname = str_random_lipsum(1, null, null)
        , last_sign_in_ip = random_ip()
	where id > 0;

-- update field firstname and surname
update users 
	set orcid_id = random_orcid()
	where id > 0 and not (orcid_id = '' or orcid_id is null);

select firstname, surname, email, orcid_id, last_sign_in_ip
from users	
limit 100;

rollback;
