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

## Breakdown
<details>
    <summary>expand/collapse</summary>

- Per node:
    - 155 GB; 7 Cores
        - 156 GB; 8 Cores
        - Node Manager = 1 Core; 1 GB

    <details>
    <summary> Executor Memory</summary>

    Cores do not split evenly so we will use 1 Executor per Node

    - Per Executor:
        - 155 GB; 7 Cores
    - Memory Breakdown:
        - 155 GB * .10 = 15.5 GB for Offheap Overhead
    - Heap:
        - 139.5 GB
        - 75% = ~104.63 GB
        - Storage Memory = ~52.31 GB
        - Execution Memory = ~52.31 GB
        - Heap Overhead = ~ 300 MB
        - User Memory = ~34.58 GB
    - Per Core:
        - 52.31 GB / 7 Cores = ~7.47 GB per Core
        - 2 – 4 Tasks per Slot  = 3.74 GB – 1.87 GB per Partition
    </details>

    
    <details>
    <summary>Total Execution Memory for our Cluster</summary>
    
    - Total Execution memory for Cluster:
        - 7 Cores/Node * 14 Nodes * 2 Tasks/Core * 3.74 GB Memory = ~733 GB We can comfortably transform in Memory
    - In order to Transform Entire 4.2 TB Dataset we would need to scale out to ~80 Nodes on this cluster
    </details>

    <details>
    <summary>Driver running on worker</summary>
    
    - Total Execution memory for Cluster:
        - ((7 Cores/Node * 14 Nodes) - 7 Cores) * 2 Tasks/Core * 3.74 GB Memory = ~680 GB We can comfortably transform in Memory
    - In order to Transform Entire 4.2 TB Dataset we would need to scale out to ~81 Nodes on this cluster
        - Note: with one Executor per node our numbers do not really change, we just lose one of our worker nodes
    </details>



</details>
    

