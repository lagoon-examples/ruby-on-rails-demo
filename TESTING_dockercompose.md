Docker Compose Ruby on Rails - ruby3.1, nginx, postgres
========================================================

This is a docker compose version of the Lando example tests:

Start up tests
--------------

Run the following commands to get up and running with this example.

```bash
# Should remove any previous runs and poweroff
docker network inspect amazeeio-network >/dev/null || docker network create amazeeio-network
docker compose down

# Should start up our Lagoon ruby on rails site successfully
docker compose build && docker compose up -d

# Ensure postgres pod is ready to connect, then sleep for 60s
docker run --rm --net ruby-on-rails_default amazeeio/dockerize dockerize -wait tcp://postgres:5432 -timeout 1m
sleep 60
```

Verification commands
---------------------

Run the following commands to validate things are rolling as they should.

```bash
# Should set the Rails ENV
docker compose exec -T ruby sh -c "rails db:migrate RAILS_ENV=development"

# Should have all the services we expect
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails-nginx-1
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails-postgres-1
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails-ruby-1

# Should ssh against the ruby container by default
docker compose exec -T ruby sh -c "env | grep LAGOON=" | grep ruby

# Should have the correct environment set
docker compose exec -T ruby sh -c "env" | grep LAGOON_ROUTE | grep ruby-on-rails.docker.amazee.io

# Should be running Ruby 3
docker compose exec -T ruby sh -c "ruby -v" | grep "ruby 3"

# Should have Puma
docker compose exec -T ruby sh -c "puma --version"

# Should have gems - ruby & puma
docker compose exec -T ruby sh -c "gem list -i puma | gem list -i ruby"

# Should have a running site served by nginx on port 8080
docker compose exec -T ruby sh -c "curl -kL http://nginx:8080" | grep "Articles"

# Should be able to db-export and db-import the database
docker compose exec -T ruby sh -c "rails db:schema:dump" # Creates a database schema file db/schema.rb
docker compose exec -T ruby sh -c "rails db:drop" 
docker compose exec -T ruby sh -c "rails db:create" 
docker compose exec -T ruby sh -c "rails db:schema:load" # Loads a database schema file db/schema.rb

# Should be able to show the 'articles' tables
docker compose exec -T ruby sh -c "echo QWN0aXZlUmVjb3JkOjpCYXNlLmNvbm5lY3Rpb24udGFibGVfZXhpc3RzPyAnYXJ0aWNsZXMnCg== | base64 -d | rails console"

# Should be able to rebuild and persist the database
docker compose build && docker compose up -d
docker compose exec -T ruby sh -c "echo QWN0aXZlUmVjb3JkOjpCYXNlLmNvbm5lY3Rpb24udGFibGVfZXhpc3RzPyAnYXJ0aWNsZXMnCg== | base64 -d | rails console"
```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be able to destroy our rails site with success
docker compose down --volumes --remove-orphans
```
