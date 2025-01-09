# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.

If you see a spot in the docs that's confusing or could be improved, please pay it forward by making a pull request!

## Repo Setup

1. Fork the Repo: Go to https://github.com/DARIAEngineering/dcaf_case_management and hit the `fork` button up in the top right.
2. Clone the repo to your machine: Copy the URL for your fork and run: `git clone YOUR_FORK_URL` to pull it down to your local system. Change into the repo directory with `cd dcaf_case_management`.
3. Add the Daria repo as a remote: `git remote add upstream https://github.com/DARIAEngineering/dcaf_case_management`. This will let you update when the source repo changes by running the command `git pull upstream main`.


## Local Dev Environment

For the rest of the setup, you have two options: Docker, or installing everything locally. We recommend Docker if you're comfortable with its ecosystem.

### Docker

We've dockerized this app, to manage the dependencies and save us some headache. If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:

* `docker compose build # (this may say 'uses an image, skipping' a few times, that's OK)`
* `docker compose run --rm web rails db:drop db:create db:migrate db:seed # to populate the database`
* `docker compose up`

The last command will take a moment and should print a number of things. When it's ready
to go, it should say something like:

    web_1  | [1] * Listening on tcp://0.0.0.0:3000

This runs the app on `http://localhost:3000` and you can hit it like a regular rails server. The first time you view a page will
take a minute or two for resources to compile and load, but it should eventually load. You can log in with the user `test@example.com` and the password `AbortionsAreAHumanRight1`.

Any errors will show up in your terminal in the window you are running the `up` command in.

If the server won't start, it may not have cleanly shut down. Run `rm tmp/pids/server.pid` to remove the leftover server process and run `docker compose up` again.

If you're using a Windows 10 machine to run docker, we strongly suggest downloading and using [Docker-Desktop](https://www.docker.com/products/docker-desktop).
The Docker-Desktop experience on Windows 10 is mostly very smooth these days, but there are a couple common "gotchas" we've seen while developing this (and other) apps. One of our core maintainers keeps additional info on this [here](https://github.com/mdworken/MKD-Docker-Windows-Rails). If you run into issues that are not covered there, or if you have suggestions to improve the readability of the repo, please let us know! We're happy to help debug, and once we understand the issues you've seen, you'll have helped future users who may encounter the same issue.

To fix this, you need to enable experimental features for Docker:
1. Right click Docker icon in the Windows System Tray
2. Go to Settings
3. Go to Daemon
4. Check Experimental features
5. Hit Apply


### Local Laptop Install

If you prefer a local environment, totally cool! We recommend the following, but you'll need to adapt to your exact machine.

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

