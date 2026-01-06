-- ============================================
-- TABLES
-- ============================================

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    userid UUID PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    is_admin BOOLEAN DEFAULT FALSE,
    register_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: plants
CREATE TABLE IF NOT EXISTS plants (
    plantid SERIAL PRIMARY KEY,
    plantname VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category VARCHAR(255),
    humidity INT,
    temperature VARCHAR(50),
    description TEXT,
    size VARCHAR(50)
);

-- Table: favorites
CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    plantid INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
    PRIMARY KEY (user_id, plantid)
);

-- Table: addresses
CREATE TABLE IF NOT EXISTS addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    reciever_first_name VARCHAR(255) NOT NULL,
    reciever_last_name VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    neighborhood VARCHAR(255),
    alley VARCHAR(255),
    zip_code VARCHAR(50) NOT NULL,
    house_number VARCHAR(50) NOT NULL,
    vahed VARCHAR(50)
);

-- Table: bazkhords (feedback/comments)
CREATE TABLE IF NOT EXISTS bazkhords (
    user_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    bazkhord TEXT NOT NULL
);

-- Table: cart_items
CREATE TABLE IF NOT EXISTS cart_items (
    userid UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    plantid INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (userid, plantid)
);

-- Table: notifications
CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    notification_title VARCHAR(255) NOT NULL,
    notification_comment TEXT
);

-- Table: ratings
CREATE TABLE IF NOT EXISTS ratings (
    user_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    plantid INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
    rating NUMERIC(3, 1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    reaction TEXT,
    PRIMARY KEY (user_id, plantid)
);

-- Table: sessions
CREATE TABLE IF NOT EXISTS sessions (
    sessionid VARCHAR(255) PRIMARY KEY,
    userid UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: orders
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(userid) ON DELETE CASCADE,
    tracking_code VARCHAR(50) NOT NULL UNIQUE,
    total_amount NUMERIC(10, 2) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'cash_on_delivery',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending'
);

-- Table: order_items
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    plant_id INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);


-- ============================================
-- VIEWS
-- ============================================

-- View: Plant details with average rating
CREATE OR REPLACE VIEW plant_details_view AS
SELECT 
    p.plantid,
    p.plantname,
    p.price,
    p.category,
    p.humidity,
    p.temperature,
    p.size,
    p.description,
    COALESCE(AVG(r.rating), 0) AS average_rating,
    COUNT(*) FILTER (WHERE r.rating IS NOT NULL) AS total_ratings
FROM plants p
LEFT JOIN ratings r ON p.plantid = r.plantid
GROUP BY p.plantid, p.plantname, p.price, p.category, p.humidity, p.temperature, p.size, p.description;

-- View: User cart summary
CREATE OR REPLACE VIEW user_cart_summary_view AS
SELECT 
    ci.userid,
    u.username,
    COUNT(ci.plantid) AS total_items,
    SUM(ci.quantity) AS total_quantity,
    SUM(ci.quantity * p.price) AS total_price
FROM cart_items ci
JOIN users u ON ci.userid = u.userid
JOIN plants p ON ci.plantid = p.plantid
GROUP BY ci.userid, u.username;


-- ============================================
-- FUNCTIONS
-- ============================================

-- Function: Calculate total cart value for a user
CREATE OR REPLACE FUNCTION calculate_cart_total(p_userid UUID)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(ci.quantity * p.price), 0)
    INTO total
    FROM cart_items ci
    JOIN plants p ON ci.plantid = p.plantid
    WHERE ci.userid = p_userid;
    
    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- Function: Get plant popularity score
CREATE OR REPLACE FUNCTION get_plant_popularity_score(p_plantid INT)
RETURNS NUMERIC AS $$
DECLARE
    score NUMERIC;
    rating_avg NUMERIC;
    rating_count INT;
    cart_count INT;
