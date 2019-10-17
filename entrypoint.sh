#!/bin/sh
# Docker entrypoint script.

# Wait until Postgres is ready
while ! pg_isready -q -h $DB_HOST -p 5432 -U $DB_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

./prod/rel/web_and_iot/bin/web_and_iot eval AcqdatCore.Release.migrate
./prod/rel/web_and_iot/bin/web_and_iot start
