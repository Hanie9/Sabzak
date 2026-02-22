#!/bin/bash
# راه‌اندازی دیتابیس PostgreSQL با Docker (برای توسعه محلی)
cd "$(dirname "$0")"
if docker ps -a --format '{{.Names}}' | grep -q '^sabzak-db$'; then
  if docker ps --format '{{.Names}}' | grep -q '^sabzak-db$'; then
    echo "دیتابیس در حال اجراست (sabzak-db)."
  else
    echo "در حال شروع کانتینر sabzak-db..."
    docker start sabzak-db
    echo "دیتابیس آماده است."
  fi
else
  echo "در حال ساخت و اجرای کانتینر sabzak-db..."
  docker run -d --name sabzak-db \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_DB=sabzak \
    -p 5432:5432 \
    postgres:17-alpine
  echo "صبر کنید تا PostgreSQL بالا بیاید..."
  sleep 4
  echo "دیتابیس آماده است."
fi
