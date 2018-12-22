FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19664 `# user-id`     \
  -G nogroup `# group`     \
  porter   `# user-name`

WORKDIR /app
COPY . .
RUN chown -R porter .

ARG SHA
ENV SHA=${SHA}

EXPOSE 4517
USER porter
CMD [ "./up.sh" ]
