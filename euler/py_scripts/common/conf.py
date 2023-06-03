import os

DATABASE = 'dev'
SCHEMA = 'public'

PRODUCT_MASTER_TABLE = 'product_master'
ADS_LOCAL_TABLES = {
    'us': 'ads_us',
    'uk': 'ads_uk',
    'online': 'ads_online'
}
ADS_COMBINED_TABLE = 'ads_combined'
ADS_MAPPING_TABLE = 'ads_mapping'


REDSHIFT_URL = 'poc-redshift-cluser.cqvoimn792bx.eu-central-1.redshift.amazonaws.com'
REDSHIFT_LOGIN = os.environ["REDSHIFT_LOGIN"]
REDSHIFT_PASSWORD = os.environ["REDSHIFT_PASSWORD"]
