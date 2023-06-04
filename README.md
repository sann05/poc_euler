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