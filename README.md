# eogladkih_microservices
eogladkih microservices repository




## 14-Topic. HW Docker-1

1. Установлен Docker
2. Изучены основные команды и принципы работы с Docker
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


## 17-Topic. HW Docker-4


1. docker-compose.yml изменен под кейс со множеством сетей.
2. Выполнене параметризация параметров при помощи файла .env.
3. Для файла .env сделано исключение в gitignore и создан пример .env.example.
4. Создан файл docker-compose.override.yml при помощи которого можно переопределить некоторые параметры не требующие пересборки образов.
5. Реализован запуск запуска puma в режиме отладки с двумя воркерами.


Префикс берется из имени проекта. По умолчанию проект именутеся так же как и папка из которой он запускается.
Имя проекта можно изменить во время запуска проекта при помощи ключа -p. 
docker-compose -p somename up -d
В дальнейшем необходимо так же указывать имя проекта иначе ничего не отобразится и не удалится.
```
docker-compose -p somename ps 
docker-compose -p name down
```



## 18-Topic. HW GitLab-CI-1


1. Создана VM с устнаовленным GitLab-CI и runner.
2. При помощи terraform реализована подготовка небходимого нам количества VM для runner приложений. 
- задаем число нод с runner при помощи переменной num_of_nodes (1 - по умолчанию)
- ис директории ./gitlab-ci/infra/ запускаем terraform apply
3. При помощи ansible осуществляется установка всех зависимостей и регистрация runner приложений для всех VM с соответсвующим  тэгом.
- в ./gitlab-ci/infra/var.yml указываем наш ключ для регистрации runner
- запускаем ansible-playbook main.yml из директории ./gitlab-ci/infra/
4. Настроена отправка сообщений из Gitlab в slack канал #evgeny_gladkih



## 19-Topic. HW GitLab-CI-2


1. Расширен pipline предыдущего занятия.
2. Определены окружения.
3. При пуше любой ветки осущестяляется поиск VM с аналогичным именем в GCE. Если такой VM нет, то она создается.
Реализовано при помощи terraform и gce.py
4. В VM п.3 создается и запускается раннер gl_runner.
реализовано при помощи ansible
5. Все job, кроме последнего, выполняются в созданном раннере. Последний job выполняется в my-runner с тэгом default_runner.
6. Последний job выполняется вручную и позволяет удалить созданную VM.

Проблемы:
1. При удалении VM не удаляется запись о раннере в Gitlab. Он просто становится неактивным.
2. При пуше новой ветки часть job может выполняться не в одноименной VM т.к. область выполнения определяется тэгом раннера, а они совпадают.
3. gitlab не поддерживает определение tags через переменную.
4. gitlab не поддерживает определение tags черезе условие не такой тэг.
5. gitlab различает tag и tags, что не совсем логично.



## 20-Topic. HW Monitoring-1


1. Запущен prometheus
2. Настроен мониторинг состояния микросервисов (добавлены соответсвущие алиасы для mongo)
3. Настроен сбор метрик хоста с использованием экспортера 
4. Настроен мониторинг MongoDB при помощи xendera/mongodb-exporter
docker-compose.yml
```
  mongodb-exporter:
    image: xendera/mongodb-exporter
    container_name: mongodb-exporter
    hostname: mongodb-exporter
    networks:
      - back_net
    ports:
      - 9216:9216
    environment:
      - MONGODB_URL=mongodb://post_db
```
prometheus.yml
```
  - job_name: 'mongodb-exporter'
    static_configs:
      - targets:
        - 'mongodb-exporter:9216'
```
5. Добавлен blackbpx exporter и настроен мониторинг сервисов comment, ui, post.
docker-compose.yml
```
  black-box:
    image: prom/blackbox-exporter
    networks:
      - back_net
      - front_net
```
prometheus.yml
```
  - job_name: 'blackbox_http'
    metrics_path: /probe
    params:
      module: [http_2xx]  
    static_configs:
      - targets:
        - http://ui:9292 
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: black-box:9115  

  - job_name: 'blackbox_tcp'
    metrics_path: /probe
    params:
      module: [tcp_connect]  
    static_configs:
      - targets:
        - post:5000
        - comment:9292   
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: black-box:9115  
```
6. Полученные образы с нашими сервисами запушены в DockerHub.
https://hub.docker.com/r/eogladkih/



## 21-Topic. HW Monitoring-2


1. Выполнено разделение файла docker-compose на 2 (отельно все приложения, и отдельно все что связано с мониторингом)
docker-compose.yml и docker-compose-monitoring.yml

2. Настроен мониторинг Docker конйтейнеров 
Для наблюдения за состоянием Docker контейнеров используется cadvisor.
docker-compose-monitoring:
```
...
cadvisor:
  image: google/cadvisor:v0.29.0
  volumes:
    - '/:/rootfs:ro'
    - '/var/run:/var/run:rw'
    - '/sys:/sys:ro'
    - '/var/lib/docker/:/var/lib/docker:ro'
  ports:
    - '8080:8080'
```
prometheus.yml
```
...
  - job_name:'cadvisor'
    static_configs:
      - targets:
        - 'cadvisor:8080'
```

3. Настроена визуализация метрик
Для визуализации используется Grafana.
docker-compose-monitoring.yml
```
services:

  grafana:
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000

volumes:
  grafana_data:
```

4. Организован сбор метрик приложения и бизнес метрик
Созданы 3 графика в дашборде UI_Service_Monitoring:
 - UI http requests
 - Rate of UI HTTP Requests with Error
 - HTTP response time 95th percentile
 
5. Настроен и проверен алертинг
В качестве системы алертинга используется alertmanager, а уведомления о проблемах отсылаются в slack канал.

6. Созданы все необходимые разрешения в firewall gcloud.
Созданы следующие разрешения:
 - gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
 - gcloud compute firewall-rules create grafana-default --allow tcp:3000
 - gcloud compute firewall-rules create alertmanger-default --allow tcp:9093
 
7. Все Images добавлены в DockerHub.
 - docker push $USER_NAME/ui
 - docker push $USER_NAME/comment
 - docker push $USER_NAME/post
 - docker push $USER_NAME/prometheus
 - docker push $USER_NAME/alertmanager



## 22-Topic. HW Logging-1


1. Добавлен конфигурационный файл docker/docker-compose-logging.yml при помощи которого создаются контейнеры для elasticsearch, fluentd, kibana и zipkin.
2. Обновлены файлы приложения /src.
3. В файле logging/fluentd/fluent.conf определены параметры преобразования (парсинга) логов для приложений post и ui.
4. Реализован разбор логов разной структуры для приложения ui.
```
<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{URIPATH:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IP:remote_addr} \| method=%{GREEDYDATA:method} \| response_status=%{NUMBER:response_status}
  key_name message
  reserve_data true
</filter>
```
5. В рамках поиска ошибок в работе bugged приложения при помощи ziprin определено, что все праблемы связвны с подключением сервисов.
Анализ файлов приложений выявил, что в соответвующих файлах Dockerfile отутсовали неолбходимые для нормальной работы параметры ENV.
6. Образы для логирования (тэг logging) запушены в docker hub - https://hub.docker.com/r/eogladkih/
