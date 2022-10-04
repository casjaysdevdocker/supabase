## 👋 Welcome to supabase 🚀  

supabase README  
  
  
## Run container

```shell
dockermgr update supabase
```

### via command line

```shell
docker pull casjaysdevdocker/supabase:latest && \
docker run -d \
--restart always \
--name casjaysdevdocker-supabase \
--hostname casjaysdev-supabase \
-e TZ=${TIMEZONE:-America/New_York} \
-v $HOME/.local/share/srv/docker/supabase/files/data:/data:z \
-v $HOME/.local/share/srv/docker/supabase/files/config:/config:z \
-p 80:80 \
casjaysdevdocker/supabase:latest
```

### via docker-compose

```yaml
version: "2"
services:
  supabase:
    image: casjaysdevdocker/supabase
    container_name: supabase
    environment:
      - TZ=America/New_York
      - HOSTNAME=casjaysdev-supabase
    volumes:
      - $HOME/.local/share/srv/docker/supabase/files/data:/data:z
      - $HOME/.local/share/srv/docker/supabase/files/config:/config:z
    ports:
      - 80:80
    restart: always
```

## Authors  

🤖 casjay: [Github](https://github.com/casjay) [Docker](https://hub.docker.com/r/casjay) 🤖  
⛵ CasjaysDevDocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/r/casjaysdevdocker) ⛵  
