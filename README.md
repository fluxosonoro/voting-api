BillIt (RESTful API)
===================

# API Design and Features

The API is designed as a very thin layer over MongoDB. Each collection of data has a single URL endpoint. For example, data from the "proyectos" collection can be found by doing a GET request to:

    /bills

This will return a page of proyectos in JSON form, in order of their creation in the database. The query that fetches these proyectos can be controlled in a number of ways.


# GET operations


## Ordering

To control the sort order of results:

    /bills?sort=id
    /bills?sort=id&order=asc
    /bills?sort=id&order=desc


## Pagination

By default, results are paginated to 20 items per page, and the first page is returned. To control pagination:

    /bills?per_page=10&page=2

All results also return a "count" field that lists how many total items match the query, and a "page" object with four subfields: the actual"page" and "per_page" values that were used in the query, a "total" field that has the total of pages availables, and a "count" field that has the actual number of items returned (this is useful if there are fewer items in the results for that page than the "per_page" parameter specifies).


## Filtering

Results can be filtered by specifying fields and values. For example, to return all proyectos whose "iniciativa" field is "Mensaje":

    /bills?creation_date=01-01-1990

Filters can be combined, and used alongside other parameters:

    /bills?creation_date=01-01-1990&tags=health&sort=creation_date

The API will try to infer the type of the values that are given. Values that contain only digits will be interpreted as numbers, and timestamps of the format "YYYY-MM-DD" or that begin with "YYYY-MM-DDTHH:MM:SS" will be interpreted as Time objects. "true" and "false" will be interpreted as booleans.

To override these assumptions for a particular field, you can declare the field's type in that model's Mongoid declaration, and no type inference will be done for the given value.

This is not implemented yet, but the filtering could be easily extended to add operators to allow for more powerful filtering, such as the use of regular expressions, or asking for a field to be greater than or less than a given value.


## Partial responses

To return only specific fields for each result, specify a comma-separated list of fields. You can specify nested fields by using the dot operator.

    /bills?fields=matters,tags,summary,title


## Query explanation

To see an explanation, in JSON, of how the API transforms the parameters you provide into a MongoDB query, provide an "explain" parameter. This is meant for debugging, and will only return the explanation, not the results.

    /bills?explain=true

This will return the fields, conditions, sort parameters, and pagination information that were used to form the query, and the formal database explanation for how that query is processed.


## JSONP

JSON results can be returned with a function callback wrapped around the results, for use in "JSONP", a method for retrieving data from remote services through embedded JavaScript. To trigger this, send in a "callback" parameter with the name of the JavaScript function name you want wrapped around the results.

    /bills?callback=myCallback

If you use jQuery's AJAX methods, it will take care of this automatically for you, but will also add a "_" parameter with a timestamp value that acts as a "cache-buster". This API will not do anything special when it sees this parameter, but it knows to ignore it and to not try to filter results based on a field named "_".

# POST, PUT and DELETE

For the follows operations execute this curl lines from a terminal. Replace 'api.billit.com' with the domain of your installation.

## POST

    $ curl -i -H "Accept: application/json" -X POST "http://api.billit.com/bills?id=1&title=Education&summary=''&tags=example|test&matters=education|chile|loce|university&stage=waiting&creation_date=2011-09-18&publish_date=2012-05-09&authors='Joaquin Lavin'&origin_chamber=Diputados"


## PUT

    $ curl -i -H "Accept: application/json" -X PUT "http://api.billit.com/bills?id=1&title=Education&summary=''&tags=example|test&matters=education|chile|loce|university&stage=waiting&creation_date=2011-09-18&publish_date=2012-05-09&authors='Joaquin Lavin'&origin_chamber=Senado"

## DELETE

    
    $ curl -i -H "Accept: application/json" -X DELETE "http://api.billit.com/bills?id=1"


Installation
-----------


# Dependencies

Dependencies (Ruby gems) are managed using Bundler. Most Ruby gems that a project needs do not need to be installed to the system for the project to function. However, the Rubygems program itself must be installed to the system, and the "bundler" gem must be installed by Rubygems to either the system or to the local user account.

Once Rubygems and the "bundler" gem are installed, a file called "Gemfile" must be created in the root of the project. The Gemfile specifies the dependencies, and an example Gemfile looks like this:

    source 'http://rubygems.org'
    
    gem 'json', '1.5.3'
    gem 'sinatra', '1.2.6'

To install dependencies to a project for the first time:

    bundle install --path=vendor/gems

This will install the gems listed in the Gemfile, and any sub-dependencies, into the "vendor/gems" directory in the project. The "vendor/gems" directory should be ignored in git, as you want the gems to be re-installed on every environment the app is deployed in.

However, you can cache the specific gem files you use so that you do not have to access the Internet for future deployments. By using:

    bundle pack

This will create a "vendor/cache" directory which contains .gem files of all dependencies. This *can* be committed to the repository, and future dependency installation can be accomplished directly from those .gem files by using:

    bundle install --path=vendor/gems --local

This is particularly useful when automating deployment of code to a remote system.


# Console

In order to get a console, create or update your $HOME/.irbrc file with this:

    # use rubygems
    require 'rubygems'
    
    # load in project-specific dependencies through bundler
    require 'bundler/setup'
    
    # load in that project's environment if it exists
    require 'config/environment' if File.exists?('config/environment.rb')

And then in the project directory, type "irb". The app will load its environment, and you will see an error if it cannot connect to the database. You can reference models and make database queries through the ORM, or run any Ruby you want.

    >> Bill.count
    => 0
    >> Bill.create!(:title => "Proyecto de ley en materia de duración del descanso de maternidad.")
    => #<Proyecto _id: 4e7cae54ae85c114b4000001, created_at: Fri Sep 23 16:05:40 UTC 2011, updated_at: Fri Sep 23 16:05:40 UTC 2011, _type: nil, title: "Proyecto de ley en materia de duraci\303\263n del descanso de maternidad.">
    >> Proyecto.count
    => 1

# Running the app

Sinatra apps can be run using any system that supports Rack apps. You can run it using Unicorn on both development and production.

Unicorn is a part of the Gemfile for this application. To run unicorn in development, run:

    bundle exec unicorn

This will run the app on http://localhost:8080 by default. To change the port, add a --port flag.

To run unicorn in production, first install the "rack" gem to your system, using the same version that is required by the Gemfile. Then install the "unicorn" gem to your system.

If you're using the same system to host different apps that use different versions of rack, you may find it more convenient to install rack and/or unicorn to the user, and not the system. This requires exporting the GEM_HOME environment variable to add a user-editable directory to the gem path. For example:

    export GEM_HOME=$HOME/.gem/ruby/1.8

You can test this by running "gem env" and seeing this directory included under "GEM PATHS". You can then install gems system-wide by running "sudo gem install [gemname]" and install gems user-wide by running "gem install [gemname]".

Once you've installed unicorn and rack, you can instruct unicorn to listen to a UNIX socket and run as a daemon by running:

    unicorn -l ~/wherever/app_name.sock -D

You can also define a unicorn.rb config file and use it to specify a PID file - rather than document that here, it's better to refer to the documentation:

http://unicorn.bogomips.org/
