FROM ubuntu:20.04 AS base-ubuntu
# Устанавливаем gnupg
RUN apt-get update && apt-get install -y curl gnupg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Добавляем ключ MongoDB
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -

RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

RUN apt update && apt install mongodb-org -y

FROM base-ubuntu AS d-mongo

COPY mongod.conf /etc/mongod.conf

COPY init-script.sh /docker-entrypoint-initdb.d/init-script.sh

RUN openssl rand -base64 756 > /var/lib/mongodb/mongodb-keyfile \
    && chmod 600 /var/lib/mongodb/mongodb-keyfile

# Запускаем MongoDB для создания пользователя в базе данных "admin" без авторизации
RUN mongod --fork --logpath /var/log/mongodb/mongod.log --config /etc/mongod.conf --noauth && \
    sleep 5 && \
    mongo admin --eval "db.createUser({user: 'admin', pwd: 'adminpass', roles: ['root']}); db.shutdownServer();"

# Запускаем MongoDB с включенной авторизацией
CMD ["mongod", "--fork", "--logpath", "/var/log/mongodb/mongod.log", "--config", "/etc/mongod.conf"]



