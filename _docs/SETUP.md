# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.

If you see a spot in the docs that's confusing or could be improved, please pay it forward by making a pull request!

## Repo Setup

1. Fork the Repo: Go to https://github.com/DARIAEngineering/dcaf_case_management and hit the `fork` button up in the top right.
2. Clone the repo to your machine: Copy the URL for your fork and run: `git clone YOUR_FORK_URL` to pull it down to your local system. Change into the repo directory with `cd dcaf_case_management`.
3. Add the Daria repo as a remote: `git remote add upstream https://github.com/DARIAEngineering/dcaf_case_management`. This will let you update when the source repo changes by running the command `git pull upstream main`.

## Local Development

### Docker-based

We've dockerized the app, to manage the dependencies and save us some headache. We recommend this route for beginners or anyone who prefers docker.  
If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:

* `docker compose build`
* `docker compose run --rm web rails db:drop db:create db:migrate db:seed # to populate the database`
* `docker compose up`

The last command will take a moment and should print a number of things. When it's ready
to go, it should say something like:

    web_1  | [1] * Listening on tcp://0.0.0.0:3000

This runs the app on `http://localhost:3000` and you can hit it like a regular rails server. The first time you view a page will
take a minute or two for resources to compile and load, but it should eventually load. You can log in with the user `test@example.com` and the password `AbortionsAreAHumanRight1`.

Any errors will show up in your terminal in the window you are running the `up` command in.


### Local Laptop Install

If you prefer to run directly on you machine, here are our general directions. You may need to adapt them to your machine. Beginners may find the docker setup easier.

#### System Dependencies
* Install:
  * Git, python2, & openssl-dev
  * Ubuntu: `sudo apt install git python2 openssl libssl-dev`
  * Mac: `brew install git python2 openssl`

#### Ruby Dependencies
* Make sure you have a ruby version manager installed; we recommend either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/).
* Install our version of Ruby! `rbenv install` or `rvm install $(cat .ruby-version)` should do the trick, depending on what you're using.

#### JS Dependencies
* Set up a node verion manager; we recommend [nvm](https://github.com/nvm-sh/nvm#install--update-script).
* Install our version of node with `nvm install`.
* Install Yarn locally (`brew install yarn`, or the [setup instructions](https://yarnpkg.com/en/docs/install)).

#### Postgres Dependencies
We use Postgres around these parts. Installation will differ based on your OS.

* Install Postgres
  * MacOS: `brew install postgres`
  * Ubuntu: install `postgresql`, `libpq-dev`, and `postgresql-client`
  * Other [linux instructions](https://www.postgresql.org/download/) (server and developer libraries needed)
  * Set the daemon to run automatically, if needed

* Configure Postgres
  * Setup your user; the suggested password is `postgres` if you only use this machine for development purposes
    ```
    sudo -u postgres createuser -P -s `whoami`
    ```
  * Set your env variables:
    ```
    echo "POSTGRES_USER=`whoami`" >>.env
    echo "POSTGRES_PASSWORD=postgres" >>.env
    ```

#### Final App Setup
* Run the command `gem install bundler && bundle install` to install dependencies, including `rails`.
* Install JS packages: `yarn install`
* Run the command `rails db:create db:migrate db:seed` to set up the database and populate it with some test data.

#### Showtime

* Run the command `bin/dev` to start the rails server
* You are officially ready to go! Navigate your browser to `http://localhost:3000`. You can log in with the user `test@example.com` and the password `AbortionsAreAHumanRight1`.

