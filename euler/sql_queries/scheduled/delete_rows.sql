drop table if exists temp_ads_to_delete_{locality};
create temp table temp_ads_to_delete_{locality}
as
with common_ids as (
    select
        id as ad_combined_id,
        fk_source_id
    from ads_combined
    where source = '{locality}'
),

ads_to_delete as  (
    select
        id as fk_source_id
    from ads_{locality}
    where deleted_date > coalesce ((select max(updated_date) from ads_combined where source = '{locality}' ), '1970-01-01')
),

ids_to_delete as (
    select
        common_ids.ad_combined_id
    from common_ids
    inner join ads_to_delete
        on ads_to_delete.fk_source_id = common_ids.fk_source_id
)
select * from ids_to_delete;


-- deleting rows that were deleted in the local ads source
delete from ads_order_mapping
where ad_combined_id in (select ad_combined_id from temp_ads_to_delete_{locality});

delete from ads_combined
where id in (select ad_combined_id from temp_ads_to_delete_{locality});