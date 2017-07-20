# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.

* **First things first**: Make a copy of your own to wrench on by forking! Go to https://github.com/DCAFEngineering/dcaf_case_management and hit the `fork` button up in the top right.
* **Second things second**: `git clone https://github.com/{YOUR GITHUB USERNAME}/dcaf_case_management` to pull it down to your local system
* **Third things third**: Add the source repo as the upstream with the command `git remote add upstream https://github.com/DCAFEngineering/dcaf_case_management`. This will let you update when the source repo changes by running the command `git pull upstream master`.
* **Fourth things fourth**: Make the source repo fetch-only by unsetting the URL: `git remote set-url --push upstream no-pushing-to-upstream`. This will prevent mistakenly pushing to upstream if you get push access down the road.

For the rest of the setup, you have three options: Docker, installing everything locally, or Cloud9. We recommend Docker if you're comfortable with its ecosystem.

## Docker

We've dockerized this app, to manage the dependencies and save us some headache. If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:

* `docker-compose pull`
* `docker-compose build` (this may say 'uses an image, skipping' a few times, that's OK)
* `docker-compose run web rake db:seed # to populate the database`
* `docker-compose up`

The last command will take a moment and should print a number of things. When it's ready
to go, it should say something like:

    web_1  | [1] * Listening on tcp://0.0.0.0:3000

In order to connect to the application you will need the IP address of your Docker instance.
This can be found with the `docker-machine ip default` command. With the IP, and the port
from the output of the original `up` command, you can now go to your browser and navigate
to the application.

For example, if your Docker machine's IP is `192.168.99.100`, you would go to your browser
and type: `http://192.168.99.100:3000/` and hit enter. The first time you view a page will
take a minute or two for resources to compile and load, but it should eventually load.

Any errors will show up in your terminal in the window you were running the `up` command in.

## Local environment

If you prefer a local environment, totally cool! We recommend the following:

### First, ruby dependencies
* Make sure you have a ruby version manager installed; we recommend either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)
* Install our version of Ruby! We use version `2.4.1` (Usually `rbenv install 2.4.1` or `rvm install 2.4.1` once you have your version manager set up)
* Install PhantomJS, which our test suite depends on, via `brew install phantomjs`, or `npm install -g phantomjs-prebuilt`, or the [linux instructions](http://phantomjs.org/download.html)
* Run the command `gem install bundler && bundle install` to install ruby dependences, including `rails`

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
* All set! Navigate your browser to `http://localhost:3000`

#### Troubleshooting MongoDB
If you've never run MongoDB on a Rails server before...
In the Terminal command line:
1.) Once you have `mongod` running, seed your database by running `rake db:seed`.
2.) Start your rails server by running `rails server`.
3.) In the address bar, go to `localhost:3000`. The app should render.

Use 'Control + C' for both MongoDB and Rails to stop their servers from running. You can also stop MongoDB manually by killing the process running it. On a mac, open Activity Monitor and select 'mongoDB' under Process Name and then force it to quit by clicking the 'x' icon on the task bar above.


## Cloud9

If you don't currently have Rails installed (or are on Windows), Cloud9 makes things WAY easier by letting you skip installation of Rails and MongoDB.

* Sign into `https://c9.io/` and create a new workspace
* Clone from `git@github.com:{your_github_username}/dcaf_case_management.git` and select the Rails option
* The terminal at the bottom of your new workspace will have a warning message saying "ruby-2.4.1 is not installed. To install do: `rvm install ruby-2.4.1`". Run that command to install the necessary version of Ruby.
* Next, install the bundler gem by entering `gem install bundler` in the terminal.
* Install MongoDB by entering `sudo apt-get install -y mongodb-org`.
* Once MongoDB is installed, run `bundle install` in the terminal
* Open another terminal tab, and enter `mongod --bind_ip=$IP --nojournal` to start MongoDB
* Pop back to the previous tab and run `rake db:seed` to populate your database with test data
* Hit the `Run Project` button up top. (If the button is unresponsive, you may need select **Run -> Run With -> Rails Default** from the dropdown.)
* Check out the URL it's running on! You're all set!


## Security

Checkout [this document](https://github.com/DCAFEngineering/dcaf_case_management/docs/SECURITY_INTRO.md) on Ruby on Rails security.