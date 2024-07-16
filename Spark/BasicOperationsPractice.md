# Basic Operations
## Flights Dataset

1.	Reading the Dataset
    - Use Spark to read the dataset
    - Display the schema to understand the structure of the data.
2.	Basic Data Inspection
    - Show the first few rows of the dataset
    - Count the total number of rows in the dataset.
3.	Selecting Columns
    - Use Spark to select specific columns (date, origin, and destination) and display them.
4.	Filtering Data
    - Filter the dataset for flights from a specific airport or to a particular destination.
5.	Column Operations
    - Create a new column that categorizes flights as follows:
    - Under 15 minutes late or early: On-time
    - Over 15 minutes early: Early
    - Over 15 minutes late: Delayed
    - Over 2 hours late: Major Delay
6.	Sorting Data
    - Sort the data by departure time or delay duration
7.	Aggregations
    - Get the total distance flown in the dataset
    - Get the total number of flights to each destination
    - Calculate the average delay for each destination
8.	Date Manipulation
    - Add the year (2014) as a new column
    - Extract the day, month, and time  from the date column
9.	Simple Join Operation
    - Join the airport-codes-na.txt dataset to enrich the flights data with additional information.
