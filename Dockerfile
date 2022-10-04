FROM casjaysdevdocker/alpine:latest as build

ARG LICENSE=WTFPL \
  IMAGE_NAME=supabase \
  TIMEZONE=America/New_York \
  PORT=8090

ENV SHELL=/bin/bash \
  TERM=xterm-256color \
  HOSTNAME=${HOSTNAME:-casjaysdev-$IMAGE_NAME} \
  TZ=$TIMEZONE

RUN mkdir -p /bin/ /config/ /data/ && \
  arch="$(apk --print-arch)"; \
  rm -Rf /bin/.gitkeep /config/.gitkeep /data/.gitkeep && \
  apk update -U --no-cache && \
  apk add --no-cache unzip && \
  case "$arch" in \
  'x86_64') \
  DOWNLOAD_URL="https://github.com/pocketbase/pocketbase/releases/download/v0.7.9/pocketbase_0.7.9_linux_amd64.zip"; \
  ;; \
  'aarch64') \
  DOWNLOAD_URL="https://github.com/pocketbase/pocketbase/releases/download/v0.7.9/pocketbase_0.7.9_linux_arm64.zip"; \
  ;; \
  *) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
  esac; \
  wget -q "$DOWNLOAD_URL" -O "/tmp/pocketbase.zip" && \
  unzip -q "/tmp/pocketbase.zip" -d "/tmp/pocketbase" && \
  rm -Rf "/tmp/pocketbase.zip" && \
  mv -f "./pocketbase" "/usr/local/bin" && \
  chmod +x "/usr/local/bin/pocketbase"

COPY ./bin/. /usr/local/bin/
COPY ./config/. /config/
COPY ./data/. /data/

FROM scratch
ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')"

LABEL org.label-schema.name="supabase" \
  org.label-schema.description="Containerized version of supabase" \
  org.label-schema.url="https://hub.docker.com/r/casjaysdevdocker/supabase" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/supabase" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="$LICENSE" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="latest" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>"

ENV SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-supabase" \
  TZ="${TZ:-America/New_York}"

WORKDIR /root

VOLUME ["/root","/config","/data"]

EXPOSE $PORT

COPY --from=build /. /

ENTRYPOINT [ "tini", "--" ]
HEALTHCHECK CMD [ "/usr/local/bin/entrypoint-supabase.sh", "healthcheck" ]
CMD [ "/usr/local/bin/entrypoint-supabase.sh" ]
