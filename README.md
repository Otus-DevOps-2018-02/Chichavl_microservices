# Chichavl_microservices
Chichavl microservices repository

# Основные комманды Docker
`docker version` - версия docker
`docker run hello-world` - запустить контейнер hello-world
`docker ps` - список запущенных контейнеров
`docker ps -a` - список всех контейнеров
`docker images` - список сохраненных образов

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

