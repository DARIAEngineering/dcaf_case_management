# DCAF Case Manager

[![CircleCI](https://circleci.com/gh/colinxfleming/dcaf_case_management.svg?style=shield)](https://circleci.com/gh/colinxfleming/dcaf_case_management)

[A deployed demo version of what's in the master branch is at: http://casemanagerdemo.herokuapp.com/](http://casemanagerdemo.herokuapp.com/)

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Currently, a team of around 75 case managers are taking about 3,500 calls a year and entering them all into shared Excel sheets. We're replacing that with a nice, clean, usable and scalable rails application! This will let DCAF continue to operate at a fast pace, and prevent volunteers from getting frustrated with shared Excel sheets. 

Get started with the how-and-why of the project by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](https://github.com/colinxfleming/dcaf_case_management/wiki/DCAF-101), looking at the design team's [InVision prototype](https://projects.invisionapp.com/share/6757W6WFJ), and reading the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files/).

The three co-leads on this project are @colinxfleming (rails and technical lead), @mebates (design and UI lead), and @adinneen (project manager and UX lead). We also have a large presence from DCAF actively consulting on this project, led by @lwaldsc and @nerdygirl537. Feel free to hit any of us up with questions about the project, we're nice!

## Contributing to this Project
### Our structure

We run two week sprints where we try to complete 2-3 small features. Generally, we meet at Code for DC once to begin the sprint, and spend the off-week completing what we didn't finish the previous week.

When we begin a sprint, the project manager identifies the features to complete from the list of things to do before hitting Minimum Viable Product. The project leads create a Project Milestone and create Github issues for the feature itself. When we meet, we divide up the issues in the sprint, to not duplicate work.

### Pull Requests Please!
This project runs on Github forks and pull requests, so we can be sure to make changes incrementally and keep everything clean. For an introduction to Github, check out [this guide on github.com](https://guides.github.com/activities/hello-world/). Contribution instructions are as follows: 

* Visit [the main project page](https://github.com/colinxfleming/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* Do any work in your local environment and commit it to your fork in github.
* Once you have finished your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button.
* At least one other person (probably @colinxfleming) will review and comment on code changes, and work with you to resolve issues, and merge the pull request when it's ready.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception of MongoDB. So hopefully you can hop right in!

(TK: Formal Contributing Guidelines)


## Setting Stuff Up 
**First things first**: Make a copy of your own to wrench on! Go to https://github.com/colinxfleming/dcaf_case_management and hit the `fork` button up in the top right.

For the rest of the setup, you have three options: Cloud9, Docker, or installing everything locally. We recommend Cloud9 if you're new to Rails or don't want to waste a lot of time installing dependencies, or Docker if you're comfortable with its ecosystem. The directions below get you to a point where you can run the app with a test-seeded database.

### Cloud9

If you don't currently have Rails installed (or are on Windows), Cloud9 makes things WAY easier by letting you skip installation of Rails and MongoDB: 

* Sign into `https://c9.io/` and create a new workspace
* Clone from `git@github.com:{your_github_username}/dcaf_case_management.git` and select the Rails option
* Once created, run `bundle install` from the terminal
* Open another terminal tab, and run `mongod` to start MongoDB
* Pop back to the previous tab and run `rake db:seed` to populate your database with test data
* Hit the `Run Project` button up top. (If the button is unresponsive, you may need select **Run -> Run With -> Rails Default** from the dropdown.)
* Check out the URL it's running on! You're all set!

### Docker

We've dockerized this app, to manage the dependencies and save us all the headahce. If you've got Docker installed already, you can be up and running with three commands:
* `docker-compose build # to install the dependencies` 
* `docker-compose run web rake db:seed # to populate the database`
* `docker-compose up`

If the server won't start, it may not have cleanly shut down. Run `rm tmp/pids/server.pid` to remove the leftover server process and run `docker-compose up` again. 

### Local environment

If you prefer a local environment, do the following: 

* Install Ruby, Rails and MongoDB (An easy rails installer is [here](http://railsinstaller.org/en); MongoDB setup instructions are below)
* Run the command `git clone git@github.com:{YOUR GITHUB USERNAME}/dcaf_case_management.git && cd dcaf_case_management` to pull down 
* Run the command `bundle install` to install dependences

If you don't have MongoDB installed, also do: 
* Install MongoDB locally (`brew install mongodb`, for example, or the [linux instructions](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/))
* Create a folder in the root directory for the MongoDB database. `sudo mkdir -p /data/db`
* Allow for MongoDB read/write permissions `sudo chmod 777 /data/db`
* Open another terminal tab and run `mongod` to start up the database

After that:
* Run `rake db:seed` to populate your database with test data
* Run the command `rails server` to start the rails server
* All set! Navigate your browser to `http://localhost:3000`


## For designers
The design team has created a working InVision prototype for iteration, [here](https://projects.invisionapp.com/share/6757W6WFJ). We need help furthering the wireframes in InVision beyond the "Submit Pledge" button, as well as designing a usability testing plan for the app. 

Current UX and wireframe assets are available here: 
* [DCAFtaskflow.pdf](https://drive.google.com/file/d/0B2HIORWZ94L-NVJNN0VEeEdEa28/view?usp=sharing)
* [DCAFwireframe120715.ai](https://github.com/colinxfleming/dcaf_case_management/blob/master/_design/DCAFwireframe120715.ai)
* [DCAFwireframe120715.pdf](https://github.com/colinxfleming/dcaf_case_management/blob/master/_design/DCAFwireframe120715.pdf)


## Project Wall of Appreciation

Like all volunteer projects, we'd be dead in the water if it weren't for the hard work of our valuable team. Championship contributors to this project (so far!) are: 

* @ajohnson051 (lots of hard work on controllers and views)
* @Kevin-Wei (constructed data model)
* @charleshuang80 (crucial work on forms)
* @drownedout (constructed data model, excellent rails guide)


## License

Made available under an MIT license. See `LICENSE.txt` for more info.
