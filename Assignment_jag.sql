
-- IMPORTANT: BEFORE CREATING ANY TABLE, Importing the jar file
ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-hcatalog-core-1.1.0-cdh5.11.2.jar;


-- Using my created database:
use jagdishponnada;



-- CREATE EXTERNAL TABLE 
create external table if not exists nyc_taxi_data(VendorID string, tpep_pickup_datetime timestamp,
tpep_dropoff_datetime timestamp, Passenger_count int, Trip_distance double, RateCodeID int,
Store_and_fwd_flag string, PULocationID int, DOLocationID int, Payment_type int,
Fare_amount double, Extra double, MTA_tax double, Tip_amount double, Tolls_amount double,
Improvement_surcharge double, Total_amount double) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/common_folder/nyc_taxi_data/'
tblproperties ("skip.header.line.count" = '1');




---- Basic Data Quality Checks 

-- How many records has each TPEP provider provided? Write a query that summarises the number of records of each provider.?
select vendorid as TEPT_provider,count(vendorid)  as no_of_records
from nyc_taxi_data
group by vendorid
order by vendorid;

/*
tept_provider	no_of_records
 	tept_provider	no_of_records
1	1	527386
2	2	647183
*/

-- There are 647183 records for VendorID 2 and 527386 records for VendorID 1

-- 
-- if we just take the year 2017 and month of november and december 


select vendorid as TEPT_provider,count(vendorid)  as no_of_records
from nyc_taxi_data
where year(tpep_pickup_datetime) = 2017 and month(tpep_pickup_datetime) in (11,12)
group by vendorid
order by vendorid;


/* tept_provider	no_of_records
 	tept_provider	no_of_records
1	1	527386
2	2	647169
*/

-- I could see some inconsistency in the output as there are lesser number of records where year is 2017 and month is NOv and Dec 
-- This difference in record if only for vendor 2


-- •	This is the query showing that there are some entries not in the given timeframe 

select vendorid,tpep_pickup_datetime
from nyc_taxi_data
where year(tpep_pickup_datetime) != 2017 or month(tpep_pickup_datetime) not in (11,12);

/*vendorid	tpep_pickup_datetime
 	vendorid	tpep_pickup_datetime
1	2	2017-10-31 23:59:00
2	2	2017-10-31 23:59:00
3	2	2017-10-31 23:59:00
4	2	2017-10-31 11:23:00
5	2	2017-10-31 18:56:00
6	2	2017-10-31 18:33:00
7	2	2009-01-01 00:13:00
8	2	2008-12-31 10:27:00
9	2	2008-12-31 23:53:00
10	2	2003-01-01 00:58:00
11	2	2018-01-01 00:00:00
12	2	2018-01-01 00:00:00
13	2	2018-01-01 00:00:00
14	2	2018-01-01 00:04:00
*/

-- this further shows that vendor 2 have some records beyond the given time frame.



-- checking the data quality issues for each of the columns

-- 1. Vendor ID 
select distinct vendorid
from nyc_taxi_data;


/*
vendorid
 	vendorid
1	2
2	1
*/

-- There is no inconsitency in this column 
 -- 2. Pick up and drop time, As we have already checked some column where we have datetime inconsistency.We can also check if there
 -- are any rows where the drop time is early then the pickup time.


 select vendorid,tpep_pickup_datetime,tpep_dropoff_datetime
 from nyc_taxi_data
 where tpep_dropoff_datetime <tpep_pickup_datetime;
/*
 vendorid	tpep_pickup_datetime	tpep_dropoff_datetime
 	vendorid	tpep_pickup_datetime	tpep_dropoff_datetime
1	1	2017-11-05 01:58:00	2017-11-05 01:02:00
2	1	2017-11-05 01:58:00	2017-11-05 01:10:00
3	1	2017-11-05 01:27:00	2017-11-05 01:09:00
4	1	2017-11-05 01:58:00	2017-11-05 01:14:00
5	1	2017-11-05 01:45:00	2017-11-05 01:27:00
6	1	2017-11-05 01:51:00	2017-11-05 01:11:00
7	1	2017-11-05 01:49:00	2017-11-05 01:12:00
8	1	2017-11-05 01:54:00	2017-11-05 01:02:00
9	1	2017-11-05 01:58:00	2017-11-05 01:05:00
10	1	2017-11-05 01:48:00	2017-11-05 01:01:00

 
 */

