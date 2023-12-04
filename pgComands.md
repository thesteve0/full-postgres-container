Commands to use in the PostgreSQL talk

We are going to use the superuser (postgres) account today. DO NOT DO THIS FOR DAY IN AND DAY OUT WORK

### JSON
```postgresql
psql workshop

\d natural_events

# Put syntax here

--return text
select json_content #>> '{title' from natural_events limit 1;

--return json object
select json_content #> '{title}' from natural_events limit 1;

--get some categories
select json_content #>> '{"categories",0,"title"}' from natural_events limit 10;

--get the distinct list of categories
select distinct(json_content #>> '{"categories",0,"title"}') from natural_events;

--only return data for events in the volcano category
select json_content from natural_events where (json_content #> '{"categories",0}') @> '{"title":"Volcanoes"}' limit 5;

--get counts for categories
select json_content #>> '{"categories",0,"title"}' as title, count(id) from natural_events GROUP BY json_content #>> '{"categories",0,"title"}';

--change "severe storms" to "bad weather"
UPDATE natural_events SET json_content = jsonb_set(json_content, '{"categories",0,"title"}', '"Bad Weather"') where (json_content #> '{"categories",0}') @> '{"title":"Severe Storms"}';
```

---

### Full Text

```postgresql

\d se_details

--Steps to builld the FT index
-- https://www.postgresql.org/docs/current/textsearch-intro.html
-- text to tokens
-- tokens to lexemes
-- analysis and indexing of lexemes

--build the full text index
CREATE INDEX se_details_fulltext_idx ON se_details USING GIN (to_tsvector('english', event_narrative));

-- search parser
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('villag');

-- stemming
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('english', 'villa:*');

-- word proximity that doesn't provide expected results
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('grapefruit <1> hail');

-- gives expected results
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('grapefruit <2> hail');

-- order matters
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('hail <2> grapefruit');

-- compound text query
select begin_date_time, event_narrative from se_details where to_tsvector('english', event_narrative) @@ to_tsquery('(grapefruit | golf:* ) <2> hail');
```

---

### PostGIS

```postgresql

-- required to load the extension
-- CREATE EXTENSION postgis;

\d county_geometry

-- find 3 closest counties, ineffcient
SELECT id, county_name, ST_Distance('POINT(-103.771555 44.967244)'::geography, the_geom) FROM county_geometry ORDER BY ST_Distance('POINT(-103.771555 44.967244)'::geography, the_geom) LIMIT 3;

-- Find 3 closest efficient

SELECT id, county_name, ST_Distance('POINT(-103.771555 44.967244)'::geography, the_geom) FROM county_geometry ORDER BY the_geom <-> 'POINT(-103.771555 44.967244)'::geography LIMIT 3;

-- spatial join
select geo.statefp, geo.county_name, geo.aland, se.event_id, se.location from county_geometry as geo, se_locations as se where ST_Covers(geo.the_geom, se.the_geom) limit 10;

-- buffer then select - first CTE
)
select statefp, county_name, count(*) from all_counties group by statefp, county_name order by statefp, count(*) DESC;

-- then full query
with all_counties as (
    select geo.statefp, geo.county_name, se.locationid from county_geometry as geo, se_locations as se where ST_intersects(geo.the_geom, ST_Buffer(se.the_geom, 12500.0)) limit 200
)
select statefp, county_name, count(*) from all_counties group by statefp, county_name order by statefp, count(*) DESC;


```

---

### PL/Python

```postgresql

-- load extension
CREATE EXTENSION plpython3u;

-- add plython as an untrusted language
UPDATE pg_language SET lanpltrusted = true WHERE lanname LIKE 'plpython3u';

-- creaste function
CREATE OR REPLACE FUNCTION two_power_three ()
    RETURNS VARCHAR
AS $$
    result = 2**3
    return f'Hello! 2 to the power of 3 is {result}.'
$$ LANGUAGE 'plpython3u';

-- call the function
SELECT two_power_three ();

-- use standard library
CREATE OR REPLACE FUNCTION test_rand (low int, high int)
    RETURNS INT
AS $$
    import random
    number = random.randint(low, high)
    return number
$$ LANGUAGE 'plpython3u';

-- call the function
SELECT test_rand(5, 1510);

-- steps to add numpy to our postgres - not in image
\q

in the shell
pip3 install numpy

log back in 

psql workshop

-- now back in postgres
CREATE OR REPLACE FUNCTION testnp () RETURNS int[][] 
    AS $$ 
        import numpy as np 
        a = np.arange(15).reshape(3, 5).tolist()
        return a 
    $$ LANGUAGE 'plpython3u';

-- use the function
SELECT testnp();

```
---

### pgvector

https://github.com/pgvector/pgvector
https://medium.com/@rubyabdullah14/using-pgvector-to-supercharge-vector-operations-in-postgresql-a-python-guide-d048497464da

