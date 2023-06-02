import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

from euler.py_scripts.common import conf


def write_df(df: pd.DataFrame, table, truncate=True):
    url = URL.create(
        drivername='redshift+redshift_connector',
        host=conf.REDSHIFT_URL,
        port=5439,
        database=conf.DATABASE,
        username=conf.REDSHIFT_LOGIN,
        password=conf.REDSHIFT_PASSWORD
    )
    with create_engine(url=url).connect() as conn:
        if truncate:
            conn.execute(f"truncate table {conf.SCHEMA}.{table};")
        df.to_sql(
            name=table,
            schema=conf.SCHEMA,
            con=conn,
            index=False,
            chunksize=1000,
            if_exists='replace')

