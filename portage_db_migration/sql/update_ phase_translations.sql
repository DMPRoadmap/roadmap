begin;
-- update field title and description with random wordings and link
update phase_translations
	set title = str_random_lipsum(5, null, null) 
		, description = concat('<p>', str_random_lipsum(5, null, null), ' <a href="http://google.com">'
		, str_random_lipsum(3, null, null), '</a> ', str_random_lipsum(4, null, null), '</p>')
	where id > 0 and not (title = '' or title is null);
select * from phase_translations
	limit 100;
commit;
