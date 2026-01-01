
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
