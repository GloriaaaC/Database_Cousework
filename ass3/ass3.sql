create or replace view Q1a(code, id, quota)
as
SELECT s.code, c.id, c.quota
FROM Courses as c JOIN Subjects as s
ON c.subject_id = s.id
JOIN Terms as t
ON c.term_id = t.id
WHERE c.quota > 50 and t.name = '19T3'
;

create or replace view Q1b(code, quota, enrolment)
as
SELECT MIN(q.code), MIN(q.quota), COUNT(q.id)
FROM Q1a as q JOIN Course_Enrolments as c
ON q.id = c.course_id
GROUP BY q.id
HAVING COUNT(q.id) > MIN(q.quota)
ORDER BY MIN(q.code)
;

create or replace view Q2a(course,cha)
as
SELECT SUBSTRING(code, 5, 8), SUBSTRING(code, 1, 4)
FROM Subjects
ORDER BY SUBSTRING(code, 5, 8), SUBSTRING(code, 1, 4)
;

create type Q2_rec as
     (code text, info text);

create or replace function
	Q2b(num integer) returns setof Q2_rec
as $$
declare  r RECORD; res Q2_rec; i integer := 0; pre text := ''; string text := '';
begin
	for r in
			SELECT * FROM Q2a 
		loop
			if (pre <> r.course and i > 0) then
				res.code := pre;
				res.info := string;
                if (i = num) then
				    return next res;
                end if;
				string := ''; 
				i := 0;
			end if;
			i := i + 1;
			string := string || ' ' || r.cha;
			pre := r.course;
		end loop;
		if (i = num) then
			res.code := pre;
			res.info := string;
			return next res;
    	end if;
end;
$$ language plpgsql;

create or replace view Q3a(id)
as
SELECT distinct c.id
FROM Courses as c JOIN Terms as t
ON c.term_id = t.id
WHERE t.name = '19T2'
;

create or replace view Q3b(building, code)
as
SELECT  distinct b.name, s.code
FROM Q3a as q JOIN Courses as c
ON q.id = c.id
JOIN Subjects as s
ON c.subject_id = s.id
JOIN Classes as Cla
ON c.id = Cla.course_id
JOIN Meetings as m
ON Cla.id = m.class_id
JOIN Rooms as r
ON m.room_id = r.id
JOIN Buildings as b
ON r.within = b.id
ORDER BY b.name, s.code
;

create type Q3_rec as
     (building text, course text);

create or replace function
	Q3c(prefix text) returns setof Q3_rec
as $$
declare  r RECORD; res Q3_rec;
begin
	for r in
			SELECT * FROM Q3b
			WHERE code ILIKE prefix || '%'
		loop
				res.building = r.building;
				res.course = r.code;
				return next res;
		end loop;
end;
$$ language plpgsql;

Create or replace view Q4a(term, id, code)
as
SELECT t.name, c.id, s.code
FROM Subjects as s JOIN Courses as c
ON s.id = c.Subject_id
JOIN Terms as t
On c.term_id = t.id
ORDER BY t.name, c.id, s.code
;

Create or replace view Q4b(id, num)
as
SELECT c.id, count(c.id)
FROM Courses as c JOIN Course_Enrolments as e
ON c.id = e.course_id
GROUP BY c.id
;

Create or replace view Q4c(term, code, num)
as
SELECT a.term, a.code, b.num
FROM Q4a as a JOIN Q4b as b 
ON a.id = b.id
ORDER BY a.term, a.code
;

create type Q4_rec as
     (term text, course text, num int);

create or replace function
	Q4d(prefix text) returns setof Q4_rec
as $$
declare  r RECORD; res Q4_rec;
begin
	for r in
			SELECT * FROM Q4c
			WHERE code ILIKE prefix || '%'
		loop
				res.term = r.term;
				res.course = r.code;
				res.num = r.num;
				return next res;
		end loop;
end;
$$ language plpgsql;

Create or replace view Q5a(code, id, class_type, class_tag, quota)
as
SELECT s.code, cla.id, claty.name, cla.tag, cla.quota
FROM Classes as cla JOIN ClassTypes as claty
ON cla.type_id = claty.id
JOIN Courses as c
ON cla.course_id = c.id
JOIN Subjects as s
ON s.id = c.Subject_id
JOIN Terms as t
On c.term_id = t.id
WHERE t.name = '19T3'
ORDER BY s.code, claty.name, cla.tag
;
Create or replace view Q5b(id, num)
as
SELECT c.id, count(c.id)
FROM Classes as c JOIN Class_Enrolments as e
ON c.id = e.class_id
GROUP BY c.id
;

Create or replace view Q5c(code, class_type, class_tag, percantage)
as
SELECT a.code, a.class_type, a.class_tag, ROUND(b.num::numeric*100::numeric/a.quota::numeric, 0)
FROM Q5a as a JOIN Q5b as b
ON a.id = b.id
ORDER BY a.code, a.class_type, a.class_tag, ROUND(b.num::numeric*100::numeric/a.quota::numeric, 0)
;

create type Q5_rec as
     (class_type text, class_tag text, num int);


create or replace function
	Q5d(course_name text) returns setof Q5_rec
as $$
declare  r RECORD; res Q5_rec;
begin
	for r in
			SELECT * FROM Q5c
			WHERE code = course_name and percantage < 50
		loop
				res.class_type = r.class_type;
				res.class_tag = r.class_tag;
				res.num = r.percantage;
				return next res;
		end loop;
end;
$$ language plpgsql;

create or replace function 
	Q6a(weeks text) returns text
