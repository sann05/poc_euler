import os

from euler.py_scripts.common import conf
from euler.py_scripts.common.helper import get_project_path, get_connection


def main():
    project_root_path = get_project_path()
    scripts_dir_path = 'sql_queries/scheduled/'

    with get_connection() as conn:
        with conn.connection.cursor() as cur:
            conn.connection.autocommit = False
            for locality, table_name in conf.ADS_LOCAL_TABLES.items():
                for script in [
                    "product_added.sql",
                    "delete_rows.sql",
                    "update_rows.sql",
                    "insert_rows.sql"
                ]:
                    script_path = os.path.join(
                        project_root_path,
                        scripts_dir_path,
                        script
                    )
                    with open(script_path, 'r') as f:
                        script_parsed = f.read().format(locality=locality)
                        script_array = [s.strip() for s in
                                        script_parsed.split(';') if s.strip()]
                        print(
                            f"Executing script {script} on table {table_name}")
                        for st in script_array:
                            cur.execute(st)
            conn.connection.commit()


if __name__ == '__main__':
    main()
