# Chichavl_microservices
Chichavl microservices repository

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

