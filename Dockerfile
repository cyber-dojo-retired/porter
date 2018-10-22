FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - - -

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19664 `# user-id`     \
  porter   `# user-name`

ARG                    PORTER_HOME=/app
COPY .               ${PORTER_HOME}
RUN  chown -R porter ${PORTER_HOME}

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > ${PORTER_HOME}/sha.txt

# - - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - - -

USER porter
EXPOSE 4517
CMD [ "./up.sh" ]

