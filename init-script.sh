#!/bin/bash

# Удалить файл блокировки, если он существует
rm -f /var/lib/mongodb/mongod.lock

# Запуск MongoDB без включенной авторизации
mongod --logpath /var/log/mongodb/mongod.log --config /etc/mongod.conf --noauth

# Ожидаем, пока MongoDB запустится
sleep 5

# Создание пользователя в базе данных "admin"
mongo admin --eval "db.createUser({user: 'admin', pwd: 'adminpass', roles: ['root']});"

# Остановка MongoDB
mongod --shutdown

# Запуск MongoDB с включенной авторизацией
mongod --logpath /var/log/mongodb/mongod.log --config /etc/mongod.conf

# КОННЕКТ ПОСЛЕ ЗАПУСКА КОНТЕЙНЕРА
# mongo -u admin -p adminpass --authenticationDatabase admin


