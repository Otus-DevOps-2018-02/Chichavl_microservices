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
