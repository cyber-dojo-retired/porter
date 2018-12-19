FROM  docker:latest
LABEL maintainer=jon@jaggersoft.com

RUN apk add bash

COPY . /app

ENTRYPOINT [ "/app/insert.sh" ]
