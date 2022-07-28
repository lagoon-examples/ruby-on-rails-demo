Start up tests
--------------

Run the following commands to get up and running with this example.

```bash
# Should remove any previous runs and poweroff
docker network inspect amazeeio-network >/dev/null || docker network create amazeeio-network
docker-compose down

# Should start up our Lagoon Drupal 9 site successfully
docker-compose build && docker-compose up -d

# Ensure postgres pod is ready to connect
docker run --rm --net ruby-on-rails_default amazeeio/dockerize dockerize -wait tcp://postgres:5432 -timeout 1m
```

Verification commands
---------------------

Run the following commands to validate things are rolling as they should.

```bash
# Should be able to site install via Drush
docker-compose exec -T ruby sh -c "rails db:migrate RAILS_ENV=development"

# Should have all the services we expect
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails_nginx_1
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails_postgres_1
docker ps --filter label=com.docker.compose.project=ruby-on-rails | grep Up | grep ruby-on-rails_ruby_1


# Should ssh against the ruby container by default
docker-compose exec -T ruby sh -c "env | grep LAGOON=" | grep ruby-on-rails_ruby_1

# Should have the correct environment set
docker-compose exec -T ruby sh -c "env" | grep LAGOON_ROUTE | grep ruby-on-rails.docker.amazee.io
docker-compose exec -T ruby sh -c "env" | grep LAGOON_ENVIRONMENT_TYPE | grep development

# Should be running Ruby 3
docker-compose exec -T ruby sh -c "ruby -v" | grep "ruby 3"

# Should have Puma
docker-compose exec -T ruby sh -c "puma --version"

# Should have gems - ruby & puma
docker-compose exec -T ruby sh -c "gem list -i puma | gem list -i ruby"

# Should have a running site served by nginx on port 8080
docker-compose exec -T ruby sh -c "curl -kL http://nginx:8080"

# Should be able to db-export and db-import the database
docker-compose exec -T ruby sh -c "rails db:schema:dump" # Creates a database schema file db/schema.rb
docker-compose exec -T ruby sh -c "rails db:drop" 
docker-compose exec -T ruby sh -c "rails db:create" 
docker-compose exec -T ruby sh -c "rails db:schema:load" # Loads a database schema file db/schema.rb

# Should be able to show the 'articles' tables
docker-compose exec -T ruby sh -c "echo \"ActiveRecord::Base.connection.table_exists? 'articles'\" | rails console"

# Should be able to rebuild and persist the database
docker-compose build && docker-compose up -d
docker-compose exec -T ruby sh -c "echo \"ActiveRecord::Base.connection.table_exists? 'articles'\" | rails console"

```

Destroy tests
-------------

Run the following commands to trash this app like nothing ever happened.

```bash
# Should be able to destroy our Drupal 9 site with success
docker-compose down --volumes --remove-orphans