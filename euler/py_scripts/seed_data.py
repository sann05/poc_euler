import os.path
from datetime import datetime, tzinfo, timezone

from euler.py_scripts.common import conf
import pandas as pd

from euler.py_scripts.common.helper import write_df, get_project_path


def main():
    tables = [*conf.ADS_LOCAL_TABLES.values(), conf.PRODUCT_MASTER_TABLE]
    project_root_path = get_project_path()
    for table in tables:
        path = os.path.join(project_root_path, f"data/{table}.csv")
        df = pd.read_csv(path)
        if "updated_date" in df.columns:
            df["updated_date"] = datetime.now(tz=timezone.utc)
        print(f"Seeding {table}")
        write_df(df, table)


if __name__ == '__main__':
    main()