-- The above is 10 of the 73 records ,All of them are from vendor 1 which are kind of erronous

 -- checking if the pickup and drop columns have any null value

 select tpep_pickup_datetime,tpep_dropoff_datetime
 from nyc_taxi_data
 where tpep_pickup_datetime = NULL or tpep_dropoff_datetime=NULL;

 -- Done. 0 results.

 -- 3.Passenger count 

 select distinct passenger_count
  from nyc_taxi_data
  order by passenger_count;

 /*
 passenger_count
 	passenger_count
1	0
2	1
3	2
4	3
5	4
6	5
7	6
8	7
9	8
10	9
*/

-- As there are some cases where the number of passengers are 0.Lets try to explore it .

select vendorid,count(*)
from nyc_taxi_data
where passenger_count = 0
group by vendorid
order by vendorid;

/*

 
 vendorid	_c1
 vendorid	_c1
1	1	6813
2	2	11
*/

-- IN this the vendor 1 is having many such rows where the number of passanger is 0 but not any of the other rows.
	

-- 4. Trip distance
select distinct trip_distance
from nyc_taxi_data
order by trip_distance;
 /*
 0.0
2	0.01
3	0.02
4	0.03
5	0.04
6	0.05
7	0.06
8	0.07
9	0.08
10	0.09
11	0.1
*/
 -- These are just 11 records out of 3192, The distance cannot be zero when the other variables are not.
 -- There are two scenario here 
 -- a. When the distance is 0 the PUlocation and drop location are different . This is erronous for sure 
 select * from nyc_taxi_data
where trip_distance=0 and pulocationid != dolocationid;

/*

ulocationid	dolocationid	trip_distance
 	pulocationid	dolocationid	trip_distance
1	90	264	0
2	264	143	0
3	264	116	0
4	264	132	0
5	209	45	0
6	264	144	0
7	107	264	0

*/

-- these are just 8 records out of 2352 which are definately erronous 

--lets see what are the payment menthod when the trip distance is zero and pickup location is same as drop location
select payment_type, count(payment_type) as cnt
from nyc_taxi_data
where trip_distance=0 and pulocationid = dolocationid
group by payment_type
order by  cnt desc;

/*
payment_type	cnt
 	payment_type	cnt
1	1	2005
2	2	1949
3	3	943
4	4	153
*/

-- All looks legit apart from the 153 entries where the method is 4(disputed)

-- Lets check the vendor and their count for the condition
select vendorid,count(vendorid)
from nyc_taxi_data
where trip_distance=0 and pulocationid != dolocationid
group by vendorid
order by vendorid;

/*
vendorid	_c1
 	vendorid	_c1
1	1	1259
2	2	1093
*/

-- vendor 1 has contributed max erronous data for this column


-- b. The other case being when total distance is zero , when both pulocation as well as dolocation are same.This could be possible
-- as the person might have cancelled the cab just after the trip starts.
select vendorid,count(vendorid)
from nyc_taxi_data
where trip_distance=0 and pulocationid = dolocationid
group by vendorid
order by vendorid;

/*
vendorid	_c1
vendorid	_c1
1	1	2958
2	2	2092
*/


-- So this might not be erronous , so lets just assume them as non erronos for now.

-- 5.Ratecodeid , Lets check if there are any inconsistencies

select distinct RatecodeID
from nyc_taxi_data
order by ratecodeid;
/*
ratecodeid
 	ratecodeid
1	1
2	2
3	3
4	4
5	5
6	6
7	99
*/
-- As can be seen here there is an entry 99 which is not expected. Lets check which vendor has contributed to it

-- The rate code id 6 is groupride lets see if we have any inconsistencies
select distinct passenger_count 
from nyc_taxi_data
where ratecodeid = 6;

/*
passenger_count
 	passenger_count
1	1
*/

 -- we have just one value (1) for a group ride which is an error. So need to remove this too.


select vendorid,count(vendorid)
from nyc_taxi_data
where ratecodeid=99
group by vendorid
order by vendorid;

/*
vendorid	_c1
 vendorid	_c1
1	1	8
2	2	1
*/

-- Even for this the max contributions of erronous data comes from vendor 1



-- 6.store_and_fwd_flag , lets check if we have any erronous data

select distinct store_and_fwd_flag
from nyc_taxi_data;