BEGIN
    -- Get average rating and count
    SELECT COALESCE(AVG(rating), 0), COUNT(*)
    INTO rating_avg, rating_count
    FROM ratings
    WHERE plantid = p_plantid;
    
    -- Get cart count
    SELECT COUNT(*)
    INTO cart_count
    FROM cart_items
    WHERE plantid = p_plantid;
    
    -- Calculate popularity score (rating * 2 + rating_count + cart_count)
    score := (rating_avg * 2) + (rating_count * 0.5) + (cart_count * 0.3);
    
    RETURN score;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure: Update plant price with history
CREATE OR REPLACE FUNCTION update_plant_price_with_history(
    p_plantid INT,
    p_new_price INT,
    p_updated_by INT
)
RETURNS VOID AS $$
BEGIN
    -- Create price history table if not exists
    CREATE TABLE IF NOT EXISTS plant_price_history (
        id SERIAL PRIMARY KEY,
        plantid INT NOT NULL REFERENCES plants(plantid) ON DELETE CASCADE,
        old_price INT,
        new_price INT,
        updated_by INT REFERENCES users(userid),
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Insert history
    INSERT INTO plant_price_history (plantid, old_price, new_price, updated_by)
    SELECT plantid, price, p_new_price, p_updated_by
    FROM plants
    WHERE plantid = p_plantid;
    
    -- Update price
    UPDATE plants
    SET price = p_new_price
    WHERE plantid = p_plantid;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Log plant insertions
CREATE OR REPLACE FUNCTION log_plant_insert()
RETURNS TRIGGER AS $$
BEGIN
    CREATE TABLE IF NOT EXISTS plant_audit_log (
        id SERIAL PRIMARY KEY,
        plantid INT,
        action VARCHAR(50),
        plantname VARCHAR(255),
        price INT,
        action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    INSERT INTO plant_audit_log (plantid, action, plantname, price)
    VALUES (NEW.plantid, 'INSERT', NEW.plantname, NEW.price);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;




CREATE TRIGGER IF NOT EXISTS trigger_plant_insert
AFTER INSERT ON plants
FOR EACH ROW
EXECUTE FUNCTION log_plant_insert();

-- Trigger: Log plant updates
CREATE OR REPLACE FUNCTION log_plant_update()
RETURNS TRIGGER AS $$
BEGIN
    CREATE TABLE IF NOT EXISTS plant_audit_log (
        id SERIAL PRIMARY KEY,
        plantid INT,
        action VARCHAR(50),
        plantname VARCHAR(255),
        old_price INT,
        new_price INT,
        action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    INSERT INTO plant_audit_log (plantid, action, plantname, old_price, new_price)
    VALUES (NEW.plantid, 'UPDATE', NEW.plantname, OLD.price, NEW.price);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Log plant updates
CREATE OR REPLACE FUNCTION log_plant_update()
RETURNS TRIGGER AS $$
BEGIN
    CREATE TABLE IF NOT EXISTS plant_audit_log (
        id SERIAL PRIMARY KEY,
        plantid INT,
        action VARCHAR(50),
        plantname VARCHAR(255),
        old_price INT,
        new_price INT,
        action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    INSERT INTO plant_audit_log (plantid, action, plantname, old_price, new_price)
    VALUES (NEW.plantid, 'UPDATE', NEW.plantname, OLD.price, NEW.price);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_plant_update
AFTER UPDATE ON plants
FOR EACH ROW
EXECUTE FUNCTION log_plant_update();

-- Trigger: Log plant deletions
CREATE OR REPLACE FUNCTION log_plant_delete()
RETURNS TRIGGER AS $$
BEGIN
    CREATE TABLE IF NOT EXISTS plant_audit_log (
        id SERIAL PRIMARY KEY,
        plantid INT,
        action VARCHAR(50),
        plantname VARCHAR(255),
        price INT,
        action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    INSERT INTO plant_audit_log (plantid, action, plantname, price)
    VALUES (OLD.plantid, 'DELETE', OLD.plantname, OLD.price);
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_plant_delete
AFTER DELETE ON plants
FOR EACH ROW
EXECUTE FUNCTION log_plant_delete();
