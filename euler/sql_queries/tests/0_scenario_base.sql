insert into ads_online (date, products)
values
('2022-10-11','iPhone11, iPat');

update ads_us
set products = 'iPhone-XR, Coke, AppleiPad',
 updated_date = current_timestamp
where id = 1