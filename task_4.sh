# Очистка старых данных
echo "Очистка старых контейнеров и сетей..."
docker compose -f proxy.yaml down --remove-orphans || true
docker rm -f mysql-dev webapp || true
docker network rm backend || true

# Создаем сеть с нужной подсетью
echo "Создание сети backend..."
docker network create --subnet=172.20.0.0/24 backend

# Запуск MySQL
echo "Запуск MySQL..."
docker run -d \
  --name mysql-dev \
  --network backend \
  --ip 172.20.0.10 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=example \
  -e MYSQL_USER=test_user \
  -e MYSQL_PASSWORD=est_password \
  mysql:8.0

# Ждём, пока MySQL запустится
echo "Ожидание запуска MySQL..."
sleep 10

# Сборка FastAPI приложения
echo "Сборка FastAPI приложения..."
docker build -f Dockerfile.python -t my-fastapi .

# Запуск FastAPI
docker run -d \
  --name webapp \
  --network backend \
  --ip 172.20.0.5 \
  -p 127.0.0.1:5000:5000 \
  -e DB_HOST=172.20.0.10 \
  -e DB_USER=app \
  -e DB_PASSWORD=QwErTy1234 \
  -e DB_NAME=virtd \
  -e TABLE_NAME=requests \
  my-fastapi

# Добавьте импорт time в main.py, чтобы не было NameError ↑

# Теперь запуск прокси
echo "Запуск reverse-proxy и ingress-proxy..."
docker compose -f proxy.yaml up -d
