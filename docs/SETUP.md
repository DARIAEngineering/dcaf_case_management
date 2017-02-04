# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.


## Docker

We've dockerized this app, to manage the dependencies and save us some headache. If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:
* `docker-compose build`
* `docker-compose run web rake db:seed # to populate the database`
* `docker-compose up`


## Local environment

If you prefer a local environment, totally cool! We recommend the following:

### First, ruby dependencies
* Make sure you have a ruby version manager installed; we recommend either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)
* Install our version of Ruby! We use version `2.3.3` (Usually `rbenv install 2.3.3` or `rvm install 2.3.3` once you have your version manager set up)
* Install PhantomJS, which our test suite depends on, via `brew install phantomjs`, or `npm install -g phantomjs`, or the [linux instructions](http://phantomjs.org/download.html)
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
* The terminal at the bottom of your new workspace will have a warning message saying "ruby-2.3.3 is not installed. To install do: `rvm install ruby-2.3.3`". Run that command to install the necessary version of Ruby.
* Next, install the bundler gem by entering `gem install bundler` in the terminal.
* Install MongoDB by entering `sudo apt-get install -y mongodb-org`.
* Once MongoDB is installed, run `bundle install` in the terminal
* Open another terminal tab, and enter `mongod --bind_ip=$IP --nojournal` to start MongoDB
* Pop back to the previous tab and run `rake db:seed` to populate your database with test data
* Hit the `Run Project` button up top. (If the button is unresponsive, you may need select **Run -> Run With -> Rails Default** from the dropdown.)
* Check out the URL it's running on! You're all set!
