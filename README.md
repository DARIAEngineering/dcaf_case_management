# Case management system

![CircleCI](https://circleci.com/gh/colinxfleming/dcaf_case_management.svg?style=shield)

[A deployed demo version is at: http://casemanagerdemo.herokuapp.com/](http://casemanagerdemo.herokuapp.com/)

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Currently, a team of around 75 case managers are taking about 3,500 calls a year and entering them all into shared Excel sheets. We're replacing that with a nice, clean, usable and scalable rails application! This will let DCAF continue to operate at a fast pace, and prevent volunteers from getting frustrated with shared Excel sheets. 

If you're interested: This is a great opportunity to learn about common nonprofit data problems, try out Rails, or just contribute to a project that will have a great positive impact on reproductive justice for people in the DC area. Come say hi, we're friendly! 

We're generally looking for people comfortable or interested in the following:
* Ruby on Rails (a good starter kit: [CodeAcademy's course](http://www.codecademy.com/learn/learn-rails))
* JQuery / HTML / CSS
* NoSQL / flat data modeling
* Nonprofit data issues 

Get started with the how-and-why of the project by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](https://github.com/colinxfleming/dcaf_case_management/wiki/DCAF-101), looking at the design team's [InVision prototype](https://projects.invisionapp.com/share/6757W6WFJ), and reading the `#dcaf_case_management` channel on Slack. Hit up @colinxfleming and Mollie with any questions. 

## How Do I Contribute? 
This project runs on Github forks and pull requests, so we can be sure to make changes incrementally and keep everything clean. For an introduction to github, check out (this guide on github.com)[https://guides.github.com/activities/hello-world/]. 
* To contribute, visit [the main project page](https://github.com/colinxfleming/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* Do any work in your local environment and commit it to your fork in github.
* Once you have finished your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button.
* At least one other person (probably @colinxfleming) will review and comment on code changes, and work with you to resolve issues, and merge the pull request when it's ready.

## Setting Things Up Locally 

First things first: Make a copy of your own to wrench on! Go to `https://github.com/colinxfleming/dcaf_case_management` and hit `fork`.

If you don't currently have Rails installed (or are on Windows), Cloud9 makes things WAY easier by letting you skip installation of Rails and MongoDB: 

    Sign into `https://c9.io/` and create a new workspace
    Clone from `git@github.com:{your_github_username}/dcaf_case_management.git` and select the Rails option
    Once created, `$ bundle install` from the terminal
    `$ mongod` to start MongoDB
    Hit the `Run Project` button up top

If you do prefer a local environment, do the following: 

    # Install Ruby, Rails and MongoDB (An easy rails installer is [here](http://railsinstaller.org/en); MongoDB setup instructions are below)
    `$ git clone git@github.com:{your_github_username}/dcaf_case_management.git && cd dcaf_case_management`
    `$ bundle install`
    `$ rails server`
    # navigate your browser to `http://localhost:3000`

## For designers
The design team has created a working InVision prototype for iteration, [here](https://projects.invisionapp.com/share/6757W6WFJ). We need help furthering the wireframes in InVision beyond the "Submit Pledge" button, as well as designing a usability testing plan for the app. 

Current UX and wireframe assets are available here: 
* [DCAFtaskflow.pdf](https://drive.google.com/file/d/0B2HIORWZ94L-NVJNN0VEeEdEa28/view?usp=sharing)
* [DCAFwireframe120715.ai](https://github.com/colinxfleming/dcaf_case_management/blob/master/_design/DCAFwireframe120715.ai)
* [DCAFwireframe120715.pdf](https://github.com/colinxfleming/dcaf_case_management/blob/master/_design/DCAFwireframe120715.pdf)

## Dockerizing

To manage the dependencies and save us all some headache, we've Dockered this app. If you're docker-savvy, you can run the following to fire up mongo and the rails server: 
* `$ docker-compose build && docker-compose up`

## Setting up MongoDB

* Install MongoDB locally if you haven't (`$ brew install mongodb`, for example, or the [linux instructions](https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/))
* `$ bundle install` to install necessary gems
* Create a folder in the root directory for the MongoDB database. `$ sudo mkdir -p /data/db`
* Allow for MongoDB read/write permissions `$ sudo chmod 777 /data/db`
* Start 'er up with `$ mongod`

# Depreciated Readme stuff

## Working With Jekyll 

This repo has a `gh-pages` branch, currently used for displaying live pages. To contribute to those pages (this assumes you have ruby installed): 

* clone it -- `$ git clone git@github.com:colinxfleming/dcaf_case_management.git`
* Install the jekyll gem -- `$ gem install jekyll`
* Start the web server -- `$ jekyll serve --baseurl ''`
* Navigate to `http://localhost:4000`
* Make changes to the pages in the root directory or the assets in `_sass` and hack away!
