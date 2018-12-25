FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .
RUN chown -R nobody:nogroup .

USER nobody
EXPOSE 4518
CMD [ "./up.sh" ]
