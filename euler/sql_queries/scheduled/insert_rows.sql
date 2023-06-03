-- create temp table with batch to insert
with ads_local_new as (
    select
        id as fk_source_id,
        date,
        products,
        updated_date
    from ads_{locality}
    where
        updated_date > (select max(updated_date) from ads_combined where source = '{locality}' )
),

max_id as (
    select max(id) as max_combined_id from ads_combined
),

ads_local_to_insert as (
    select
        row_number() over () + max_combined_id as ads_combined_id,
        fk_source_id,
        date,
        products,
        updated_date
    from ads_local_new
    cross join max_id
    where
        fk_source_id not in (select fk_source_id from ads_combined where lower(source) = '{locality}')

)

create temp_ads_to_insert_{locality}
as
select * from ads_local_to_insert;


-- insert into combined
insert into ads_combined
(id, fk_source_id, source, date, updated_date)
select
    ads_combined_id,
    fk_source_id,
    '{locality}',
    date,
    updated_date
from temp_ads_to_insert_{locality};

-- insert mapping
with ads_to_insert(
    select
        ads_combined_id,
        fk_source_id,
        split_to_array(products, ',') as products_array
    from temp_ads_to_insert_{locality} as ads_local,
),

ads_exploded as (
    select
        ads_combined_id,
        fk_source_id,
        element::VARCHAR as product,
        index + 1 as index
    from ads_to_insert as ad,
    ad.products_array as element at index
),

ads_exploded_with_product_id as (
    select
        ads_exploded.ads_combined_id,
        product.id as product_id,
        ads_exploded.index as order_number
    from ads_exploded
    inner join product_master
	    on ads_exploded.product like '%' || product_master.product || '%'
)

insert into ads_order_mapping
select
    ads_combined_id,
    product_id,
    order_number
from ads_exploded_with_product_id;