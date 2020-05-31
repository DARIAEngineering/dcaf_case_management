# Detailed setup instructions

The directions below get you to a point where you can run the app with a test-seeded database.

[If this is your first time, a good way to get oriented is to leave our users a nice note! Check out instructions here.](YOUR_FIRST_CONTRIBUTION.md). If you have any trouble getting things set up, please ping us in Slack!

If you see a spot in the docs that's confusing or could be improved, please pay it forward by making a pull request!

* **First things first**: Make a copy of your own to wrench on by forking! Go to https://github.com/DCAFEngineering/dcaf_case_management and hit the `fork` button up in the top right.
* **Second things second**: `git clone https://github.com/{YOUR GITHUB USERNAME}/dcaf_case_management` to pull it down to your local system. Use `cd dcaf_case_management` to change directory to where you saved the clone.
* **Third things third**: Add the source repo as the upstream with the command `git remote add upstream https://github.com/DCAFEngineering/dcaf_case_management`. This will let you update when the source repo changes by running the command `git pull upstream master`.
* **Fourth things fourth**: Make the source repo fetch-only by unsetting the URL: `git remote set-url --push upstream no-pushing-to-upstream`. This will prevent mistakenly pushing to upstream if you get push access down the road.

For the rest of the setup, you have two options: Docker, or installing everything locally. We recommend Docker if you're comfortable with its ecosystem.

## Docker

We've dockerized this app, to manage the dependencies and save us some headache. If you've got [Docker installed already](https://docs.docker.com/engine/installation/), you can be up and running with three commands:

* `docker-compose build # (this may say 'uses an image, skipping' a few times, that's OK)`
* `docker-compose run --rm web rake db:seed # to populate the database`
* `docker-compose up`

The last command will take a moment and should print a number of things. When it's ready
to go, it should say something like:

    web_1  | [1] * Listening on tcp://0.0.0.0:3000

This runs the app on `http://localhost:3000` and you can hit it like a regular rails server. The first time you view a page will
take a minute or two for resources to compile and load, but it should eventually load. You can log in with the user `test@example.com` and the password `P4ssword`.

Any errors will show up in your terminal in the window you are running the `up` command in.

If the server won't start, it may not have cleanly shut down. Run `rm tmp/pids/server.pid` to remove the leftover server process and run `docker-compose up` again.

* On Windows 10, you may run into an error related to no matching manifest for Windows:
ex: Step 1/21 : FROM ruby:2.6.5-slim-buster
2.6.5-slim-buster: Pulling from library/ruby
Service 'web' failed to build: no matching manifest for windows/amd64 10.0.18363 in the manifest list entries

To fix this, you need to enable experimental features for Docker:
1. Right click Docker icon in the Windows System Tray
2. Go to Settings
3. Go to Daemon
4. Check Experimental features
5. Hit Apply


## Local environment

If you prefer a local environment, totally cool! We recommend the following:

### First, ruby dependencies
* Make sure you have a ruby version manager installed; we recommend either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/).
* Install our version of Ruby! You can see our current version of ruby in the `Gemfile`. Install it with `rbenv install VERSION` or `rvm install VERSION`, depending on what you're using.
* Run the command `gem install bundler && bundle install` to install dependencies, including `rails`.

### Then, MongoDB dependencies
You'll also need to set up MongoDB. This will differ based on your OS.
* Install MongoDB locally (here's the [MacOS instructions](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/) and [linux instructions](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/))

### Then, JS dependencies
We're on Webpacker, which requires an additional setup step, but which lets us write ES6.
* Install Yarn locally (`brew install yarn`, or the [setup instructions](https://yarnpkg.com/en/docs/install)).
* Install JS packages: `yarn install`

### Then, showtime
After that:
* run `rake db:seed` to populate your database with test data
* Run the command `rails server` to start the rails server
* You are officially ready to go! Navigate your browser to `http://localhost:3000`. You can log in with the user `test@example.com` and the password `P4ssword`.

## Security

Check out [this document](https://github.com/DCAFEngineering/dcaf_case_management/docs/SECURITY_INTRO.md) on Ruby on Rails security, which contains some guidelines on developing safely. (Note that we review code before merging, so a second human will be checking that things are safe, not just you!)
