from datetime import datetime, tzinfo, timezone

from euler.py_scripts.common import conf
import pandas as pd

from euler.py_scripts.common.helper import write_df


def main():
    tables = [*conf.ADS_LOCAL_TABLES.values(), conf.PRODUCT_MASTER_TABLE]

    for table in tables:
        path = f"euler/data/{table}.csv"
        df = pd.read_csv(path)
        if "updated_date" in df.columns:
            df["updated_date"] = datetime.now(tz=timezone.utc)
        print(f"Seeding {table}")
        write_df(df, table)


if __name__ == '__main__':
    main()
