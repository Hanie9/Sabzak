--
-- PostgreSQL database dump
--

\restrict 9dwVnk1ZuWHUOKQgaf9Jl1G670HqHwlMj7Hzf4YiBDCKCkwRQHLIKSD5EEIQXcv

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calculate_cart_total(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_cart_total(p_userid uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.calculate_cart_total(p_userid uuid) OWNER TO postgres;

--
-- Name: get_plant_popularity_score(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_plant_popularity_score(p_plantid integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.get_plant_popularity_score(p_plantid integer) OWNER TO postgres;

--
-- Name: log_plant_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_plant_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.log_plant_delete() OWNER TO postgres;

--
-- Name: log_plant_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_plant_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.log_plant_insert() OWNER TO postgres;

--
-- Name: log_plant_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_plant_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.log_plant_update() OWNER TO postgres;

--
-- Name: update_plant_price_with_history(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_plant_price_with_history(p_plantid integer, p_new_price integer, p_updated_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.update_plant_price_with_history(p_plantid integer, p_new_price integer, p_updated_by integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    address_id integer NOT NULL,
    customer_id uuid NOT NULL,
    reciever_first_name character varying(255) NOT NULL,
    reciever_last_name character varying(255) NOT NULL,
    street character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    neighborhood character varying(255),
    alley character varying(255),
    zip_code character varying(50) NOT NULL,
    house_number character varying(50) NOT NULL,
    vahed character varying(50)
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.addresses_address_id_seq OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_address_id_seq OWNED BY public.addresses.address_id;


--
-- Name: bazkhords; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bazkhords (
    user_id uuid NOT NULL,
    bazkhord text NOT NULL
);


ALTER TABLE public.bazkhords OWNER TO postgres;

--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    userid uuid NOT NULL,
    plantid integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- Name: favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorites (
    user_id uuid NOT NULL,
    plantid integer NOT NULL
);


ALTER TABLE public.favorites OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    notification_id integer NOT NULL,
    notification_title character varying(255) NOT NULL,
    notification_comment text
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_notification_id_seq OWNER TO postgres;

--
-- Name: notifications_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_notification_id_seq OWNED BY public.notifications.notification_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_id integer NOT NULL,
    plant_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id uuid NOT NULL,
    tracking_code character varying(50) NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    payment_method character varying(50) DEFAULT 'cash_on_delivery'::character varying,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'pending'::character varying
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: plants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plants (
    plantid integer NOT NULL,
    plantname character varying(255) NOT NULL,
    price numeric(10,2) NOT NULL,
    category character varying(255),
    humidity integer,
    temperature character varying(50),
    description text,
    size character varying(50)
);


ALTER TABLE public.plants OWNER TO postgres;

--
-- Name: ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ratings (
    user_id uuid NOT NULL,
    plantid integer NOT NULL,
    rating numeric(3,1) NOT NULL,
    reaction text,
    CONSTRAINT ratings_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


ALTER TABLE public.ratings OWNER TO postgres;

--
-- Name: plant_details_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.plant_details_view AS
 SELECT p.plantid,
    p.plantname,
    p.price,
    p.category,
    p.humidity,
    p.temperature,
    p.size,
    p.description,
    COALESCE(avg(r.rating), (0)::numeric) AS average_rating,
    count(*) FILTER (WHERE (r.rating IS NOT NULL)) AS total_ratings
   FROM (public.plants p
     LEFT JOIN public.ratings r ON ((p.plantid = r.plantid)))
  GROUP BY p.plantid, p.plantname, p.price, p.category, p.humidity, p.temperature, p.size, p.description;


ALTER VIEW public.plant_details_view OWNER TO postgres;

--
-- Name: plants_plantid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.plants_plantid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plants_plantid_seq OWNER TO postgres;

--
-- Name: plants_plantid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.plants_plantid_seq OWNED BY public.plants.plantid;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    sessionid character varying(255) NOT NULL,
    userid uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    userid uuid NOT NULL,
    firstname character varying(255) NOT NULL,
    lastname character varying(255) NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    is_admin boolean DEFAULT false,
    register_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: user_cart_summary_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_cart_summary_view AS
 SELECT ci.userid,
    u.username,
    count(ci.plantid) AS total_items,
    sum(ci.quantity) AS total_quantity,
    sum(((ci.quantity)::numeric * p.price)) AS total_price
   FROM ((public.cart_items ci
     JOIN public.users u ON ((ci.userid = u.userid)))
     JOIN public.plants p ON ((ci.plantid = p.plantid)))
  GROUP BY ci.userid, u.username;


ALTER VIEW public.user_cart_summary_view OWNER TO postgres;

--
-- Name: addresses address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN address_id SET DEFAULT nextval('public.addresses_address_id_seq'::regclass);


--
-- Name: notifications notification_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN notification_id SET DEFAULT nextval('public.notifications_notification_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: plants plantid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants ALTER COLUMN plantid SET DEFAULT nextval('public.plants_plantid_seq'::regclass);


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.addresses (address_id, customer_id, reciever_first_name, reciever_last_name, street, city, neighborhood, alley, zip_code, house_number, vahed) FROM stdin;
1	d62922e6-8d8c-435b-b154-aa65d1e8c34d	hanie	nabati	تهران	تهران		کرمیار	1371912345	53	4
2	d62922e6-8d8c-435b-b154-aa65d1e8c34d	hanie	nabati	تهران	تهران		کرمیار	1371912345	53	4
3	d62922e6-8d8c-435b-b154-aa65d1e8c34d	hanie	nabati	تهران	تهران		کرمیار	1371912345	53	4
4	d62922e6-8d8c-435b-b154-aa65d1e8c34d	hanie	nabati	تهران	تهران		کرمیار	1371912345	53	4
\.


--
-- Data for Name: bazkhords; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bazkhords (user_id, bazkhord) FROM stdin;
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (userid, plantid, quantity) FROM stdin;
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorites (user_id, plantid) FROM stdin;
d62922e6-8d8c-435b-b154-aa65d1e8c34d	2
d62922e6-8d8c-435b-b154-aa65d1e8c34d	6
d62922e6-8d8c-435b-b154-aa65d1e8c34d	3
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (notification_id, notification_title, notification_comment) FROM stdin;
2	test2	jghfds
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_item_id, order_id, plant_id, quantity, price) FROM stdin;
3	2	2	2	85000.00
4	3	4	2	250000.00
5	4	3	1	65000.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, user_id, tracking_code, total_amount, payment_method, order_date, status) FROM stdin;
1	d62922e6-8d8c-435b-b154-aa65d1e8c34d	511335	600000.00	cash_on_delivery	2026-02-22 11:11:41.861862	pending
2	d62922e6-8d8c-435b-b154-aa65d1e8c34d	350121	290000.00	cash_on_delivery	2026-02-22 11:35:07.813937	pending
3	d62922e6-8d8c-435b-b154-aa65d1e8c34d	231839	500000.00	cash_on_delivery	2026-02-25 11:41:53.755947	pending
4	d62922e6-8d8c-435b-b154-aa65d1e8c34d	883517	65000.00	cash_on_delivery	2026-02-26 07:04:32.783437	pending
\.


--
-- Data for Name: plants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plants (plantid, plantname, price, category, humidity, temperature, description, size) FROM stdin;
4	شمعدانی	250000.00	باغچه‌ای	55	۱۰ تا ۲۵ درجه	شمعدانی با گل‌های رنگارنگ قرمز، صورتی و سفید یکی از بهترین گزینه‌ها برای باغچه و فضای باز است. نور زیاد و آبیاری منظم را دوست دارد و در فصول گرم به خوبی گل می‌دهد.	متوسط
2	سنبل	85000.00	آپارتمانی	60	۱۵ تا ۲۲ درجه	سنبل گیاهی معطر و زیبا با گل‌های خوشه‌ای است که برای فضای بسته و آپارتمان ایده‌آل است. در بهار گل می‌دهد و با نگهداری ساده می‌تواند سال‌ها در گلدان بماند.	کوچک
3	کاکتوس	65000.00	محل‌کار	30	۲۰ تا ۲۸ درجه	کاکتوس گیاهی بسیار مقاوم و کم‌نیاز است؛ به آبیاری کم و نور معمولی اتاق عادت دارد و برای میز کار و محیط اداری گزینه مناسبی است. در اندازه‌های مختلف موجود است.	کوچک
6	پتوس	70000.00	آپارتمانی	65	۱۷ تا ۲۶ درجه	پتوس گیاهی رونده و بسیار مقاوم است؛ در نور کم هم رشد می‌کند و به تصفیه هوا کمک می‌کند. برای گلدان آویز یا روی قفسه مناسب است و نگهداری آن برای تازه‌کارها هم آسان است.	متوسط
7	گل داوودی	135000.00	پیشنهادی	50	۱۵ تا ۲۰ درجه	گل داوودی در رنگ‌های سفید، زرد، بنفش و قرمز برای فضای باز و باغچه عالی است. گل‌دهی پاییزه دارد و با هرس به موقع می‌توان چند سال از آن استفاده کرد.	متوسط
8	نخل اریکا	180000.00	محل‌کار	60	۱۸ تا ۲۷ درجه	نخل اریکا نخل زینتی با برگ‌های سبز و ظریف است و برای محیط اداری و پذیرایی مناسب است. به نور غیرمستقیم و رطوبت متوسط نیاز دارد و در فضای بسته به خوبی رشد می‌کند.	بزرگ
9	بگونیا	78000.00	باغچه‌ای	55	۱۶ تا ۲۴ درجه	بگونیا با برگ‌ها و گل‌های رنگی برای گلدان و باغچه مناسب است. گونه‌های مختلفی دارد؛ بعضی برای گل و بعضی برای برگ‌های زینتی نگهداری می‌شوند. آبیاری منظم و نور فیلتر شده لازم دارد.	کوچک
5	دیفن باخیا	5600000.00	سمی	70	۱۸ تا ۲۴ درجه	دیفن باخیا گیاه آپارتمانی با برگ‌های پهن و رگه‌دار است. توجه کنید که شیره و برگ‌های آن سمی هستند و باید از دسترس کودکان و حیوانات دور نگه داشته شود. به رطوبت و نور غیرمستقیم نیاز دارد.	متوسط
\.


--
-- Data for Name: ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ratings (user_id, plantid, rating, reaction) FROM stdin;
d62922e6-8d8c-435b-b154-aa65d1e8c34d	2	4.0	
d62922e6-8d8c-435b-b154-aa65d1e8c34d	3	3.5	
d62922e6-8d8c-435b-b154-aa65d1e8c34d	4	3.5	
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (sessionid, userid, created_at) FROM stdin;
ZiP2YQaKGJBrY6fpCH8ywa7C3NSEJ2MNaO7hfgLiY18PgQbMq2	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:24:56.507384
DAXSM1WRpwiW0B7pygkChkFRCAFDDlsxHKkXkWJ2derbWGSy6I	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:24:56.598998
VbPjVdnVw70Y1wx5S4QkJLKgdQ8ZOqjUeLbhUjgEbShG7B1sOO	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:30:04.507058
cOHAJoib4H7vOYJZoUEf2THuwFYp1Zygzig0pTld0VP8DcLixl	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:37:27.635439
3oV54kCgUHfOVcNCK3UBELFmB4qgIDIm6QJJkL5jSDO6zvcdZw	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:38:03.482437
yeXQ4LtrBjL8j5TaiADPYCRnbXsN6McN8ISajizB1hLeMymwsO	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:48:48.121424
I10LH8i5qLzXGKmas2VHtbYwLXE9zxZ7ol3a80Uwl9xHPjbVIz	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:51:22.807805
gT49U73p0sqTobFUjHBaonu3Tovt46Gj2C2iJlCQZaiXqCmAOV	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:58:42.556603
bZZgHe1l72WBiMHR04O8fu02CatJeKJs4jGPHpCgS3NsDvIfaK	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 10:59:25.811067
9Y91zedLuIkny4oJpfF4qAGfTHY2kG9eOqxETkJxKDUzV3GlTc	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:03:55.699875
miFQw2MNYiDlv0ja2MyrwtO0acIJzhSCghejpILTDSWLfGYgYW	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:10:43.352888
YBynAW4je3ZdGflj8fBkLpAMBJLaWS5ght93ghUCMYTi2OuWHO	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:27:26.322939
5eUbWZfYkmp32xDim8Ec10Z2aQIHL3mLEGCrr9g1NNYbrYWNfM	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:45:54.895098
tYW7ArDo9gDbbpnYqHXKDfzuGQbGgEvSaOv0hq4uxz2pSPUAmj	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:46:26.280237
w7MXseGgmgXDj5osJ7QqOBpk7RdfR2H1rxTbca8zzvcjqGbwfD	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:46:59.496668
SdBXyNEJahe7ZAiUctJfNeJtyIVbYnJQKmesEx5jlyejZIsB2G	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:57:58.502177
H1BzOWETsrALXH8Wwp2R8rvbzDA6sofVUDKPMOybxpuS2ACik7	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:58:38.584519
FepYRXvymNiyYv9tmEtkiEcRb4UmKdL1KHsunSfu5a9uljSIcU	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 11:59:20.758705
A5CQSVDkYNSDAILH7JYM4j25JujRVmrRbYuvPTG3dQxZj3ropT	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:00:13.554528
7taA2A7UfUsxMaVhKEEERqkusC70M31E0oB2WngreNe2bnG1dO	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:03:42.597106
V9mLCsrsmNP0ZyMgdSxqBX8gBJheIacEuxRHnBjEp3OvsAoeaz	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:04:15.353855
H8ry4raNs6AS3vjCvyaQzhWI6u5dOaRrAEkUjuD8pLtPiuYS7r	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:10:25.243844
YnRygFMQYI18ZZ1L96FYn8r9oOCsq7svucqBPwnVXDVNoHsb6c	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:16:48.465245
2dDHK7LA4l4ZuEv5rWHuUQjH9xksJEANQnp3ZuBZGgXrkRASaQ	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 12:44:44.177289
pb9dHD8xqPHe3n13ZiNFiCAEgYisSSdVaamDQZZM0RdHzgTNLh	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-22 18:30:52.256865
zfAc560st0JVlSq2xBtoVpaS0x2ebu68gz2LoT1FuUDgcLMqIJ	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-25 11:40:57.674693
drTMLQR6ECZL9FHaDQurmcjwWSIimGAdxlkiioVCmEiTubzGpc	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-26 06:57:44.796494
FRvuQEOQ1tyZE1I8WVduiS9flKojmNVDPycZfO94tkOpf9NecE	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-26 07:08:20.787607
3AbF4LyTahziqODO0wi20NNrpC7wWICLdTygK64vQa2cFZmc5M	d62922e6-8d8c-435b-b154-aa65d1e8c34d	2026-02-26 08:04:08.942336
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (userid, firstname, lastname, username, password, email, is_admin, register_date) FROM stdin;
e14a1a21-9dc0-42c2-8a3f-d6f93f8f7a6f	amirhosein	hafizi	amir	Amir@1382	amir@gmail.com	f	2026-02-22 11:57:23.411077
d62922e6-8d8c-435b-b154-aa65d1e8c34d	حانیه	نباتی	hanie	Hanie@8282	hanienabati@gmail.com	t	2026-02-22 10:24:56.497386
\.


--
-- Name: addresses_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.addresses_address_id_seq', 4, true);


--
-- Name: notifications_notification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_notification_id_seq', 2, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 5, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 4, true);


--
-- Name: plants_plantid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.plants_plantid_seq', 20, true);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (userid, plantid);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (user_id, plantid);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (notification_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: orders orders_tracking_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_tracking_code_key UNIQUE (tracking_code);


--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (plantid);


--
-- Name: ratings ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (user_id, plantid);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (sessionid);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: addresses addresses_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: bazkhords bazkhords_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bazkhords
    ADD CONSTRAINT bazkhords_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_plantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_plantid_fkey FOREIGN KEY (plantid) REFERENCES public.plants(plantid) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: favorites favorites_plantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_plantid_fkey FOREIGN KEY (plantid) REFERENCES public.plants(plantid) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_plant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES public.plants(plantid) ON DELETE CASCADE;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: ratings ratings_plantid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_plantid_fkey FOREIGN KEY (plantid) REFERENCES public.plants(plantid) ON DELETE CASCADE;


--
-- Name: ratings ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- Name: sessions sessions_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_userid_fkey FOREIGN KEY (userid) REFERENCES public.users(userid) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 9dwVnk1ZuWHUOKQgaf9Jl1G670HqHwlMj7Hzf4YiBDCKCkwRQHLIKSD5EEIQXcv

