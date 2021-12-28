FROM temporalio/server:latest


# Switch to root user
# https://community.render.com/t/permission-denied-for-secret-file/3036/2?u=swyx
USER root

# Set environment variables to interpolate into the Docker image's config
# template.
# https://github.com/temporalio/temporal/blob/master/docker/config_template.yaml
ENV DB=postgresql
ENV SQL_TLS_ENABLED=true