drop table if exists temp_new_products;
create temp table temp_new_products
as
select
    id,
    product
from product_master
where updated_date > (select max(updated_date) from ads_combined);

insert into ads_order_mapping
with ads_to_insert as (
    select
        ads_combined.id as ad_combined_id,
        fk_source_id,
        split_to_array(products, ',') as products_array
    from ads_{locality} as ads_local
    join ads_combined
        on ads_combined.fk_source_id = ads_local.id
        and ads_combined.source = '{locality}'
    where deleted_date is null
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
    inner join temp_new_products as product_master
	    on ads_exploded.product like '%' || product_master.product || '%'
)

select
    ad_combined_id,
    product_id,
    order_number
from ads_exploded_with_product_id;