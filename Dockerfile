FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# group`       \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19664         `# user-id`     \
  porter           `# user-name`

WORKDIR /app
COPY . .
RUN chown -R porter .

ARG SHA
ENV SHA=${SHA}

EXPOSE 4517
USER porter
CMD [ "./up.sh" ]
