# Memory Management Excercises


## 1
ACME Inc is estimating whether their current spark cluster will be able to handle a new ETL process. They have a number of databases for their retails stores across the world. The total dataset is 4.2TB. They are running a spark cluster with the following configurations:
-	Driver Node 
    -	Same as worker
-	Worker Nodes 
    -	14 nodes
    -	Worker Type: Standard_DS13_v2
        -	156 GB mem
        -	8 cores


Given that each task slot has a single core, will this spark cluster be optimal for the workload? If not, how would you scale it?


Break down the memory allocation of the spark cluster
-	Node manager resources
-	Container resources
    -	Overhead memory
    -	Heap
        -	Execution/Storage memory
        -	User memory
        -	Reserved memory
-	Total storage memory in the cluster
-	Number of tasks per slot

How would the breakdown change if the Driver program were running on one of the worker nodes instead of within it's own node?