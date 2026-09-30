CREATE DATABASE online_retail_db;

USE online_retail_db;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(30) DEFAULT 'Pending',
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

INSERT INTO customers
(customer_name, email, phone, address)
VALUES
('Anu Thomas', 'anu@gmail.com', '9876543210', 'Kochi'),
('Rahul Nair', 'rahul@gmail.com', '9876543211', 'Kollam'),
('Meera Joseph', 'meera@gmail.com', '9876543212', 'Trivandrum'),
('Arjun Kumar', 'arjun@gmail.com', '9876543213', 'Thrissur'),
('Sneha Menon', 'sneha@gmail.com', '9876543214', 'Calicut');

INSERT INTO products
(product_name, category, price, stock_quantity)
VALUES
('Wireless Mouse', 'Electronics', 799.00, 50),
('Keyboard', 'Electronics', 1299.00, 40),
('USB Cable', 'Accessories', 299.00, 100),
('Laptop Bag', 'Accessories', 1499.00, 30),
('Bluetooth Speaker', 'Electronics', 2499.00, 25);

INSERT INTO orders
(customer_id, order_date, total_amount, status)
VALUES
(1, '2026-09-01', 1098.00, 'Completed'),
(2, '2026-09-03', 1299.00, 'Completed'),
(3, '2026-09-05', 2499.00, 'Pending'),
(4, '2026-09-07', 1098.00, 'Completed'),
(5, '2026-09-10', 1499.00, 'Pending');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 799.00),
(1, 3, 1, 299.00),
(2, 2, 1, 1299.00),
(3, 5, 1, 2499.00),
(4, 1, 1, 799.00),
(4, 3, 1, 299.00),
(5, 4, 1, 1499.00);

INSERT INTO payments
(order_id, payment_date, amount, payment_method, payment_status)
VALUES
(1, '2026-09-01', 1098.00, 'UPI', 'Paid'),
(2, '2026-09-03', 1299.00, 'Credit Card', 'Paid'),
(3, '2026-09-05', 2499.00, 'UPI', 'Pending'),
(4, '2026-09-07', 1098.00, 'Debit Card', 'Paid'),
(5, '2026-09-10', 1499.00, 'Cash on Delivery', 'Pending');

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

SELECT * FROM order_items;

SELECT * FROM payments;

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
ORDER BY o.order_date;

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS item_total,
    o.status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
ORDER BY o.order_date;

SELECT
    p.category,
    COUNT(oi.order_item_id) AS total_items_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

CREATE VIEW sales_report AS
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS item_total,
    o.status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id;

SELECT * FROM sales_report;

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    p.payment_method,
    p.payment_status
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN payments p
    ON o.order_id = p.order_id
ORDER BY o.order_date;

SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_sales DESC;