# poc_euler

### Prerequisites

1. Install all libraries listed in [requirements.txt](requirements.txt) via command 
    <br> ```pip install -r requirements.txt```
2. Add Redshift credentials to
`REDSHIFT_LOGIN` and `REDSHIFT_PASSWORD` environment variables


### Project structure 
```commandline
├── data # folder for data seeding
│   ├── ads_online.csv
│   ├── ads_uk.csv
│   ├── ads_us.csv
│   └── product_master.csv
├── py_scripts
│   ├── __init__.py
│   ├── common # helper python scritps 
│   │   ├── __init__.py
│   │   ├── conf.py # configuration
│   │   └── helper.py 
│   ├── run_daily.py # The script for running daily job
│   └── seed_data.py # Refreshes and seed all data in the DWH
└── sql_queries
    ├── recreate_tables.sql
    ├── scheduled # scripts that are running in the daily job
    │   ├── delete_rows.sql
    │   ├── insert_rows.sql
    │   ├── product_added.sql
    │   └── update_rows.sql
    ├── tests # scripts that manipulate data for testing
    │   ├── 0_scenario_base.sql
    │   ├── 1_scenario_insertion.sql
    │   ├── 2_scenario_deletion.sql
    │   ├── 3_scenario_updation.sql
    │   ├── 4_product_add.sql
    │   └── 5_scenario_mixed.sql
    └── validation # script for displaying current relationship between tables 
        └── show_relation.sql

```

### How to run

 - Each time you want a fresh start run the [seed_data.py](euler%2Fpy_scripts%2Fseed_data.py) script (seed data fulfill only `product_master` and local `ads_*` tables)
 - When you want seeded data be uploaded to `ads_combined` and `ads_order_mapping` tables run [run_daily.py](euler%2Fpy_scripts%2Frun_daily.py) script
 - To see changes in convenient way you may use [show_relation.sql](euler%2Fsql_queries%2Fvalidation%2Fshow_relation.sql) script
 - In order to run any test execute its content in any DB client connect to the Redshift instance and the run [run_daily.py](euler%2Fpy_scripts%2Frun_daily.py) script

### FAQ

> What will happen if query execution is stopped due to the termination of the Redshift cluster of whatever?

The daily_job.py works that way in that it commits all made changes only at the very end of the execution,
so in case something fails or terminates in the middle of execution, changes will not take effect, and you'll be safe 
to execute it the next day or whatever period 

> Why this is better than materialized view solution?

Because in the materialized view solution you recalculate all historical data despite of if it was changed or not. 
This solution split updates into the 3 parts: 

1. reduce the number of calculated rows to the one that needs to be changed
2. split the whole process into four stages: changes related to product addition, new ads insertion, old ads update, ads deletion
3. each locality (online, us, uk) has its own pipeline

So that way we keep affected resources in the smallest batches possible and we are able to control their execution whatever we want.

> Are there any other options than this solution?

This solution is the easiest and most effective way to eliminate current performance issues, but this probably can't work forever. 

The most durable solution will be to create a streaming application that will send so-called "micro-batches" in the form of CDC (change data capture). Basically, this streaming application can get all the smallest data changes(like the row with id X from table Y was added) and understand where to make the required changes.

The benefits of the solution are: 
 - it's incredibly effective and can eliminate performance issues forever
 - new changes are visible in real-time

But there are significant drawbacks:
 - It requires a complete understanding of the data flows 
 - The development is much more time-consuming than the first solution
 - It requires constant support