create database Test_DWH_Ilnur;
GO

use Test_DWH_Ilnur;

create table customer (
	dwh_customer_id int primary key identity,
	customer_id varchar(10),
	subname nvarchar(20),
	name nvarchar(20),
	phone_number varchar(20),
	city nvarchar(20),
	Registrated_date date
);
create table products (
	dwh_product_id int primary key identity,
	product_id varchar(10),
	name nvarchar(20),
	Description nvarchar(50),
	price int,
	weight decimal(10, 2),
	created_at datetime
);
create table orders (
	Dwh_order_id int primary key identity,
	order_id varchar(10),
	dwh_customer_id int references customer(dwh_customer_id),
	dwh_product_id int references products(dwh_product_id),
	quantity int,
	order_dt date,
	amount decimal(10, 2),
	status nvarchar(5),
	created_at datetime,
	update_at datetime,

	foreign key (dwh_customer_id) references customer(dwh_customer_id) 
		on delete cascade 
		on update cascade,
	foreign key (dwh_product_id) references products(dwh_product_id) 
		on delete cascade 
		on update cascade
);