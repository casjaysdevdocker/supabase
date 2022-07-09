FROM casjaysdevdocker/alpine:latest
ARG BUILD_DATE="$(date +'%Y-%m-%d %H:%M')" 

RUN apk -U upgrade && apk add supabase

LABEL \
  org.label-schema.name="supabase" \
  org.label-schema.description="supabase container based on Alpine Linux" \
  org.label-schema.url="https://hub.docker.com/r/casjaysdevdocker/supabase" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/supabase" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.version=$BUILD_DATE \
  org.label-schema.vcs-ref=$BUILD_DATE \
  org.label-schema.license="WTFPL" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="latest" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>" 


HEALTHCHECK NONE

ENTRYPOINT [ "true" ]