/*
store_and_fwd_flag
 	store_and_fwd_flag
1	N
2	Y

*/

-- NO surprises here, This column looks perfectly fine 

--7. pulocationid and dolocationid	--lets check if they have any null values

select count(*)
from nyc_taxi_data
where pulocationid is NULL or dolocationid is NULL;

/*

_c0
 	_c0
1	0

*/

-- There are no issues with this column and can be skipped.

--8.  payment type, lets explore it
select payment_type, count(payment_type)
from nyc_taxi_data
group by payment_type
order by payment_type;
/*
payment_type	_c1
 	payment_type	_c1
1	1	790256
2	2	376374
3	3	6274
4	4	1665
*/

-- There is no unwanted entries. We can see maximum of payment types are done by credit card.


-- 9.fare_amount lets xplore it
--lets check for any null values
select fare_amount
from nyc_taxi_data
where fare_amount is NULL;

--  Done. 0 results.

select max(fare_amount) as max_fare,min(fare_amount) as min_fare
from nyc_taxi_data;

/*
max_fare	min_fare
max_fare	min_fare
1	650 	-200

*/

-- We have some values which are negative which is not appropriate, lets see how many of them do we have 


/*
vendorid	_c1
 	vendorid	_c1
1	2	558

*/

-- This is definately erranous and can be removed.


-- 10.Extra ,lets explore it 
select extra,count(extra)
from nyc_taxi_data
group by extra;


/*
extra	_c1
 	extra	_c1
1	-10.6	1
2	-4.5	5
3	-1	87
4	-0.5	193
5	0	631872
6	0.3	36
7	0.5	363455
8	1	174386
9	1.5	2
10	2	1
11	4.5	4502
12	4.8	1
13	0.8	15
14	1.3	13
*/

-- There are many values which are erronous(not 0.5 or 1)
--lets see how many of them are erronous

select vendorid,count(vendorid)
from nyc_taxi_data
where extra not in (0,0.5,1)
group by vendorid;

/*
vendorid	_c1
 	vendorid	_c1
1	1	1823
2	2	3033
*/

-- These are the erronous values and should be removed

--11. MTA_tax - lets explore it 


select mta_tax,count(mta_tax)
from nyc_taxi_data
group by mta_tax;

/*
mta_tax	_c1
 	mta_tax	_c1
1	-0.5	544
2	0	5197
3	0.5	1168824
4	3	3
5	11.4	1
*/

-- The valid values are 0 or 0.5 hence the remaining are erronous


select vendorid,count(vendorid)
from nyc_taxi_data
where mta_tax not in (0,0.5)
group by vendorid
order by vendorid ;
/*
vendorid	_c1
 	vendorid	_c1
1	1	1
2	2	547
*/






-- Vendor 2 in this case has provided max erronous data

-- 12. tip_amount
select max(tip_amount), min(tip_amount)
from nyc_taxi_data;
/*
_c0	_c1
 	_c0	_c1
1	450	-1.16
*/
-- the negative value is erranous so can be removed

select payment_type,count(payment_type)
from nyc_taxi_data
where tip_amount >0
group by payment_type;
/*
payment_type	_c1
 	payment_type	_c1
1	4	5
2	1	756713
3	3	12

*/

-- all looks good here

-- 13.tolls amount 
-- lets explore it 


select min(tolls_amount)
from nyc_taxi_data; 



/*
_c0
 	_c0
1	-5.76
*/

-- So even this has negative values , lets check what the total amount and fare amount is for this entry
select fare_amount,tolls_amount, total_amount
from nyc_taxi_data
where tolls_amount <0;
/*
fare_amount	tolls_amount	total_amount
 	fare_amount	tolls_amount	total_amount
1	-52	-5.76	-58.56
2	-52	-5.76	-58.56
3	-52	-5.76	-58.56
*/

-- this whole row will be deleted anyway as part of fare amount cleanup

-- 14.improvement_surcharge

select improvement_surcharge, count(improvement_surcharge)
from nyc_taxi_data
group by improvement_surcharge
order by improvement_surcharge;

/*
improvement_surcharge	_c1
 	improvement_surcharge	_c1
1	-0.3	558
2	0	287
3	0.3	1173720
4	1	4
*/

-- the values corresponding to -0.3 and 1 are erronous. They add upto 562 rows which can be excluded.

