# 🌱 Supplejack Docker
Docker implementation of Supplejack stack (API, Manager, Worker, MongoDB, Redis and Solr).

### Features
- Redis container
- Solr container
- Docker volumes for mongo and solr-index
- Supplejack worker container: rails
- Supplejack worker container: sidekiq
- Supplejack manager container
- Supplejack sample API container: rails
- Supplejack sample API container: sidekiq + crons for indexing

Note that the cronjob for indexing new records in to solr runs once per minute, as does the Solr autocommit.

### Prerequisites
- Docker
- Docker Compose

### Getting Started
1. [Install Docker, Docker Compose and dependencies](https://docs.docker.com/install/)

3. Clone this project recursively.

    ```bash
    → git clone --recursive git@github.com:digitalnz/supplejack_docker.git
    ```

### Running Docker Containers 🏁

1. Go to project directory.

    ```bash
    → cd supplejack_docker
    ```

2. Build Docker containers (This will take a while).

    ```bash
    → docker-compose build
    ```

3.  Run Docker containers (This will take a while as well).

    ```bash
    → docker-compose up
    ```

    If everything goes well, you should see all the containers running.

    ```bash
    → docker ps
    ```

    ```bash
    CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                    NAMES
    b82c59b64d2e        docker_sidekiq   "bundle exec sidekiq  "    57 seconds ago      Up 56 seconds                                sidekiq
    3ed5cf88d125        docker_worker    "bundle exec rails s  "   57 seconds ago      Up 56 seconds       0.0.0.0:3002->3000/tcp   worker
    7e92bb3df879        docker_manager   "bundle exec rails s  "   57 seconds ago      Up 56 seconds       0.0.0.0:3001->3000/tcp   manager
    ae32635f4802        docker_api       "bundle exec rails s  "   58 seconds ago      Up 57 seconds       0.0.0.0:3000->3000/tcp   api
    dad90c3e0039        redis:2.8         "docker-entrypoint.sh"   58 seconds ago      Up 57 seconds       0.0.0.0:6379->6379/tcp   redis
    a4e536734a7b        docker_solr      "bundle exec rake su.."    59 seconds ago      Up 57 seconds       0.0.0.0:8983->8983/tcp   solr
    47fba6738e23        mongo:3.6.8      "/entrypoint.sh mongo"   17 hours ago        Up 57 seconds       27017/tcp                supplejackdocker_mongodb_1
    ```

4. If you exit the docker process for any reason, make sure you run `docker-compose down` before running `docker-compose up` again.  This will ensure the PID'S are correctly reset.

### Seeding Data

The Supplejack components are connected by API keys. Before start using it, make sure to run the following commands to generate default users.

Make two users in the api:
1. a user for the harvester App (Supplejack Manager) in the **sample Api container**.
2. a normal api user in the sample Api container
```ruby
$ docker-compose exec api rails c

irb(main):001:0> SupplejackApi::User.create(email: 'info@email.com', password: 'password', password_confirmation: 'password', role: 'harvester', authentication_token: 'KJ64DC023FFO', name: 'harvester User', username: 'harvester User')

irb(main):002:0> SupplejackApi::User.create(email: 'developer@email.com', password: 'password', password_confirmation: 'password', role: 'developer', authentication_token: '82HYSEI92N0DGN28', name: 'Mr Jones', username: 'jonesy')

irb(main):003:0>exit
```


Make a user in the Supplejack Manager container with the following command (this is the user you will log in with:

```ruby
$ docker-compose exec manager rails c

irb(main):001:0> User.create(email: 'developer@email.com', name: 'Mr Jones', password: 'password', password_confirmation: 'password', role: 'admin')
irb(main):002:0> exit
```

This will generate the following user and keys.

```yaml
Manager:
    email: developer@email.com
    password: password
    authentication_token: '82HYSEI92N0DGN28'
# log in to the manager with this user

Worker:
    authentication_token: 'JK54SFJ94DAQQCB'

API:
    api_key: 'KJ64DC023FFO' - used for harvests
    api_key: '82HYSEI92N0DGN28' - used for normal api requests
```

Use the appropriate localhost ports to access the services:

```yaml
→ api: http://localhost:3000/records.json?api_key=82HYSEI92N0DGN28
→ manager: http://localhost:3001
→ worker: http://localhost:3002
→ sidekiq: http://localhost:3002/sidekiq
→ solr: http://localhost:8982/solr
```

### What's next?

- Get started with harvesting by creating your first parser.

    [http://digitalnz.github.io/supplejack/manager/introduction-to-parser-scripts.html](http://digitalnz.github.io/supplejack/manager/introduction-to-parser-scripts.html)
    
    or for a walk through, you can jump to step 6 of this guide:
    
    [http://digitalnz.github.io/supplejack/start/installation-walk-through-by-example.html#step-six](http://digitalnz.github.io/supplejack/start/installation-walk-through-by-example.html#step-six)

    visit [localhost:3001](http://localhost:3001), and sign in as developer@email.com as above, to get started.

- Know your Record Schema.

    This stack comes with a default [schema](https://github.com/DigitalNZ/supplejack_api_app/blob/master/app/supplejack_api/record_schema.rb) for you to get started.

    An example [parser](https://gist.github.com/hapiben/c904e581ea944b70533bb5fdf25efaa7) is also available to match the current Record Schema.


### Questions/Issues?
File a new [issue](https://github.com/digitalnz/supplejack_docker/issues/new) if you have questions or issues.

### Contributing

1. Fork it ( https://github.com/digitalnz/supplejack_docker/fork )
2. Create your feature branch (`git checkout -b my-awesome-feature`)
3. Commit your changes (`git commit -am 'Add my awesome feature!'`)
4. Push to the branch (`git push origin my-awesome-feature`)
5. Create a new Pull Request
