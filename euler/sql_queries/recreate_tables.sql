
drop table public.product_master;
create table public.product_master(
    id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    product varchar(256) not null,
    updated_date timestamp default current_timestamp
);

drop table public.ads_us;
create table public.ads_us(
    id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);


drop table public.ads_uk;
create table public.ads_uk(
    id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);


drop table public.ads_online;
create table public.ads_online(
    id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    "date" date not null,
    products varchar(256) not null,
    updated_date timestamp,
    deleted_date timestamp
);

drop table public.ads_combined;
create table public.ads_combined(
    id integer GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    fk_source_id int not null,
    "source" varchar(256) not null,
    "date" date not null,
    updated_date timestamp
)
distkey("date")
sortkey("date");

drop table public.ads_order_mapping;
create table public.ads_order_mapping(
    ad_combined_id integer NOT NULL,
    product_id int not null,
    order_number int not null
);