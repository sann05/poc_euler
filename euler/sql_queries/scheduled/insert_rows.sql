-- create temp table with batch to insert
drop table if exists temp_ads_to_insert_{locality};
create temp table temp_ads_to_insert_{locality}
as
with ads_local_new as (
    select
        id as fk_source_id,
        date,
        products,
        updated_date
    from ads_{locality}
    where
        updated_date > coalesce ((select max(updated_date) from ads_combined where source = '{locality}' ), '1970-01-01')
        and deleted_date is null
),

max_id as (
    select coalesce (max(id), 0) as max_combined_id from ads_combined
),

ads_local_to_insert as (
    select
        row_number() over () + max_combined_id as ad_combined_id,
        fk_source_id,
        date,
        products,
        updated_date
    from ads_local_new
    cross join max_id
    where
        fk_source_id not in (select fk_source_id from ads_combined where source = '{locality}')

)

select * from ads_local_to_insert;


-- insert into combined
insert into ads_combined
(id, fk_source_id, source, date, updated_date)
select
    ad_combined_id,
    fk_source_id,
    '{locality}',
    date,
    updated_date
from temp_ads_to_insert_{locality};


-- insert mapping
insert into ads_order_mapping
with ads_to_insert as (
    select
        ad_combined_id,
        fk_source_id,
        split_to_array(products, ',') as products_array
    from temp_ads_to_insert_{locality} as ads_local
),

ads_exploded as (
    select
        ad_combined_id,
        fk_source_id,
        element::VARCHAR as product,
        index + 1 as index
    from ads_to_insert as ad,
    ad.products_array as element at index
),

ads_exploded_with_product_id as (
    select
        ads_exploded.ad_combined_id,
        product_master.id as product_id,
        ads_exploded.index as order_number
    from ads_exploded
    inner join product_master
	    on ads_exploded.product like '%' || product_master.product || '%'
)

select
    ad_combined_id,
    product_id,
    order_number
from ads_exploded_with_product_id;