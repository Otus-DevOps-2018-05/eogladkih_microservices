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
