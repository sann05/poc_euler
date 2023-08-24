create or replace library thefuzz language plpythonu
from 's3://test-euler-bucket-v1/thefuzz.zip'
iam_role default;
