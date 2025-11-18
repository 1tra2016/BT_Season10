create schema bt_season_10_gioi2;
set search_path to bt_season_10_gioi2;

create table products (
    id serial primary key,
    name varchar(100) not null,
    stock int not null
);

create table orders (
    id serial primary key,
    product_id int not null,
    quantity int not null,
    foreign key (product_id) references products(id)
);

create or replace function update_stock_insert()
returns trigger
language plpgsql
as $$
begin
    update products
    set stock = stock - new.quantity
    where id = new.product_id;

    return new;
end;
$$;
create trigger trg_orders_insert
after insert on orders
for each row
execute function update_stock_insert();

select * from products;
insert into products (name, stock) values
    ('laptop acer', 100),
    ('iphone 15', 50),
    ('chuột logitech', 200);
insert into orders (product_id, quantity) values (1, 5);
select * from products where id = 1;

create or replace function update_stock_update()
returns trigger
language plpgsql
as $$
begin
    -- nếu đổi product
    if old.product_id <> new.product_id then
        update products
        set stock = stock + old.quantity
        where id = old.product_id;

        update products
        set stock = stock - new.quantity
        where id = new.product_id;

        return new;
    end if;

    -- cùng product, quantity thay đổi
    if old.quantity <> new.quantity then
        update products
        set stock = stock + old.quantity - new.quantity
        where id = new.product_id;
    end if;

    return new;
end;
$$;
create trigger trg_orders_update
after update on orders
for each row
execute function update_stock_update();

update orders set quantity = 10 where id = 1;
select * from products where id = 1;

update orders set product_id = 2, quantity = 3 where id = 1;
select * from products;

create or replace function update_stock_delete()
returns trigger
language plpgsql
as $$
begin
    update products
    set stock = stock + old.quantity
    where id = old.product_id;

    return old;
end;
$$;
create trigger trg_orders_delete
after delete on orders
for each row
execute function update_stock_delete();

delete from orders where id = 1;
select * from products;
