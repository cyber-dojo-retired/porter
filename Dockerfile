FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19664 `# user-id`     \
  porter   `# user-name`

ARG                    PORTER_HOME=/app
COPY .               ${PORTER_HOME}
RUN  chown -R porter ${PORTER_HOME}

ARG SHA
RUN echo ${SHA} > ${PORTER_HOME}/sha.txt

EXPOSE 4517
USER porter
CMD [ "./up.sh" ]
