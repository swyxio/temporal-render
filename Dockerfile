FROM temporalio/base-server:1.14.1

# # https://github.com/arniebilloo/test/blob/8e52f7b1647c7b0f55b67f432358936f863ae1a4/multiple.Dockerfile
# WORKDIR /etc/temporal
# ENV TEMPORAL_HOME /etc/temporal
# ENV SERVICES "history:matching:frontend:worker"
# EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

# RUN addgroup -g 1000 temporal
# RUN adduser -u 1000 -G temporal -D temporal
# RUN mkdir /etc/temporal/config
# RUN chown -R temporal:temporal /etc/temporal/config

# actually do work
COPY custom-auto-setup.sh .
COPY entrypoint.sh .
CMD ["entrypoint.sh"]
