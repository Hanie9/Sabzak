-- یک گیاه نمونه به جدول plants اضافه می‌کند.
-- مقادیر را ویرایش کن و سپس در psql یا با docker exec اجرا کن.
--
-- اجرا با Docker:
--   docker exec -i sabzak-db psql -U postgres -d sabzak < insert_one_plant.sql
--
-- یا داخل psql:
--   \i insert_one_plant.sql
--
-- ═══════════════════════════════════════════════════════════════════
-- عکس گیاه چطور اضافه می‌شود؟
-- ═══════════════════════════════════════════════════════════════════
-- عکس هر گیاه با نام   {plantid}.png   در پوشه   backend/images/   ذخیره می‌شود.
-- بعد از اجرای INSERT زیر، عدد plantid را در خروجی می‌بینی.
--
-- روش ۱ (دستی): فایل عکس را با نام همان عدد ذخیره کن، مثلاً اگر plantid = 10 بود:
--   cp /مسیر/عکس.png  backend/images/10.png
--
-- روش ۲ (از اپ): با اکانت ادمین برو به «افزودن گیاه»، گیاه را اضافه کن و عکس را انتخاب کن
--   (اپ خودش عکس را به سرور می‌فرستد و با همان plantid ذخیره می‌کند).
--
-- روش ۳ (با curl، بعد از ساخت گیاه): اگر بک‌اند بالا است و session_id ادمین را داری:
--   curl -X POST -F "file=@/مسیر/عکس.png" \
--     -H "session_id: SESSION_ID_ADMIN" \
--     http://127.0.0.1:8888/images/upload_photo/PLANTID
--   به‌جای PLANTID همان عدد plantid را بگذار.
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO plants (
    plantname,
    price,
    category,
    humidity,
    temperature,
    description,
    size
) VALUES (
    'گل رز',                    -- plantname
    150000,                     -- price
    'پیشنهادی',                 -- category (یکی از: پیشنهادی، آپارتمانی، محل‌کار، باغچه‌ای، سمی)
    60,                         -- humidity (عدد، مثلاً ۱ تا ۱۰۰)
    '۱۵ تا ۲۵ درجه',           -- temperature
    'گیاه زینتی و خوشبو.',      -- description
    'متوسط'                     -- size
)
RETURNING plantid;
