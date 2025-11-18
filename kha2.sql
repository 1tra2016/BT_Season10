create schema bt_season_10_kha2;
set search_path to bt_season_10_kha2;

create table customers (
    id serial primary key,
    name varchar(100) not null,
    credit_limit numeric(12, 2) not null
);

create table orders (
    id serial primary key,
    customer_id int not null,
    order_amount numeric(12, 2) not null,
    foreign key (customer_id) references customers(id)
);

create or replace function check_credit_limit()
returns trigger
language plpgsql
as $$
declare
    current_total numeric(12, 2);
    limit_value numeric(12, 2);
begin
    select coalesce(sum(order_amount), 0)
    into current_total
    from orders
    where customer_id = new.customer_id;

    select credit_limit
    into limit_value
    from customers
    where id = new.customer_id;

    if current_total + new.order_amount > limit_value then
        raise exception 'Khách hàng % đã vượt hạn mức tín dụng: tổng hiện tại %, đơn mới %, hạn mức %',
            new.customer_id, current_total, new.order_amount, limit_value;
    end if;

    return new;
end;
$$;

create trigger trg_check_credit
before insert on orders
for each row
execute function check_credit_limit();

insert into customers (name, credit_limit) values
    ('khách hàng a', 10000000),
    ('khách hàng b', 5000000);

select * from customers;

insert into orders (customer_id, order_amount) values (1, 3000000);
select * from orders;
insert into orders (customer_id, order_amount) values (1, 4000000);
select * from orders;

-- Lỗi
insert into orders (customer_id, order_amount) values (1, 4000000);

insert into orders (customer_id, order_amount) values (2, 3000000);
select * from orders;

--Lỗi
insert into orders (customer_id, order_amount) values (2, 2500000);