select vendorid,count(vendorid)
from nyc_taxi_data
where improvement_surcharge not in (0,0.3)
group by vendorid
order by vendorid;

/*
vendorid	_c1
 	vendorid	_c1
1	2	562

*/

-- Here all the entries whic are erronous are provided by vendor 2

-- 15 . Total amount

select min(total_amount)
from nyc_taxi_data; 

/*
_c0
 	_c0
1	-200.8
*/

-- The values below zero are invalid so they need to be removed
select vendorid,count(vendorid)
from nyc_taxi_data
where total_amount < 0
group by vendorid;

/*
vendorid	_c1
 	vendorid	_c1
1	2	558
*/

-- All the entries were from vendor 2.


-- Lets find the vendor who has given more erronous data as a whole

select VendorID ,count(vendorid) as cnt_vendorid
from nyc_taxi_data
where (year(tpep_pickup_datetime)!=2017 or  month(tpep_pickup_datetime) not in (11,12))
or  tpep_pickup_datetime > tpep_dropoff_datetime
or (trip_distance <0 or (trip_distance ==0 and pulocationid != dolocationid))
or (fare_amount <0 or (fare_amount =0 and pulocationid!=dolocationid))
or mta_tax not in (0,0.5)
or improvement_surcharge not in (0, 0.3)
or ratecodeid  in (6,99)
or  extra not in (0,0.5,1)
or passenger_count=0
group by vendorid;


/*

 	vendorid	cnt_vendorid
1	1			9999
2	2			4399

*/

-- Vendor 1 has provided more erronous data as compared to vendor 2.


-----------------------------------------------------------------------------------------------------------
--********************************************************************************************************
--********************************************************************************************************
-----------------------------------------------------------------------------------------------------------


--Lets prepare the final table based on our analysis 'nyc_cleaned'

create table nyc_cleaned
like nyc_taxi_data;


insert overwrite table nyc_cleaned
select VendorID , tpep_pickup_datetime ,tpep_dropoff_datetime , Passenger_count , Trip_distance , RateCodeID ,
Store_and_fwd_flag , PULocationID , DOLocationID , Payment_type ,Fare_amount , Extra , MTA_tax , Tip_amount , Tolls_amount ,
Improvement_surcharge , Total_amount 
from nyc_taxi_data
where year(tpep_pickup_datetime)=2017
and month(tpep_pickup_datetime) in (11,12)
and tpep_pickup_datetime < tpep_dropoff_datetime
and (trip_distance >0 or (trip_distance ==0 and pulocationid = dolocationid))
and (fare_amount >0 or (fare_amount =0 and pulocationid=dolocationid))
and mta_tax in (0,0.5)
and improvement_surcharge in (0, 0.3)
and ratecodeid not in (6,99)
and  extra in (0,0.5,1)
and passenger_count!=0;



-- We have not used the filter conditions for total_amount, tip_amount, tolls_amount as using the above filters are successfully
-- removed the unwanted rows in the table which were error in the above mentioned columns.





--------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


-- Lets partion the table as per our requirement 

-- IMPORTANT:Setting these parameters are very important .
SET hive.exec.max.dynamic.partitions=100000;
SET hive.exec.max.dynamic.partitions.pernode=100000;

--creating an external partitioned table 

create external table if not exists nyc_taxi_partitioned
(VendorID string, tpep_pickup_datetime timestamp,
tpep_dropoff_datetime timestamp, Passenger_count int, Trip_distance double, RateCodeID int,
Store_and_fwd_flag string, PULocationID int, DOLocationID int, Payment_type int,
Fare_amount double, Extra double, MTA_tax double, Tip_amount double, Tolls_amount double,
Improvement_surcharge double, Total_amount double) partitioned by (year int, month int)
location '/user/hive/warehouse/jagdish/nyc_partition';


-- Then insert the data in the table 
insert overwrite table nyc_taxi_partitioned
select VendorID , tpep_pickup_datetime ,tpep_dropoff_datetime , Passenger_count , Trip_distance , RateCodeID ,
Store_and_fwd_flag , PULocationID , DOLocationID , Payment_type ,Fare_amount , Extra , MTA_tax , Tip_amount , Tolls_amount ,
Improvement_surcharge , Total_amount , year(tpep_pickup_datetime) as year, month(tpep_pickup_datetime) as month 
from nyc_cleaned;


