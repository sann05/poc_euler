
drop table public.product_master;
create table public.product_master(
    id integer not null,
    product varchar(256) not null
);

drop table public.ads_us;
create table public.ads_us(
    id integer not null,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);


drop table public.ads_uk;
create table public.ads_uk(
    id integer not null,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);


drop table public.ads_online;
create table public.ads_online(
    id integer not null,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);

drop table public.ads_combined;
create table public.ads_combined(
    id integer not null,
    fk_source_id int not null,
    "source" varchar(256) not null,
    "date" date not null,
    updated_date timestamp
)
distkey("date")
sortkey("date");

drop table public.ads_mapping;
create table public.ads_mapping(
    ad_combined_id integer not null,
    product_id int not null,
    ad_source_id varchar(256) not null
);