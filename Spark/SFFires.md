# San Fransico Fires Dataset

This exercise aims to utilize Apache Spark for an analysis of the sf-fire-incidents and sf-fire-calls datasets. The focus is on extracting valuable insights into the nature and frequency of fire incidents and emergency responses in San Francisco, with an emphasis on optimizing response strategies and enhancing public safety.

### Data Sources:
- `/databricks-datasets/learning-spark-v2/sf-fire/`
    - SF-Fire-Incidents Dataset: Provides detailed records of fire incidents, including type, location, and outcomes.
    - SF-Fire-Calls Dataset: Includes details of emergency fire calls, with information on response times and nature of the calls.

### Analysis
1.	**Trend Analysis of Incidents and Calls:** Investigate historical data to understand patterns and trends in fire incidents over time.
2.	**Response Time Analysis:** Detailed examination of response times to identify areas for efficiency improvement and to understand the factors impacting response speeds.
3.	**Comparative Analysis:** Analyze data across different neighborhoods or districts to understand patterns and trends in where incidents occur.
4.	**Top 10 Incident Analysis:** Create a summary report of the 10 most severe fires in the dataset.
5.	**Complex Analysis:** Combine data from both datasets to perform an analysis on the relationship between calls and incidents. Feel free to explore whatever interests you most.

### Additional Tasks
1.	Partition the Data: Determine an optimal partitioning schema to break the dataset into 128MB files and save them to DBFS.

**Tip: Use `display(df)` to get a formatted table output for dataframes with many columns. (Hit the + icon to create visualizations).**