-----------------------------------------------------------
--creating an ORC table 
create external table if not exists nyc_taxi_ORC
(VendorID string, tpep_pickup_datetime timestamp,
tpep_dropoff_datetime timestamp, Passenger_count int, Trip_distance double, RateCodeID int,
Store_and_fwd_flag string, PULocationID int, DOLocationID int, Payment_type int,
Fare_amount double, Extra double, MTA_tax double, Tip_amount double, Tolls_amount double,
Improvement_surcharge double, Total_amount double) partitioned by (year int, month int)
stored as orc location '/user/hive/warehouse/jagdish/nyc_ORC'
tblproperties ("orc.compress"="SNAPPY");

insert overwrite table nyc_taxi_ORC partition(year , month)
select * from nyc_taxi_partitioned;





----------------------------------------------------------------------------
--##########################################################################
--================================ ANALYSIS - 1
--###########################################################################
-----------------------------------------------------------------------------


----------------------------------------------------------------------------
--1. Compare the overall average fare per trip for November and December.
-----------------------------------------------------------------------------

select month,avg(fare_amount) as avg_fare_month	
from nyc_taxi_ORC
group by month
order by month;


/*
 	month	avg_fare_month
1	11		12.916952298737844
2	12		12.71329594575406

*/
-- Difference is .204
-- The average fare amount per trip is almost same for both the months. Average cost is slightly higher in November as compared to december


----------------------------------------------------------------------------
--2. Explore the ‘number of passengers per trip’ - how many trips are made by 
--   each level of ‘Passenger_count’? Do most people travel solo or with other people?
-----------------------------------------------------------------------------

select passenger_count , count(passenger_count) as trips_passngr_number
from nyc_taxi_ORC
group by passenger_count
order by passenger_count;

/*
passenger_count	trips_passngr_number
 	
1	1				818716
2	2				175037
3	3				50240
4	4				24719
5	5				54073
6	6				32902
7	7				4
8	8				2

*/


-- We can infer here that people prefer to travel solo as compared to in groups. After solo people prefer to travel in group of two.



----------------------------------------------------------------------------
--3. Which is the most preferred mode of payment?
-----------------------------------------------------------------------------

select payment_type, count(payment_type) as cnt_payment
from nyc_taxi_ORC
group by payment_type
order by payment_type;


/*

 	payment_type	cnt_payment
1	1				779881
2	2				369562
3	3				4878
4	4				1372

*/

-- Credit card ( payment type 1) is the most preferred payment method. 

----------------------------------------------------------------------------
--4. What is the average tip paid per trip? Compare the average tip with the 25th, 50th and 75th percentiles and comment whether
-- the ‘average tip’ is a representative statistic (of the central tendency) of ‘tip amount paid’. 
--Hint: You may use percentile_approx(DOUBLE col, p): Returns an approximate pth percentile of a numeric column 
--(including floating point types) in the group.
-----------------------------------------------------------------------------

select avg(tip_amount) as avg, percentile_approx(`tip_amount`, (0.25)) as Q1, percentile_approx(`tip_amount`, (0.50)) as Q2,
percentile_approx(`tip_amount`, (0.75)) as Q3 
from nyc_taxi_ORC;

/*

 	avg					q1			q2			q3
1	1.8272853344265532	0	1.3585091145833335	2.45

*/

-- The average tip paid per tip is 1.83 . The median of the tip amount distribution is 1.35, So the average is not representative 
-- enough of the tip amount distribution.

select  percentile_approx(`tip_amount`, (0.61)) as percentile
from nyc_taxi_ORC;

/*

 	percentile
1	1.8449296748961135
*/

--Average tip is approximately equal to 61 the percentile of tip amount


----------------------------------------------------------------------------
--5. Explore the ‘Extra’ (charge) variable - what fraction of total trips have an extra charge is levied?
-----------------------------------------------------------------------------

SELECT extra, count(extra)
FROM nyc_taxi_orc
group by extra
ORDER BY extra;

/*
 
 	extra	no_of_trips
1	0	 		622758
2	0.5			360217
3	1			172718
*/

-- We can infer that majority of the trips are in day time and in non rush hours.

-- Lets get the fraction of trips having extra charge levied
SELECT round(sum(frac)*100,2) as fraction_non_zero_Extra from (
select extra,t/sum(t) over() as frac from (
SELECT extra, count(extra) as t 
FROM nyc_taxi_orc
group by extra) temp)new_temp
where extra != 0;

