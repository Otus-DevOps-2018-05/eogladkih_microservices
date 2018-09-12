# eogladkih_microservices
eogladkih microservices repository




## 14-Topic. HW Docker-1

1. Установлен Docker
2. Изучены основные комынды и принципы работы с Docker
3. Проанализированы различия между образом и контейнером


## 15-Topic. HW Docker-2

1. В GCE создан новый проект для работы с Docker.
2. Создан и отправлен в HUB образ для Docker с установленным приложением.
3. Создан playbook устанавливающий Docker на хост и playbook разварачивающий на хосте контейнер из пп2.
Docker_install.yml и Docker_container_up.yml соответсевенно.
4. Настроена динамическая инвентаризация при промощи скрипта gce.py и secrets.py.
5. Реализована возможность разварачивать небходимое количество хостов в GCE при помощи terraform.
При помощи переменной num_of_nodes можно указать необходимое количество хостов(1 по умолчанию).
6. При помощи Packer можно создать образ ОС с установленным Docker.


## 16-Topic. HW Docker-3

1. Приложение разбито на несколько компонент 
2. Приложение запущено как микросервисное 
3. Произведена оптимизация dockerfile

```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db_2 --network-alias=comment_db_2 mongo:latest
docker run -d --network=reddit --network-alias=post_2 -e POST_DATABASE_HOST=post_db_2 eogladkih/post:1.0  
docker run -d --network=reddit --network-alias=comment_2 -e COMMENT_DATABASE_HOST=comment_db_2 eogladkih/comment:1.0  
docker run -d --network=reddit -p 9292:9292 -e POST_SERVICE_HOST=post_2 -e COMMENT_SERVICE_HOST=comment_2 eogladkih/ui:1.0 
```
