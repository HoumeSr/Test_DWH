USE Test_DWH_Ilnur;
GO

--Task 1.

--customer
CREATE OR ALTER PROCEDURE updateCustomer AS
BEGIN
	UPDATE c
	SET subname = k.subname,
		name = k.name,
		phone_number = k.phone_number,
		city = k.city,
		Registrated_date = k.Registrated_date
	FROM customer AS c
	JOIN klienti AS k ON k.customer_id = c.customer_id
	WHERE ISNULL(k.subname, '') <> ISNULL(c.subname, '')
	   OR ISNULL(k.name, '') <> ISNULL(c.name, '')
	   OR ISNULL(k.phone_number, '') <> ISNULL(c.phone_number, '')
	   OR ISNULL(k.city, '') <> ISNULL(c.city, '')
	   OR ISNULL(k.Registrated_date, '99991231') <> ISNULL(c.Registrated_date, '99991231')

	INSERT INTO customer (customer_id, subname, name, phone_number, city, Registrated_date)
	SELECT k.customer_id,
		k.subname,
		k.name,
		k.phone_number,
		k.city,
		k.Registrated_date
	FROM klienti as k
	WHERE NOT EXISTS (SELECT 1 FROM customer AS c WHERE c.customer_id = k.customer_id)
END;
GO

--products
CREATE OR ALTER PROCEDURE updateProducts AS
BEGIN
	UPDATE p
	SET name = t.name,
		Description = t.Description,
		price = t.price,
		weight = t.weight,
		created_at = t.created_at
	FROM products AS p
	JOIN tovari AS t ON t.product_id = p.product_id
	WHERE ISNULL(t.name, '') <> ISNULL(p.name, '') OR
		ISNULL(t.Description, '') <> ISNULL(p.Description, '') OR
		ISNULL(t.price, -1) <> ISNULL(p.price, -1) OR
		ISNULL(t.weight, -1) <> ISNULL(p.weight, -1) OR
		ISNULL(t.created_at, '99991231') <> ISNULL(p.created_at, '99991231');

	INSERT INTO products (product_id, name, Description, price, weight, created_at)
	SELECT t.product_id,
		t.name,
		t.Description,
		t.price,
		t.weight,
		t.created_at
	FROM tovari as t
	WHERE NOT EXISTS (SELECT 1 FROM products AS p WHERE t.product_id = p.product_id)
END;
GO
-- orders
CREATE OR ALTER PROCEDURE updateOrders AS
BEGIN

	UPDATE o
	SET dwh_customer_id = c.dwh_customer_id,
		dwh_product_id = p.dwh_product_id, 
		quantity = z.quantity,
		order_dt = z.order_dt,
		amount = z.amount,
		status = z.status,
		created_at = z.created_at,
		updated_at = z.updated_at
	FROM orders AS o
	JOIN zakazi AS z ON o.order_id = z.order_id
	JOIN customer AS c ON c.customer_id = z.customer_id
	JOIN products AS p ON p.product_id = z.product_id
	WHERE z.updated_at > o.updated_at;

	INSERT INTO orders (order_id, dwh_customer_id, dwh_product_id, quantity, 
	order_dt, amount, status, created_at, updated_at)
	SELECT 
		z.order_id,
		c.dwh_customer_id,
		p.dwh_product_id,
		z.quantity,
		z.order_dt,
		z.amount,
		z.status,
		z.created_at,
		z.updated_at
	FROM zakazi as z
	JOIN products as p ON p.product_id = z.product_id
	JOIN customer as c ON c.customer_id = z.customer_id
	WHERE NOT EXISTS (SELECT 1 FROM orders AS o WHERE o.order_id = z.order_id)
END;
GO

--Task 2.
CREATE OR ALTER PROCEDURE getPopularProducts AS
BEGIN
	WITH productQuantity as (
		SELECT p.name, c.city, sum(o.quantity) as sumQuantity, sum(o.amount) as sumAmount
		FROM products AS p
		JOIN orders AS o ON p.dwh_product_id = o.dwh_product_id
		JOIN customer AS c ON c.dwh_customer_id = o.dwh_customer_id
		GROUP BY c.city, p.name
	),
	topProduct as (
		SELECT name, city, sumQuantity, sumAmount,
			row_number() OVER (PARTITION BY city ORDER BY sumQuantity DESC) as rnk
		FROM productQuantity
	)
	SELECT city, name, sumQuantity, sumAmount FROM topProduct WHERE rnk <= 5
	ORDER BY city, rnk
END;
GO
-- Для улучшения запроса можно создать индексы для dwh_product_id и dwh_customer_id в таблице orders
-- Можно добавить UNIQUE для customer_id, product_id в таблицах customer и products соответсвенно.
-- Как и для таблицы orders сделать UNIQUE для столбца order_id

--Во всех случаях я решил делать инкрементное обновление данных
--В таблицах products и customer находятся первичные ключи, от которых зависят foreign key в order
--Мы не можем очистить эти таблицы, поэтому полное обновление невозможно без очистки orders

--В таблице orders нет такой проблемы, но как правило эта таблица самая объемная
--Следовательно полное обновление данных будет слишком ресурсоёмко

--Task 3

CREATE OR ALTER PROCEDURE getWeigth AS
BEGIN
	UPDATE p
	SET weight = (CASE WHEN	REGEXP_LIKE(p.Description, '([\d]+(.[\d]+)?)\s?кг') THEN CONVERT(decimal(10, 2), REGEXP_SUBSTR(p.Description, '([\d]+(.[\d]+)?)\s?кг', 1, 1, 'i', 1)) * 1000
					   WHEN	REGEXP_LIKE(p.Description, '([\d]+(.[\d]+)?)\s?г') THEN CONVERT(decimal(10, 2), REGEXP_SUBSTR(p.Description, '([\d]+(.[\d]+)?)\s?г', 1, 1, 'i', 1))
					   ELSE NULL END)
	FROM products as p
	WHERE p.Description IS NOT NULL OR p.weight IS NOT NULL
END;