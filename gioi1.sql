create schema bt_season_10_gioi1;
set search_path to bt_season_10_gioi1;

create table employees (
    id serial primary key,
    name varchar(50) not null,
    position varchar(50),
    salary numeric(10,2)
);

create table employees_log (
    id serial primary key,
    employee_id int,
    operation varchar(10),
    old_data jsonb,
    new_data jsonb,
    change_time timestamp default now()
);

create or replace function log_employee_insert()
returns trigger
language plpgsql
as $$
begin
    insert into employees_log(employee_id, operation, old_data, new_data)
    values (new.id, 'INSERT', null, to_jsonb(new));
    return new;
end;
$$;

create trigger trg_employees_insert
after insert on employees
for each row
execute function log_employee_insert();

insert into employees (name, position, salary) values ('nguyen van a', 'developer', 15000000);
select * from employees_log order by id;


create or replace function log_employee_update()
returns trigger
language plpgsql
as $$
begin
    insert into employees_log(employee_id, operation, old_data, new_data)
    values (new.id, 'UPDATE', to_jsonb(old), to_jsonb(new));
    return new;
end;
$$;
create trigger trg_employees_update
after update on employees
for each row
execute function log_employee_update();

update employees set salary = 18000000 where id = 1;
select * from employees_log order by id;


create or replace function log_employee_delete()
returns trigger
language plpgsql
as $$
begin
    insert into employees_log(employee_id, operation, old_data, new_data)
    values (old.id, 'DELETE', to_jsonb(old), null);
    return old;
end;
$$;
create trigger trg_employees_delete
after delete on employees
for each row
execute function log_employee_delete();

delete from employees where id = 1;
select * from employees_log order by id;
