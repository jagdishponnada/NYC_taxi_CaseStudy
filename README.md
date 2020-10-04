# New York City Taxi Limousine Commission Analysis 


## Background
The New York City Taxi & Limousine Commission (TLC) has provided a dataset of trips made by the taxis in the New York City. The detailed trip-level data is more than just a vast list of taxi pickup and drop-off coordinates. 

The records include fields capturing pick-up and drop-off dates/times, pick-up and drop-off locations (location coordinates of the starting and ending points), trip distances, itemized fares, rate types, payment types, driver-reported passenger counts etc. The data used was collected and provided to the NYC Taxi and Limousine Commission (TLC) by technology providers authorized under the Taxicab & Livery Passenger Enhancement Programs (TPEP/LPEP).

In this assignment, we ONLY consider the data of yellow taxis for November and December of the year 2017.

## Objective
The purpose of this analysis is to get a better understanding of the taxi system so that the city of New York can improve the efficiency of in-city commutes. Several exploratory insights were generated about the travelling experience for passengers.

## Key methods 
- HiveQL was used in this analysis as the data was in HDFS.
- External Tables/ ORC tables were created
- Pationining was used in tables.

## Insights 
- The average fare amount per trip is almost same for both the months(November and Decemver). 
- People prefer to travel solo as compared to in groups. After solo people prefer to travel in group of two.
- Credit card(payment type 1) is the most preferred payment method.
- The average tip paid per trip is 1.83
- Majority of the trips are in day time and in non rush hours.
- December has higher average speed as compared to November
- The average speed is higher in 25th december as compared to december 31st. But When compared the overall speed it is much higher.So average speed on special days are higher than the normal days.


