import os.path
from datetime import datetime, timezone

import pandas as pd

from euler.py_scripts.common import conf
from euler.py_scripts.common.helper import write_df, get_project_path, \
    recreate_tables


def main():
    tables = [ conf.PRODUCT_MASTER_TABLE, *conf.ADS_LOCAL_TABLES.values()]
    project_root_path = get_project_path()
    recreate_tables()
    for table in tables:
        path = os.path.join(project_root_path, f"data/{table}.csv")
        df = pd.read_csv(path)
        if "updated_date" in df.columns:
            df["updated_date"] = datetime.now(tz=timezone.utc)
        if "id" in df.columns:
            df.drop("id", axis=1, inplace=True)
        print(f"Seeding {table}")
        write_df(df, table)


if __name__ == '__main__':
    main()
