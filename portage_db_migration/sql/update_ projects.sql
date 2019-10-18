begin;

-- update field title and description with random wordings and link
update projects 
	set title = str_random_lipsum(5, null, null) 
		, description = str_random_lipsum(20, null, null)
	where id > 0 and not (title = '' or title is null);

-- update field principal_investigator with random names
update projects
	set principal_investigator = concat(str_random_lipsum(1, null, null), ' ', str_random_lipsum(1, null, null))
    where id > 0 and not (principal_investigator = '' or principal_investigator is null);
    
-- update field grant_number with random number
update projects
	set grant_number = lpad(floor(rand() * 1000000), 6, '0')
    where id > 0 and not (grant_number = '' or grant_number is null);

-- update field grant_number with random number
update projects
	set principal_investigator_identifier = random_orcid()
    where id > 0 and not (principal_investigator_identifier = '' or principal_investigator_identifier is null);

select title, description, principal_investigator, grant_number, principal_investigator_identifier 
from projects	
limit 100;
commit;