/*

 	fraction_non_zero_extra
1	46.11
*/


----------------------------------------------------------------------------
--##########################################################################
--================================ ANALYSIS - 2
--###########################################################################
-----------------------------------------------------------------------------



----------------------------------------------------------------------------
--1. What is the correlation between the number of passengers on any given trip, and the tip paid per trip?
-- Do multiple travellers tip more compared to solo travellers? Hint: Use CORR(Col_1, Col_2)
-----------------------------------------------------------------------------

select corr(tip_amount,passenger_count) as correlation
from nyc_taxi_ORC;

/*

 	correlation
1	-0.005158004856875417

*/

-- There is hardly any correlation between tip amount and the passenger count.

----------------------------------------------------------------------------
--2. Segregate the data into five segments of ‘tip paid’: [0-5), [5-10), [10-15) , [15-20) and >=20. 
--Calculate the percentage share of each bucket (i.e. the fraction of trips falling in each bucket).
-----------------------------------------------------------------------------
	

select category, round(count_per_category/sum(count_per_category) over(),2) as fraction_per_category from (
select category, count(category) as count_per_category from(
select tip_amount ,
case
    when tip_amount between 0 and 4.99 then 'Tip_1_5'
    when tip_amount between 5 and 9.99 then 'Tip_5_10'
    when tip_amount between 10 and 14.99 then 'Tip_10_15'
    when tip_amount between 15 and 19.99 then 'Tip_15_20'
    when tip_amount >=20 then 'Tip>20'
END as `category`
from nyc_taxi_orc
) temp 
group by category) temp_1
order by fraction_per_category desc ;

/*

 	category	fraction_per_category
1	Tip_1_5				0.92
2	Tip_5_10			0.06
3	Tip_10_15			0.02
4	Tip>20				0
5	Tip_15_20			0

*/

-- % share of 0 to 5 bin : 92 %
-- % share of 5 to 10 bin : 6 %
-- % share of 10 to 15 bin : 2 % 
-- % share of 15 to 20 bin: 0 %
-- % share of greater than 20 bin : 0 %


----------------------------------------------------------------------------
--3. Which month has a greater average ‘speed’ - November or December? 
--Note that the variable ‘speed’ will have to be derived from other metrics. Hint: You have columns for distance and time.
-----------------------------------------------------------------------------

-- we had few entries in our trip distance which were 0 and i found it non erronous because the pulocationid as well as dolocationid
-- were same. We assumed this trips were valid and may be cancelled just after boarding. 

-- FOr the speed computation lets ignore them.


select month,round(avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime) ) /(60 * 60 ))),2) as avg_speed_miles_hour from 
(
select *
from nyc_taxi_ORC
where trip_distance!=0 ) temp
group by month;


/*


 	month	avg_speed_miles_hour
1	11		10.97
2	12		11.07

*/

-- As observed, december has higher average speed as compared to November.






----------------------------------------------------------------------------
--5. Analyse the average speed of the most happening days of the year,
-- i.e. 31st December (New year’s eve) and 25th December (Christmas) and compare it with the overall average. 
-----------------------------------------------------------------------------

-- Overall average speed 

select round(avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime) ) /(60 * 60 ))),2) as ovrall_avg_speed_miles_hr from 
(
select *
from nyc_taxi_ORC
where trip_distance!=0 ) temp
 ;


/*
ovrall_avg_speed_miles_hr
 	ovrall_avg_speed_miles_hr
1	11.02
*/

-- The overall average is 11.02 miles per hour

-- Average speed on 25th and 31st December
select day(tpep_pickup_datetime) as imp_day ,round(avg(trip_distance/((unix_timestamp(tpep_dropoff_datetime) - unix_timestamp(tpep_pickup_datetime) ) /(60 * 60 ))),2) as avg_speed_miles_hour from 
(
select *
from nyc_taxi_ORC
where trip_distance!=0 ) temp
where month=12 and day(tpep_pickup_datetime) in (25,31) 
group by day(tpep_pickup_datetime) ;


/*

 	imp_day	avg_speed_miles_hour
1	25			15.27
2	31			13.25
*/

-- The average speed is higher in 25th december as compared to december 31st. But When compared the overall speed it is much higher. 
-- So average speed on special days are higher than the normal days.