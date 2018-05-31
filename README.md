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

