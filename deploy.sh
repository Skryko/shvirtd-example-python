#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Skryko/shvirtd-example-python.git"   # 👉 сюда вставь ссылку на свой форк
APP_DIR="/opt/app"
DB_CONTAINER="app-db-1"
DB_PASSWORD="very_strong"
DB_NAME="example"

echo "[INFO] Подготовка окружения..."

# Проверяем, есть ли каталог
if [ -d "$APP_DIR" ]; then
  echo "[WARN] $APP_DIR уже существует, удаляю..."
  rm -rf "$APP_DIR"
fi

# Клонируем проект
echo "[INFO] Клонирую репозиторий..."
git clone "$REPO_URL" "$APP_DIR"

# Переходим внутрь
cd "$APP_DIR"

# Останавливаем старые контейнеры на всякий случай
docker compose down --remove-orphans || true

# Запускаем сборку
echo "[INFO] Собираем и запускаем docker compose..."
docker compose up -d --build

echo "[INFO] Делаю паузу 60 секунд для полной инициализации MySQL..."
sleep 60

echo "[INFO] Создаю таблицу requests..."
docker exec -i $DB_CONTAINER mysql -uroot -p$DB_PASSWORD <<EOSQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_date DATETIME,
    request_ip VARCHAR(255)
);
EOSQL

echo "[SUCCESS] Приложение собрано, база готова, таблица создана!"
