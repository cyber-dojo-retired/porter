FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG                            SAVER_HOME=/app
COPY .                       ${SAVER_HOME}
RUN  chown -R nobody:nogroup ${SAVER_HOME}
USER nobody
EXPOSE 4598
CMD [ "./up.sh" ]
