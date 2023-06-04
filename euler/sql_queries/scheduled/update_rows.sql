-- create temp table with batch to update
drop table if exists temp_ads_to_insert_{locality};
create temp table temp_ads_to_update_{locality}
as
with ads_local_to_update as (
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

ads_combined_necessary_columns as (
    select
        id as ad_combined_id,
        fk_source_id
    from ads_combined
    where
        fk_source_id in (select fk_source_id from ads_local_to_update)
        and source = '{locality}'
),

ads_local_with_combined as (
    select
        ad_combined_id,
        ads_local_to_update.fk_source_id,
        date,
        products,
        updated_date
    from ads_local_to_update
    inner join ads_combined_necessary_columns
        on ads_combined_necessary_columns.fk_source_id = ads_local_to_update.fk_source_id
)

select * from ads_local_with_combined;

-- deleting rows that need to be updated
delete from ads_order_mapping
where ad_combined_id in (select ad_combined_id from temp_ads_to_update_{locality});

delete from ads_combined
where id in (select ad_combined_id from temp_ads_to_update_{locality});

-- insert rows
insert into ads_combined
select
    ad_combined_id,
    fk_source_id,
    '{locality}' as source,
    date,
    updated_date
from temp_ads_to_update_{locality};

insert into ads_order_mapping
with ads_to_insert as (
    select
        ad_combined_id,
        fk_source_id,
        split_to_array(products, ',') as products_array
    from temp_ads_to_update_{locality} as ads_local
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