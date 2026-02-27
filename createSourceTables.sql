if DB_ID('Test_DWH_Ilnur') is NULL
	create database Test_DWH_Ilnur;
GO

use Test_DWH_Ilnur;
GO

create table klienti (
	customer_id varchar(10),
	subname nvarchar(20),
	name nvarchar(20),
	phone_number varchar(20),
	city nvarchar(20),
	Registrated_date date
);
create table tovari (
	product_id varchar(10),
	name nvarchar(20),
	Description nvarchar(100),
	price int,
	weight decimal(10, 2),
	created_at datetime
);
create table zakazi (
	order_id varchar(10),
	customer_id varchar(10),
	product_id varchar(10),
	quantity int,
	order_dt date,
	amount decimal(10, 2),
	status nvarchar(5),
	created_at datetime,
	updated_at datetime
);