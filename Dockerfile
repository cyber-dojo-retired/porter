FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19664 `# user-id`     \
  porter   `# user-name`

COPY . /app
RUN chown -R porter /app

ARG SHA
ENV SHA=${SHA}

EXPOSE 4517
USER porter
CMD [ "./up.sh" ]
