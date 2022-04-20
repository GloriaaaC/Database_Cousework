create or replace function
	Q7e(term_name text) returns float
as $$
declare r RECORD; total integer; underused integer; pre int := -1; hour float := 0; pre_hour float := 0; words text[][]; week_string text[]; week text; 
ending float; starting float; precode text;
begin

	SELECT * FROM Q7sub1(term_name) INTO underused;
	SELECT num FROM Q7d INTO total;

	for r in
		SELECT * FROM Q7a WHERE term = term_name ORDER BY id
	loop
		SELECT regexp_split_to_array(r.weeks, '') INTO week_string;

		hour := 0;

		foreach week in ARRAY week_string

		loop
			if week = '1' then

				if length(r.starting::text) = 3 then
					starting := SUBSTRING(r.starting::text,1,1)::float;
					if SUBSTRING(r.starting::text,2,3) = '30' then
						starting := starting + 0.5;
					end if;
				else 
					starting := SUBSTRING(r.starting::text,1,2)::float;
					if SUBSTRING(r.starting::text,3,4) = '30' then
						starting := starting + 0.5;
					end if;
				end if;

				if length(r.ending::text) = 3 then
					ending := SUBSTRING(r.ending::text,1,1)::float;
					if SUBSTRING(r.ending::text,2,3) = '30' then
						ending := ending + 0.5;
					end if;
				else 
					ending := SUBSTRING(r.ending::text,1,2)::float;
					if SUBSTRING(r.ending::text,3,4) = '30' then
						ending := ending + 0.5;
					end if;
				end if;

				hour := hour + ending - starting;

			end if;
		end loop;

		if (pre <> r.id and pre <> -1) then
            if (pre_hour < 200) then
			    underused := underused + 1;
            end if;
			pre_hour := 0;
		end if;

		pre := r.id;
		precode := r.code;
		pre_hour := pre_hour + hour;

	end loop;

	IF FOUND and pre_hour < 200 THEN
		underused := underused + 1;
	END IF;

	return ROUND(underused::numeric*100::numeric/total::numeric, 1);
end;
$$ language plpgsql;
