FROM temporalio/web:latest

ENV TEMPORAL_PERMIT_WRITE_API=true

# uses Docker context $ROOT/temporal
COPY config/dynamicconfig.yaml /etc/temporal/dynamicconfig.yaml
