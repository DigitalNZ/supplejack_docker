# Supplejack Docker
# ![](http://digitalnz.github.io/supplejack/images/supplejack_logo.png)
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
- Setup Guide found [here](http://digitalnz.github.io/supplejack/start_docker/docker-setup.html)

### Questions/Issues?
File a new [issue](https://github.com/digitalnz/supplejack_docker/issues/new) if you have questions or issues.

### Contributing

1. Fork it ( https://github.com/digitalnz/supplejack_docker/fork )
2. Create your feature branch (`git checkout -b my-awesome-feature`)
3. Commit your changes (`git commit -am 'Add my awesome feature!'`)
4. Push to the branch (`git push origin my-awesome-feature`)
5. Create a new Pull Request
