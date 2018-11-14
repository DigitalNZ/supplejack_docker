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

### Example harvest

Log into your manager at [localhost:3001](http://localhost:3001) and click ‘New Data Source’, give it a **name** and a **contributor**.

Once it completes, hover over ‘Contributors and Scripts’ in the top navigation, click ‘Parser Scripts’, and then click ‘New Parser Script’.

Name your parser, `Otago Hocken`, select the contributor and data source that you created before, and then choose OAI format.

The click ‘Create Parser Script’.

You will now have a screen which will allow you to write your parser script for the harvester, this parser is written in Ruby and has it’s own DSL.[The documentation for the parser DSL can be found here](http://digitalnz.github.io/supplejack/)

Make your parser look like this:


```ruby
class OtagoHocken < SupplejackCommon::Oai::Base
  base_url "http://otago.ourheritage.ac.nz/oai-pmh-repository/request"
  validates :usage, inclusion: {in: ["Share", "Modify", "Use commercially", "All rights reserved", "Unknown"]}

  validates :landing_url, format: {with: /\Ahttps?:/}
  validates :thumbnail_url, format: {with: /\Ahttps?:/}
  validates :large_thumbnail_url, format: {with: /\Ahttps?:/}
  validates :landing_url, size: { is: 1 }
  validates :internal_identifier, size: { is: 1 }

  namespaces dc: 'http://purl.org/dc/elements/1.1/',
             oai_dc: 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                    xsi: 'http://www.w3.org/2001/XMLSchema-instance',
            dcterms: 'http://purl.org/dc/terms/',
                        o: 'http://www.openarchives.org/OAI/2.0/'

  attributes :content_partner, :display_content_partner,     default: "University of Otago"
  attributes :display_collection, :primary_collection,       default: "Otago University Research Heritage"
  attribute  :collection,                                                                  default: ["Otago University Research Heritage"]
  attributes :copyright, :usage,                             default: "All rights reserved"
  attributes :dc_rights, :rights_url,                        default: "http://digital.otago.ac.nz/terms.php"
  #attribute :dc_type, default: "Watercolors"

  attribute :title,         xpath: "//dc:title"
  attribute :description,   xpath: "//dc:description"
  attribute :date,          xpath: "//dc:date",        date: true
  attribute :display_date,  xpath: "//dc:date"
  attribute :contributor,   xpath: "//dc:contributor"
  attribute :publisher,     xpath: "//dc:publisher"
  attribute :subject,         xpath: "//dc:subject"
  attribute :source,          xpath: "//dc:source"
  attribute :creator,         xpath: "//dc:creator"
  attribute :dc_type,         xpath: "//dc:type"
  attribute :format,          xpath: "//dc:format"

  attribute :category do
    category = "Images"
    category = "Videos" if get(:dc_type).find_with(/^Video$/).present?
    category
  end

  attributes :landing_url do
    fetch("//dc:identifier").find_with(/^http:\/\/otago.ourheritage.ac.nz\/items\/show/)
  end

  attribute :internal_identifier do
    get(:landing_url).downcase
  end

  attributes :large_thumbnail_url do
    fetch("//dc:identifier").find_with(/\.jpg$/).mapping(/original/ => 'fullsize').first
  end

  attributes :thumbnail_url do
    get(:large_thumbnail_url).mapping(/fullsize/ => 'square_thumbnails')
  end

  attribute :dc_identifier do
    dcidentifier = get(:dc_identifier)
    dcidentifier += fetch("//header/identifier")
    dcidentifier += fetch("//metadata//identifier").find_without(/^http/)
    dcidentifier
  end

  reject_if do
    not get(:landing_url).find_with(/^http/i).present?
  end
end
```

You should now be able to preview your parser! Click the preview button and the various components of Supplejack will whurr into a working state.

If your preview is successful, you will see a modal window appear a json object of the potential records. Something like this:

```json
{
  "priority": 0,
  "match_concepts": null,
  "content_partner": [
    "University of Otago"
  ],
  "display_content_partner": [
    "University of Otago"
  ],
  "display_collection": [
    "Otago University Research Heritage"
  ],
  "primary_collection": [
    "Otago University Research Heritage"
  ],
  "collection": [
    "Otago University Research Heritage"
  ],
  "copyright": [
    "All rights reserved"
  ],
  "usage": [
    "All rights reserved"
  ],
  "dc_rights": [
    "http://digital.otago.ac.nz/terms.php"
  ],
  "rights_url": [
    "http://digital.otago.ac.nz/terms.php"
  ],
  "title": [
    "Gog and Magog, Stewart Island. 1880."
  ],
  "description": [
    "Lower left (l.l.) in ink: W. Deverell Jany 1880; margin below image in pencil: Gog &amp; Magog Stewart Island."
  ],
  "date": [

  ],
  "display_date": [

  ],
  "contributor": [

  ],
  "publisher": [

  ],
  "subject": [
    "Islands",
    "Landscape"
  ],
  "source": [
    "Found uncatalogued in Hocken 1947. Dr T.M. Hocken’s Collection"
  ],
  "creator": [
    "unknown"
  ],
  "dc_type": [
    "Image",
    "Still Image",
    "Watercolors",
    "Art"
  ],
  "format": [

  ],
  "category": [
    "Images"
  ],
  "landing_url": [
    "http://otago.ourheritage.ac.nz/items/show/4480"
  ],
  "internal_identifier": [
    "http://otago.ourheritage.ac.nz/items/show/4480"
  ],
  "large_thumbnail_url": [
    "http://s3.amazonaws.com/ourheritagemedia%2Ffullsize%2Fa24297b36e4d17d4b8bd4da8f7d6bb6c.jpg"
  ],
  "thumbnail_url": [
    "http://s3.amazonaws.com/ourheritagemedia%2Fsquare_thumbnails%2Fa24297b36e4d17d4b8bd4da8f7d6bb6c.jpg"
  ],
  "dc_identifier": [
    "oai:otago.ourheritage.ac.nz:4480"
  ],
  "source_id": "otago-hocken",
  "data_type": "record"
}
```

If you have a successful preview, close the modal window, scroll to the bottom of the page, enter some text in the message field (this is for parser version control), and click Update Parser Script.  Next, in the righthand columns, click on the name of your parser script under **History**, then click the blue button **Tag as Staging**.

You can now run a staging harvest, note that ‘Staging’ is a term bound to the Manager and does not relate to the Rails environment.

Click ‘Run Harvest’, and then click ‘Staging Harvest’, enter 50, and then click start.


Once the harvest is complete, it will take up to a minute for records to appear in solr, and the api response (indexing and solr auto-commit is set to every 60s)

You can now see your records on the API! Go to [http://localhost:3000/records.json?api_key=82HYSEI92N0DGN28](http://localhost:3000/records.json?api_key=82HYSEI92N0DGN28) to see the serialized JSON response.

You can also see them directly in solr at [http://localhost:8982/solr/#/development/query](http://localhost:8982/solr/#/development/query) and [http://localhost:8982/solr/development/select?q=*%3A*&wt=json&indent=true](http://localhost:8982/solr/#/development/query)

### What's next?

- Get started with harvesting by creating your first parser.

    [http://digitalnz.github.io/supplejack/manager/introduction-to-parser-scripts.html](http://digitalnz.github.io/supplejack/manager/introduction-to-parser-scripts.html)


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
