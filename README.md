# Chichavl_microservices
Chichavl microservices repository

# Основные комманды Docker
`docker version` - версия docker
`docker run hello-world` - запустить контейнер hello-world
`docker ps` - список запущенных контейнеров
`docker ps -a` - список всех контейнеров
`docker images` - список сохраненных образов

# Переопределение переменных окружения контейнера

```
docker run -d --network=reddit \
--network-alias=post_db_prod \
--network-alias=comment_db_prod mongo:latest
 
docker run -d -e "POST_DATABASE_HOST=post_db_prod" \
--network=reddit \
--network-alias=post chichavl/post:1.0
 
docker run -d -e "COMMENT_DATABASE_HOST=comment_db_prod" \
--network=reddit \
--network-alias=comment chichavl/comment:1.0
 
docker run -d --network=reddit \
-p 9292:9292 chichavl/ui:1.0
```

# Еще уменьшение образа ui (102 мб)
Уменьшение достигается удалением после сборки, пакетов, которые нужны только для сборки, а не работы приложения.

```
FROM ruby:alpine

ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/

# install build tools
RUN apk add --no-cache build-base \
    # install dependencies
    && bundle install \
    # remove build tools
    && apk del build-base
    
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]
```

Вывод `docker images`

```
[chichavl@ns327859 Chichavl_microservices]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
chichavl/ui         2.1                 8585098af173        5 minutes ago       102MB
chichavl/ui         2.0                 90c672d63ff3        15 hours ago        249MB
chichavl/ui         1.0                 8228fe2bf115        19 hours ago        776MB
```

# Переопределение имени проекта
Имя проекта можно переопределить переменной окружения `COMPOSE_PROJECT_NAME`

# Создание экземпляра GitLab
Использование:
Экспортируем идентификатор проекта GCP
```
export GOOGLE_PROJECT=docker-000000
```

Запускаем скрипт `create.sh`. Он создат новый докер хост через docker-machine в GCP. Запустит на нем контейнер gitlab.

```
[chichavl@ns327859 Chichavl_microservices]$ cat create.sh
#!/bin/bash

docker-machine create --driver google \
--google-machine-image  https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west1-b \
--google-tags gitlab \
docker-host

eval $(docker-machine env docker-host)

IP=$(docker-machine ip docker-host)

docker run --detach \
    --hostname gitlab.example.com \
    --env GITLAB_OMNIBUS_CONFIG="external_url 'http://$IP'" \
    --publish 443:443 --publish 80:80 --publish 2222:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest

echo "Gitlab external ip: $IP"

```

# Создание GitLab runner
Использование:
Экспортируем авторизационный токен для гитлаба
```
export GL_TOKEN=so***************Ex
```
Запускаем скрипт `create_runner.sh`. Он запустит и настроит агента на докер хосте, созданном скриптом `create.sh`.

```
eval $(docker-machine env docker-host)

GL_IP=$(docker-machine ip docker-host)

docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest

docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://$IP/" \
  --registration-token "$GL_TOKEN" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged \
  --locked="false" \
  --executor "docker" \
  --docker-image alpine:latest
```

