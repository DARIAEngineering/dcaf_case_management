# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.

* **First things first**: Make a copy of your own to wrench on by forking! Go to https://github.com/DCAFEngineering/dcaf_case_management and hit the `fork` button up in the top right.
* **Second things second**: `git clone https://github.com/{YOUR GITHUB USERNAME}/dcaf_case_management` to pull it down to your local system
* **Third things third**: Add the source repo as the upstream with the command `git remote add upstream https://github.com/DCAFEngineering/dcaf_case_management`. This will let you update when the source repo changes by running the command `git pull upstream master`.
* **Fourth things fourth**: Make the source repo fetch-only by unsetting the URL: `git remote set-url --push upstream no-pushing-to-upstream`. This will prevent mistakenly pushing to upstream if you get push access down the road.

For the rest of the setup, you have two options: Docker, or installing everything locally. We recommend Docker if you're comfortable with its ecosystem.

## Docker

We've dockerized this app, to manage the dependencies and save us some headache. If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:

* `docker-compose build` (this may say 'uses an image, skipping' a few times, that's OK)
* `docker-compose run web rake db:seed # to populate the database`
* `docker-compose up`

The last command will take a moment and should print a number of things. When it's ready
to go, it should say something like:

    web_1  | [1] * Listening on tcp://0.0.0.0:3000

This runs the app on `localhost:3000` and you can hit it like a regular rails server. The first time you view a page will
take a minute or two for resources to compile and load, but it should eventually load. You can log in with the user `test@test.com` and the password `P4ssword`.

Any errors will show up in your terminal in the window you are running the `up` command in.

If the server won't start, it may not have cleanly shut down. Run `rm tmp/pids/server.pid` to remove the leftover server process and run `docker-compose up` again.

## Local environment

If you prefer a local environment, totally cool! We recommend the following:

### First, ruby dependencies
* Make sure you have a ruby version manager installed; we recommend either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/).
* Install our version of Ruby! You can see our current version of ruby in the `Gemfile`. Install it with `rbenv install VERSION` or `rvm install VERSION`, depending on what you're using.
* Run the command `gem install bundler && bundle install` to install dependencies, including `rails`.

### Then, MongoDB dependencies
You'll also need to set up MongoDB, which you can do as follows:
* Install MongoDB locally (`brew install mongodb`, for example, or the [linux instructions](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/))
* Create a folder in the root directory for the MongoDB database with the command `sudo mkdir -p /data/db`
* Allow for MongoDB read/write permissions by running `sudo chmod 777 /data/db`
* Open another terminal tab and run `mongod` to start up the database

### Then, showtime
After that:
* Once you've confirmed that you have `mongod` running in a separate tab, run `rake db:seed` to populate your database with test data
* Run the command `rails server` to start the rails server
* All set! Navigate your browser to `http://localhost:3000`. You can log in with the user `test@test.com` and the password `P4ssword`.

#### Troubleshooting MongoDB
Use 'Control + C' for both MongoDB and Rails to stop their servers from running. You can also stop MongoDB manually by killing the process running it. On a mac, open Activity Monitor and select 'mongoDB' under Process Name and then force it to quit by clicking the 'x' icon on the task bar above.


## Security

Checkout [this document](https://github.com/DCAFEngineering/dcaf_case_management/docs/SECURITY_INTRO.md) on Ruby on Rails security.
