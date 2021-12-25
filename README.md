# temporal-render

Example repo to show how to deploy Temporal to Render.com

### One Click

Use the button below to deploy Temporal on Render.

[![Deploy to Render](http://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

## creation notes

- render doesnt support docker compose
- [render doesnt support creating a database](https://community.render.com/t/impossible-prisma-postgresql-schema-migration/1128/5)
  - therefore we MUST specify DBNAME same as POSTGRES_USER name [per our own setup script](https://github.com/temporalio/temporal/blob/master/docker/auto-setup.sh#L178)
