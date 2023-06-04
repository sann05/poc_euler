import os

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

from euler.py_scripts.common import conf


def get_project_path():
    helper_path = os.path.abspath(__file__)
    common_path = os.path.dirname(helper_path)
    py_scripts_path = os.path.dirname(common_path)
    euler_path = os.path.dirname(py_scripts_path)
    return euler_path


def get_url():
    url = URL.create(
        drivername='redshift+redshift_connector',
        host=conf.REDSHIFT_URL,
        port=5439,
        database=conf.DATABASE,
        username=conf.REDSHIFT_LOGIN,
        password=conf.REDSHIFT_PASSWORD
    )
    return url


def get_connection():
    return create_engine(url=get_url()).connect()


def recreate_tables():
    with get_connection() as conn:
        with conn.connection.cursor() as cur:
            conn.connection.autocommit = False
            script = "recreate_tables.sql"
            script_path = os.path.join(
                get_project_path(),
                "sql_queries",
                script
            )
            with open(script_path, 'r') as f:
                script_parsed = f.read()
                script_array = [s.strip() for s in
                                script_parsed.split(';') if s.strip()]
                print(f"Executing script {script}")
                for st in script_array:
                    cur.execute(st)
                conn.connection.commit()


def write_df(df: pd.DataFrame, table, truncate=True):
    with get_connection() as conn:
        if truncate:
            conn.execute(f"truncate table {conf.SCHEMA}.{table};")
        df.to_sql(
            name=table,
            schema=conf.SCHEMA,
            con=conn,
            index=False,
            chunksize=1000,
            if_exists='append')
