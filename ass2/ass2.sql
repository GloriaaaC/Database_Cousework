-- COMP3311 19T3 Assignment 2
-- Written by <<insert your name here>>

-- Q1 Which movies are more than 6 hours long? 

create or replace view Q1(title)
as
SELECT main_title
FROM Titles
WHERE runtime > 360 and format = 'movie'
;


-- Q2 What different formats are there in Titles, and how many of each?

create or replace view Q2(format, ntitles)
as
SELECT format, COUNT(format)
FROM Titles
GROUP BY format
;


-- Q3 What are the top 10 movies that received more than 1000 votes?

create or replace view Q3(title, rating, nvotes)
as
SELECT main_title, rating, nvotes
FROM Titles
WHERE nvotes > 1000 and format = 'movie'
ORDER BY rating DESC, main_title
LIMIT 10
;


-- Q4 What are the top-rating TV series and how many episodes did each have?

create or replace view Q4Sub1(title, id)
as
SELECT main_title, id
FROM Titles
WHERE (format = 'tvSeries' or format = 'tvMiniSeries') and rating = 
(SELECT max(rating)
FROM Titles
WHERE format = 'tvSeries' or format = 'tvMiniSeries')
GROUP BY id
;

create or replace view Q4Sub2(id, nepisodes)
as
SELECT q.id ,count(q.id)
FROM Q4Sub1 as q JOIN Episodes as e 
ON e.parent_id = q.id
GROUP By q.id
;

create or replace view Q4(title, nepisodes)
as
SELECT a.title , b.nepisodes
FROM Q4Sub1 as a JOIN Q4Sub2 as b
ON a.id = b.id
;


-- Q5 Which movie was released in the most languages?
create or replace view Q5Sub1(id, counter)
as
SELECT t.id, COUNT(DISTINCT a.language)
FROM Titles as t JOIN Aliases as a
ON t.id = a.title_id
WHERE t.format = 'movie'
GROUP BY t.id
;

create or replace view Q5Sub2(id, nlanguages)
as
SELECT id, counter
FROM Q5Sub1
WHERE counter = 
(SELECT MAX(counter) 
FROM Q5Sub1)
;

create or replace view Q5(title, nlanguages)
as
SELECT t.main_title, q.nlanguages
FROM Titles as t JOIN Q5Sub2 as q
ON t.id = q.id
;

-- Q6 Which actor has the highest average rating in movies that they're known for?
create or replace view Q6Sub1(name, id)
as
SELECT n.name, n.id
FROM Names as n JOIN Worked_as as w
on n.id = w.name_id
WHERE w.work_role = 'actor'
;

create or replace view Q6Sub2(name, id, rating)
as
SELECT q.name , q.id, t.rating
FROM Q6SUb1 as q JOIN Known_for as k
ON q.id = k.name_id
JOIN Titles as t
ON k.title_id = t.id
WHERE t.format = 'movie' and t.rating IS NOT null
;

create or replace view Q6Sub3(id, rating)
as
SELECT id, AVG(rating)
FROM Q6Sub2
GROUP BY id
Having COUNT(id) > 1
ORDER BY AVG(rating) DESC
;

create or replace view Q6(name)
as
SELECT q1.name
FROM Q6Sub1 as q1 JOIN Q6Sub3 as q3
ON q1.id = q3.id and q3.rating = 
(SELECT MAX(rating) 
FROM Q6Sub3)
;


-- Q7 For each movie with more than 3 genres, show the movie title and a comma-separated list of the genres


create or replace view Q7(title, genres)
as
SELECT t.main_title, STRING_AGG(distinct g.genre, ',' order by g.genre)
FROM Titles as t JOIN Title_genres as g
ON t.id = g.title_id
WHERE t.format = 'movie'
GROUP BY t.id
HAVING COUNT(distinct g.genre) > 3
;

-- Q8 Get the names of all people who had both actor and crew roles on the same movie

create or replace view Q8(name)
as
SElECT n.name
FROM NAMES as n JOIN Actor_roles as a
ON n.id = a.name_id
JOIN Titles as t 
ON a.title_id = t.id
JOIN Crew_roles as c
on t.id = c.title_id and n.id = c.name_id
WHERE t.format = 'movie'
GROUP BY n.id
;

-- Q9 Who was the youngest person to have an acting role in a movie, and how old were they when the movie started?

create or replace view Q9Sub1(id, age)
as
SELECT n.id, t.start_year - n.birth_year
FROM Names as n JOIN Actor_roles as a
ON n.id = a.name_id
JOIN Titles as t
ON a.title_id = t.id
WHERE n.birth_year IS not null and t.format = 'movie'
; 

create or replace view Q9Sub2(id,age)
as
SELECT id, MIN(age)
FROM Q9Sub1
WHERE age = (SELECT MIN(age) from Q9Sub1)
GROUP BY id
;

create or replace view Q9(name, age)
as
SELECT n.name, q.age
FROM Names as n JOIN Q9SUb2 as q
on n.id = q.id
;

-- Q10 Write a PLpgSQL function that, given part of a title, shows the full title and the total size of the cast and crew
create or replace view Q10Sub(title,title_id,name_id)
as
SELECT t.main_title, t.id, p.name_id
FROM Titles as t JOIN Principals as p
ON t.id = p.title_id
UNION
SELECT t.main_title, t.id, a.name_id
FROM Titles as t JOIN Actor_roles as a
ON t.id = a.title_id
UNION
SELECT t.main_title, t.id, c.name_id
FROM Titles as t JOIN Crew_roles as c
ON t.id = c.title_id
;

create or replace view Q10Sub5(title, num)
as
SELECT MIN(title), count(distinct name_id)
FROM Q10Sub
GROUP BY title_id
Having count(distinct name_id) > 0
;


create or replace function
	Q10(partial_title text) returns setof text
as $$
declare  r RECORD;
begin
	for r in
			SELECT * FROM Q10Sub5 
			WHERE title ilike '%' || partial_title || '%'
			ORDER BY title
		loop
			return next r.title || ' has ' || r.num || ' cast and crew';
		end loop;
	IF NOT FOUND THEN
		return next 'No matching titles';
	END IF;
end;
$$ language plpgsql;
