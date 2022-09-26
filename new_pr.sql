SELECT * FROM project.d2;
select * from project.d1;
-- Number of rows into our dataset
select count(*) from project.d1;
select count(*) from project.d2;

-- Dataset for uttar pradesh and bihar
select * from project.d1 
where state in ('Uttar pradesh','Bihar'); 

-- Population of India
select sum(population) population from project.d1;

select count(population) population from project.d1;

select column_name, data_type from information_schema.columns where table_schema = 'project' and table_name= 'd1';

select distinct count(District) 'No. Of District', sum(population) 'Total Population' from project.d1;
select distinct count(state) 'Total State' from project.d2;

-- Avg growth rate of the state
select state,round(avg(growth)*100,2) avg_growth from project.d2 group by state;
-- Avg sex ratio of the state
select state,round(avg(sex_ratio)*100,0) avg_sex_ratio from project.d2 group by state order by avg_sex_ratio desc;
-- Avg litracy rate of the state
select state,round(avg(Literacy),0) avg_literacy_rate from project.d2 group by state order by avg_literacy_rate desc;
-- Literacy rate greate than 90
select state,round(avg(Literacy),0) avg_literacy_rate from project.d2
 group by state having avg_literacy_rate > 90 order by avg_literacy_rate desc; 
 -- Top 3 state
 select state,round(avg(growth)*100,2) avg_growth from project.d2 group by state order by avg_growth limit 3 ;
-- top 3 state showing highest literacy rate
select state,round(avg(Literacy),0) avg_literacy_rate from project.d2 group by state order by avg_literacy_rate desc limit 3;
-- Bottom 3 state showing lowest literacy rate
select state,round(avg(Literacy),0) avg_literacy_rate from project.d2 group by state order by avg_literacy_rate asc limit 3;

-- top and bottom state showing sex ratio

drop table if exists topstates;
Create table topstates
( state nvarchar(255),
    topstate float
);

insert into topstates(select state, round(avg(sex_ratio),0) avg_sex_ratio from project.d2
group by state order by avg_sex_ratio);

select * from topstates order by topstates.topstate desc limit 3;

drop table if exists bottomstates;
Create table bottomstates
( state nvarchar(255),
    bottomstate float
);

insert into bottomstates(select state, round(avg(sex_ratio),0) avg_sex_ratio from project.d2
group by state order by avg_sex_ratio desc);

select * from bottomstates order by bottomstates.bottomstate asc limit 3;

-- Combining two result by union operator

select * from(
select * from topstates order by topstates.topstate desc limit 3 ) a 
union
select * from(
select * from bottomstates order by bottomstates.bottomstate asc limit 3 ) b;

-- states starter with letter a 
select distinct state from project.d2 where lower(state) like 'a%' or lower(state) like '%u';

select cast(a.population as unsigned) from
(select concat(population) population,district from project.d1) a;




-- Join both columns

-- inner join
select a.district,a.state,a.literacy,b.population from project.d2 a inner join project.d1 b on a.district=b.district;
select count(a.district) from project.d2 a inner join project.d1 b on a.district=b.district;
-- left join
select a.district,a.state,a.literacy,b.population from project.d2 a left join project.d1 b on a.district=b.district;
select distinct count(a.district) from project.d2 a left join project.d1 b on a.district=b.district;
-- right join
select a.district,a.state,a.literacy,b.population from project.d2 a right join project.d1 b on a.district=b.district;
select distinct (a.district) from project.d2 a right join project.d1 b on a.district=b.district;
-- CROSS join
select a.district,a.state,a.literacy,b.population from project.d2 a CROSS JOIN project.d1 b on a.district=b.district;
select distinct count(a.district) from project.d2 a cross join project.d1 b on a.district=b.district;

-- Total Number of male and female

select d.state, sum(d.males) Total_males, sum(d.females) Total_female from
(select c.district,c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.District, a.state, a.sex_ratio/1000 sex_ratio, b.population from project.d2 a inner join project.d1 b on a.district=b.district) c) d
group by state order by state asc;

-- Literacy Population

select d.state,sum(d.literate_per) Total_literate_per, sum(d.illiterate_per) Total_illeterate_per from
(select c.district, c.state, round((c.literacy_rate*c.population),0) literate_per, round((1-c.literacy_rate)*c.population,0) illiterate_per, c.population from
(select a.district, a.state, a.literacy/100 literacy_rate, b.population from project.d2 a inner join project.d1 b on a.district=b.district) c) d
group by d.state order by d.state asc;

-- previou_census

select d.state, sum(d.previous_pop) Total_prev_pop, sum(current_pop) Total_curr_pop from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_pop, c.population current_pop from 
(select a.district, a.state, a.growth/100 growth, b.population from project.d2 a inner join project.d1 b on a.district=b.district) c) d
group by d.state order by d.state asc;

-- per squre km pop

select ( g.total_area/g.prev_census_pop) as prev_census_pop, (g.total_area/g.curr_census_pop) as curr_census_pop from
(select m.*, r.total_area from
(select '1' as keyy,f.* from 
(select sum(e.Total_prev_pop) prev_census_pop, sum(Total_curr_pop) curr_census_pop from
(select d.state, sum(d.previous_pop) Total_prev_pop, sum(current_pop) Total_curr_pop from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_pop, c.population current_pop from 
(select a.district, a.state, a.growth/100 growth, b.population from project.d2 a inner join project.d1 b on a.district=b.district) c) d
group by d.state)e)f ) m inner join (

select '1' as keyy, z.* from (
select sum(area_km2) total_area from project.d1 ) z ) r on m.keyy=r.keyy)g;

-- window function

-- Top 3 literacy rate district in each state
select a.* from
(select district, state, Literacy, rank() over(partition by state order by literacy desc) rnk from project.d2) a
where a.rnk in (1,2,3) order by state;

-- Top 3 sex ratio district in each state

select a.* from
(select district, state, sex_ratio, rank() over(partition by state order by sex_ratio desc) rnk from project.d2) a
where a.rnk in (1,2,3) order by state;

-- Top 3 growth district in each state

select a.* from
(select district, state, Growth, rank() over(partition by state order by growth desc) rnk from project.d2) a
where a.rnk in (1,2,3) order by state;
