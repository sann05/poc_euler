update ads_us
set date = '2022-10-12'::DATE,
 updated_date = current_timestamp
where id = 2;


update ads_uk
set products = 'Coke',
 updated_date = current_timestamp
where id = 2;


update ads_online
set deleted_date = NULL,
 updated_date = current_timestamp
where id = 2;