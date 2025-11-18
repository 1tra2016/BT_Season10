create schema bt_season_10_kha1;
set search_path to bt_season_10_kha1;

create table products (
    id serial primary key,
    name varchar(100) not null,
    price numeric(12, 2) not null,
    last_modified timestamp default now()
);

create or replace function update_last_modified()
returns trigger
language plpgsql
as $$
begin
    new.last_modified := now();
    return new;
end;
$$;

create trigger trg_update_last_modified
before update on products
for each row
execute function update_last_modified();

insert into products (name, price)
values
    ('laptop lenovo', 15000000),
    ('iphone 15', 25000000),
    ('chuột logitech', 500000);

update products set price = 26000000 where id = 2;

select * from products where id = 2;

update products set price = price * 1.1;

select * from products;
