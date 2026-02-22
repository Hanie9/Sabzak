# راهنمای اجرای بک‌اند روی لپ‌تاپ

## پیش‌نیازها

- **Python 3.10+** نصب باشد.
- **PostgreSQL** روی لپ‌تاپ یا روی یک سرور در دسترس باشد و دیتابیس و یوزر ساخته شده باشد.

---

## مرحله ۱: رفتن به پوشه بک‌اند

```bash
cd /home/hanie/Desktop/Sabzak/backend
```

(یا مسیر واقعی پروژه روی سیستم خودتان.)

---

## مرحله ۲: محیط مجازی (اختیاری ولی توصیه می‌شود)

اگر هنوز نساخته‌اید:

```bash
python3 -m venv .venv
source .venv/bin/activate   # لینوکس/مک
# در ویندوز:  .venv\Scripts\activate
```

اگر از قبل `.venv` دارید فقط فعالش کنید:

```bash
source .venv/bin/activate
```

---

## مرحله ۳: نصب وابستگی‌ها

```bash
pip install -r requirements.txt
```

---

## مرحله ۴: تنظیم متغیرهای محیط (اتصال به PostgreSQL)

بک‌اند با **متغیرهای محیط** به دیتابیس وصل می‌شود. یکی از دو روش را انجام دهید.

### روش الف: فایل `.env`

در پوشه `backend` فایلی به نام `.env` بسازید و این خطوط را داخلش بگذارید (مقادیر را با تنظیمات خودتان عوض کنید):

```env
POSTGRES_USER=نام_کاربری_دیتابیس
POSTGRES_PASSWORD=رمز_دیتابیس
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DB=نام_دیتابیس
```

برای اجرای محلی معمولاً:
- `POSTGRES_HOST=127.0.0.1` یا `localhost`
- `POSTGRES_PORT=5432`
- `POSTGRES_DB` همان دیتابیسی است که اسکریپت‌های SQL (مثل `sabzak.sql`) را روی آن اجرا کرده‌اید.

اگر از **python-dotenv** استفاده می‌کنید، این متغیرها قبل از اجرای برنامه لود می‌شوند. در غیر این صورت از روش ب استفاده کنید.

### روش ب: export در ترمینال

قبل از اجرای سرور در همان ترمینال:

```bash
export POSTGRES_USER=نام_کاربری
export POSTGRES_PASSWORD=رمز
export POSTGRES_HOST=127.0.0.1
export POSTGRES_PORT=5432
export POSTGRES_DB=نام_دیتابیس
```

(مقادیر را با تنظیمات PostgreSQL خودتان جایگزین کنید.)

---

## مرحله ۵: اجرای سرور

```bash
uvicorn main:app --host 0.0.0.0 --port 8888
```

- **پورت 8888**: همان پورتی است که در فرانت (مثلاً `constants.dart`) استفاده شده.
- **host 0.0.0.0**: سرور از همه اینترفیس‌ها (از جمله شبکه محلی) در دسترس است؛ برای تست فقط روی همین لپ‌تاپ می‌توانید از `--host 127.0.0.1` استفاده کنید.

اگر همه‌چیز درست باشد، چیزی شبیه این می‌بینید:

```
INFO:     Uvicorn running on http://0.0.0.0:8888
INFO:     Application startup complete.
```

آدرس API روی لپ‌تاپ شما:

- از همان سیستم: `http://127.0.0.1:8888`
- از موبایل/لپ‌تاپ دیگر در همان شبکه: `http://آدرس_IP_لپ‌تاپ:8888`

---

## اگر از فایل `.env` استفاده می‌کنید

کد فعلی `main.py` مستقیماً `os.getenv(...)` می‌خواند و **خودش** فایل `.env` را لود نمی‌کند. دو راه دارید:

1. **قبل از اجرا در ترمینال** متغیرها را با `export` set کنید (همان روش ب بالا)، یا  
2. در ابتدای `main.py` یک بار `load_dotenv()` را صدا بزنید و پکیج `python-dotenv` را نصب کنید:

```bash
pip install python-dotenv
```

و در اول `main.py` بعد از `import os`:

```python
from dotenv import load_dotenv
load_dotenv()
```

بعد از آن با ساختن فایل `.env` در پوشه `backend`، متغیرها خودکار لود می‌شوند.

---

## خلاصه دستورات (بدون .env)

```bash
cd /home/hanie/Desktop/Sabzak/backend
source .venv/bin/activate
export POSTGRES_USER=...
export POSTGRES_PASSWORD=...
export POSTGRES_HOST=127.0.0.1
export POSTGRES_PORT=5432
export POSTGRES_DB=...
uvicorn main:app --host 0.0.0.0 --port 8888
```

بعد از این مراحل، بک‌اند روی لپ‌تاپ شما بالا می‌آید و فرانت می‌تواند به آدرس و پورتی که در `constants.dart` گذاشته‌اید به آن وصل شود (برای تست محلی آدرس را به `http://127.0.0.1:8888` یا IP لپ‌تاپ تغییر دهید).
