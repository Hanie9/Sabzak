-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    tracking_code VARCHAR(50) NOT NULL UNIQUE,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'cash_on_delivery',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);

-- Create order_items table to store items in each order
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    plant_id INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

