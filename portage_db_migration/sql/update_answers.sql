begin;
-- update field text with random wordings and link
update answers 
	set text = concat('<p>', str_random_lipsum(5, null, null), ' <a href="http://google.com">'
		, str_random_lipsum(3, null, null), '</a> ', str_random_lipsum(4, null, null), '</p>')
	where id > 0 and not (text = '' or text is null);
select * from answers 
	limit 100;
commit;

    