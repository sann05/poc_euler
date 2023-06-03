with common_ids as (
    select
        id as ads_combined_id,
        fk_source_id
    from ads_combined
    where lower(source) = '{locality}'
),

ads_to_delete as  (
    select
        id as fk_source_id
    from ads_{locality}
    where deleted_date > (select max(updated_date) from ads_combined where lower(source) = '{locality}' );
),

ids_to_delete as (
    select
        common_ids.ads_combined_id
    from common_ids
    inner join ads_to_delete
        on ads_to_delete.fk_source_id = common_ids.fk_source_id
)
create temp_ads_to_delete_{locality}
as
select * from ids_to_delete;


-- deleting rows that were deleted in the local ads source
delete from ads_order_mapping
where ads_combined_id in (select ads_combined_id from temp_ads_to_delete_{locality});

delete from ads_combined
where ads_combined_id in (select ads_combined_id from temp_ads_to_delete_{locality});