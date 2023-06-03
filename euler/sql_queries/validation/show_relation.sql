with ads_combined_with_mapping as (
	select
		ads_order_mapping.ad_combined_id,
		fk_source_id,
		product_id,
		order_number,
		"source",
		date,
		updated_date
	from ads_combined
	full outer join ads_order_mapping
		on ads_order_mapping.ad_combined_id = ads_combined.id
),

ads_with_product as (
	select
		ads_combined_with_mapping.*,
		product_master.product
	from ads_combined_with_mapping
	full outer join product_master
		on product_master.id = ads_combined_with_mapping.product_id
),

local_ads as (
	select *, 'us' as source from ads_us
	union all
	select *, 'uk' as source from ads_uk
	union all
	select *, 'online' as source from ads_online
),

ads_with_locals as (
	select
		ads_with_product.*,
		local_ads.date as local_date,
		local_ads.products as local_products,
		local_ads.updated_date as local_updated_date,
		local_ads.deleted_date as local_deleted_date,
		local_ads.source as local_source
	from ads_with_product
	full outer join local_ads
		on ads_with_product.fk_source_id = local_ads.id
		and ads_with_product.source = local_ads.source
)

select * from ads_with_locals