as $$
declare  words text[]; w text; num text := ''; sta text; en text; sta_num int; en_num int; total text := ''; ans text := '';
begin
	IF (weeks ILIKE '%' || 'N' || '%' or weeks ILIKE '%' || '<' || '%') THEN
		return '00000000000';
	ELSE
		SELECT regexp_split_to_array(weeks,',') INTO words;
		foreach w in ARRAY words
		loop
			w := REPLACE(w,'10', 'A');
			w := REPLACE(w,'11', 'B');
			if (char_length(w) = 3) then
				sta := SUBSTRING(w,1,1);
				en := SUBSTRING(w,3,3);
				if sta = 'A' then
					sta_num = 10;
				elsif sta = 'B' then 
					sta_num = 11;
				else
					sta_num = sta::int;
				end if;

				if en = 'A' then
					en_num = 10;
				elsif en = 'B' then 
					en_num = 11;
				else
					en_num = en::int;
				end if;

				num := '';
				while sta_num <= en_num
				loop
					num := num || sta_num::text;
					sta_num := sta_num + 1;
				end loop;

				w := num;
			end if;
			w := REPLACE(w,'10', 'A');
			w := REPLACE(w,'11', 'B');
			total := total || w;
		end loop;


		sta_num := 1;
		en_num := 11;

		while sta_num <= en_num
			loop
				if sta_num = 10 then
					sta = 'A';
				elsif sta_num = 11 then 
					sta = 'B';
				else
					sta = sta_num::text;
				end if;
				IF total ILIKE '%' || sta || '%' then
					ans := ans || '1';
				ELSE
					ans := ans || '0';
				END IF;
				sta_num := sta_num + 1;
			end loop;
		return ans;
	END IF;
end;
$$ language plpgsql;

Create or replace view Q7a(term, id, day , starting , ending , weeks, code)
as
SELECT t.name, r.id, m.day, m.start_time, m.end_time, SUBSTRING(m.weeks_binary,1,10), r.code
FROM Rooms as r JOIN Meetings as m
ON r.id = m.room_id
JOIN Classes as cla
ON cla.id = m.class_id
JOIN Courses as c
ON c.id = cla.course_id
JOIN Subjects as s
ON s.id = c.Subject_id
JOIN Terms as t
On c.term_id = t.id
WHERE r.code ILIKE 'K-' || '%'
ORDER BY t.name, r.id, m.day
;

create or replace function
	Q7sub1(term_name text) returns int
as $$
declare  res int;
begin
	SELECT count(distinct(r.id, q.id))
	FROM Rooms as r LEFT JOIN Q7a as q
	ON r.id = q.id and q.term = term_name
	WHERE r.code ILIKE 'K-' || '%' and q.term is NULL 
	INTO res;
	return res;
end;
$$ language plpgsql;

Create or replace view Q7d(num)
as
SELECT distinct COUNT(id)
FROM Rooms
WHERE code ILIKE 'K-' || '%'
;

create type Q7_rec as (id int, day WeekDay, starting int, ending int, week_string text);

create or replace function
	Q7e(term_name text) returns setof Q7_rec
as $$
declare r RECORD; week text; 
ending int; starting int; rec Q7_rec;
begin

	for r in
		SELECT * FROM Q7a WHERE term = term_name ORDER BY id
	loop

		if length(r.starting::text) = 3 then
			starting := SUBSTRING(r.starting::text,1,1)::integer*2;
			if SUBSTRING(r.starting::text,2,3) = '30' then
				starting := starting + 1;
			end if;
		else 
			starting := SUBSTRING(r.starting::text,1,2)::integer*2;
			if SUBSTRING(r.starting::text,3,4) = '30' then
				starting := starting + 1;
			end if;
		end if;

		if length(r.ending::text) = 3 then
			ending := SUBSTRING(r.ending::text,1,1)::int*2;
			if SUBSTRING(r.ending::text,2,3) = '30' then
				ending := ending + 1;
			end if;
		else 
			ending := SUBSTRING(r.ending::text,1,2)::int*2;
			if SUBSTRING(r.ending::text,3,4) = '30' then
				ending := ending + 1;
			end if;
		end if;

		rec.id := r.id;
		rec.day := r.day;
		rec.starting := starting;
		rec.ending := ending;
		rec.week_string := r.weeks;

		return next rec;

	end loop;
end;
$$ language plpgsql;

Create or replace view Q8a(code, id, type , day, starting , ending)
as
SELECT s.code, cla.id, ty.name, m.day, m.start_time, m.end_time
FROM Meetings as m JOIN Classes as cla
ON cla.id = m.class_id
JOIN Courses as c
ON c.id = cla.course_id
JOIN Subjects as s
ON s.id = c.Subject_id
JOIN Terms as t
On c.term_id = t.id
JOIN ClassTypes as ty
ON cla.type_id = ty.id
WHERE t.name = '19T3' and ty.tag <> 'WEB'
ORDER BY s.code, ty.name, cla.id, m.day, m.start_time, m.end_time
;

create type Q8_rec as (code text, id int, type text, day WeekDay, starting int, ending int);

create or replace function
	Q8b(course text) returns setof Q8_rec
as $$
declare  r RECORD; res Q8_rec;
begin
	for r in
		SELECT * FROM Q8a WHERE code = course
	loop
		res.code = r.code;
		res.id = r.id;
		res.type = r.type;
		res.day = r.day;
		res.starting = r.starting;
		res.ending = r.ending;
		return next res;
	end loop;
end;
$$ language plpgsql;