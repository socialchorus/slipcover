# Slipcover

Slipcover is a really lite wrapper around CouchDB. It comes with a Railtie to get your Rails app setup fast.
It is YAML configured allowing easy connection to servers, without imposing database constraints ... since
one of the best parts of CouchDB is the ease at which you can create new databases.

## Installation

Add this line to your application's Gemfile:

    gem 'slipcover'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slipcover

## Usage

### With Rails
Put a `slipcover.yml` in your config directory. Here is a sample:

    development:
      host: 127.0.0.1
      port: 5984

    production:
      host: socialcoders.couchservice.com
      username: COUCH_USERNAME
      password: COUCH_PASSWORD

COUCH_USERNAME/PASSWORD are the keys for the username and password in your env.

#### Create a database:

    Slipcover::Database.new('my_database_name').create

This will create a database with the Rails environment appended to the back of it: `database_name_development`.
This is a great convenience for testing etc, since you can create many database on the fly and they won't conflict
with development or other databases of the same name.

#### Create some documents:

    doc = Slipcover::Document.new('my_database_name', {foo: ['a', 'row', 'of', 'bars']})
    doc.save

#### Write views is js to query them:

Create a directory inside the Rails app called: `slipcover_views`. Organize each view/index in its own directory with a `map.js`
file. Where appropriate also add a `reduce.js` function. Since these files are real js files, they can be tested via Jasmine,
or your favorite testing framework.

#### Put a design document in your database to capture these views/indexes

    design_doc = Slipcover::DesignDocument.new('my_database_name', 'design_it_good')
    design_doc.save

It constructs views from the default app/slipcover_views directory. If you want to customize where the views live, do some
dependency injection:

    design_doc = Slipcover::DesignDocument.new('my_database_name', 'degign_it_good', my_custom_directory)
    design_doc.save

#### Query Data

    desgin_document = Slipcover::DesignDocument.new('my_database_name', 'degign_it_good')
    query = Slipcover::Query.new(design_document, view_name)
    query.all
    query.all(key: 'foo')

### Usages Sans-Rails

Put a YAML configuration file where it seems appropriate. Configure slipcover so that it knows where your YAML is:

    Slipcover::Config.yaml_path = my_special_place

Let Slipcover know what environment your are operating under:

    Slipcover.env = 'staging'

When constructing databases, Slipcover will use your yaml and environmental configuration to setup the right server.

If you are looking for more freedom, you can created databases with an optional second argument that is a server.

The slipcover views can also be put wherever you want and configured in at the Slipcover::Config level or the individual
design document.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
