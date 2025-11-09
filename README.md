## Домашнее задание к занятию 5. «Практическое применение Docker»

### Задача 0

1. Убедитесь что у вас НЕ(!) установлен docker-compose, для этого получите следующую ошибку от команды docker-compose --version

Command 'docker-compose' not found, but can be installed with:

```

sudo snap install docker          # version 24.0.5, or

sudo apt  install docker-compose  # version 1.25.0-1

```

See 'snap info docker' for additional versions.

В случае наличия установленного в системе docker-compose - удалите его.

2. Убедитесь что у вас УСТАНОВЛЕН docker compose(без тире) версии не менее v2.24.X, для это выполните команду docker compose version

Своё решение к задачам оформите в вашем GitHub репозитории!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

### Решение:

![1](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/1.png)

![2](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/2.png)

### Задача 1

1. Сделайте в своем GitHub пространстве fork репозитория.

2. Создайте файл Dockerfile.python на основе существующего Dockerfile:

- Используйте базовый образ python:3.12-slim

- Обязательно используйте конструкцию COPY . . в Dockerfile

3. Создайте .dockerignore файл для исключения ненужных файлов

Используйте CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"] для запуска

4. Протестируйте корректность сборки

ВНИМАНИЕ!

!!! В процессе последующего выполнения ДЗ НЕ изменяйте содержимое файлов в fork-репозитории! Ваша задача ДОБАВИТЬ 5 файлов: Dockerfile.python, compose.yaml, .gitignore, .dockerignore,bash-скрипт. Если вам понадобилось внести иные изменения в проект - вы что-то делаете неверно!

### Решение:

```
#Dockerfile.python

FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY main.py ./
CMD ["python", "main.py"]
```

![3](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/3.png)

![5](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/5.png)


### Задача 3

1. Изучите файл "proxy.yaml"

2. Создайте в репозитории с проектом файл compose.yaml. С помощью директивы "include" подключите к нему файл "proxy.yaml".

3. Опишите в файле compose.yaml следующие сервисы:

web. Образ приложения должен ИЛИ собираться при запуске compose из файла Dockerfile.python ИЛИ скачиваться из yandex cloud container registry(из задание №2 со *). Контейнер должен работать в bridge-сети с названием backend и иметь фиксированный ipv4-адрес 172.20.0.5. Сервис должен всегда перезапускаться в случае ошибок. Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса web

db. image=mysql:8. Контейнер должен работать в bridge-сети с названием backend и иметь фиксированный ipv4-адрес 172.20.0.10. Явно перезапуск сервиса в случае ошибок. Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!

4. Запустите проект локально с помощью docker compose , добейтесь его стабильной работы: команда curl -L http://127.0.0.1:8090 должна возвращать в качестве ответа время и локальный IP-адрес. Если сервисы не стартуют воспользуйтесь командами: docker ps -a  и docker logs <container_name> . Если вместо IP-адреса вы получаете информационную ошибку --убедитесь, что вы шлете запрос на порт 8090, а не 5000.

5. Подключитесь к БД mysql с помощью команды docker exec -ti <имя_контейнера> mysql -uroot -p<пароль root-пользователя>(обратите внимание что между ключем -u и логином root нет пробела. это важно!!! тоже самое с паролем) . Введите последовательно команды (не забываем в конце символ ; ): show databases; use <имя вашей базы данных(по-умолчанию example)>; show tables; SELECT * from requests LIMIT 10;.

6. Остановите проект. В качестве ответа приложите скриншот sql-запроса.

### Решение:
```
#compose.yaml


include:
  - proxy.yaml

volumes:
  db_mysql:

services:

  db:
    image: mysql:8
    restart: on-failure
    env_file:
      - .env
    volumes:
      - db_mysql:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - 3306:3306
    networks:
      backend:
        ipv4_address: 172.20.0.10
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      retries: 5

  web:
    build:
          dockerfile: Dockerfile.python
    restart: on-failure
    environment:
      DB_HOST: db
      DB_TABLE: requests
      DB_PORT: 3306
      DB_NAME: ${MYSQL_DATABASE}
      DB_USER: ${MYSQL_USER}
      DB_PASSWORD: ${MYSQL_PASSWORD}
    depends_on:
        db:
          condition: service_healthy
    networks:
      backend:
        ipv4_address: 172.20.0.5
```

![8](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/8.png)    

![6](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/6.png)

![7](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/7.png)



### Задача 4

1. Запустите в Yandex Cloud ВМ (вам хватит 2 Гб Ram).

2. Подключитесь к Вм по ssh и установите docker.

3. Напишите bash-скрипт, который скачает ваш fork-репозиторий в каталог /opt и запустит проект целиком.

4. Зайдите на сайт проверки http подключений, например(или аналогичный): https://check-host.net/check-http и запустите проверку вашего сервиса http://<внешний_IP-адрес_вашей_ВМ>:8090. Таким образом трафик будет направлен в ingress-proxy. Трафик должен пройти через цепочки: Пользователь → Internet → Nginx → HAProxy → FastAPI(запись в БД) → HAProxy → Nginx → Internet → Пользователь

### Решение:

![4.1](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/4.1.png)





### Задача 6

1. Скачайте docker образ hashicorp/terraform:latest и скопируйте бинарный файл /bin/terraform на свою локальную машину, используя dive и docker save. Предоставьте скриншоты действий .

Задача 6.1

1. Добейтесь аналогичного результата, используя docker cp.

2. Предоставьте скриншоты действий.

### Решение:

![6.1](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/6.1.png)

![6.2](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/6.2.png)

![6.3](https://github.com/Ivan-Shkutov/sdb-homeworks-virtd_02/blob/main/img/6.3.png)






