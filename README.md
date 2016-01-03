# Case management system

[http://colinxfleming.github.io/dcaf_case_management/](http://colinxfleming.github.io/dcaf_case_management/)

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Currently, a team of around 75 case managers are taking about 3,500 calls a year and entering them all into shared Excel sheets. We're replacing that with a nice, clean, usable and scalable rails application! This will let DCAF continue to operate at a fast pace, and prevent volunteers from getting frustrated with shared Excel sheets. 

If you're interested: This is a great opportunity to learn about common nonprofit data problems, try out Rails, or just contribute to a project that will have a great positive impact on reproductive justice for people in the DC area. Come say hi, we're friendly! 

We're generally looking for people comfortable or interested in the following:
* Ruby on Rails (a good starter kit: [CodeAcademy's course](http://www.codecademy.com/learn/learn-rails))
* JQuery / HTML / CSS
* NoSQL / flat data modeling
* Nonprofit data issues 

Get started by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](TK), and looking at the design team's [InVision prototype](https://projects.invisionapp.com/share/6757W6WFJ). Hit up @colinxfleming and Mollie with any questions. 

To solve this organizational challenge, the goals of this project are to build an accessible web-based system that will:
* Let case managers store and retrieve access to patient information
* Store all patient data safely and securely
* Ensure multiple case managers can access and use the system at once
* Track money spent in a given period of a week
* Simplify administrative tasks such as paying clinics and monthly expenses reporting 

## How Do I Contribute? 
This project runs on Github forks and pull requests, so we can be sure to make changes incrementally and keep everything clean. For an introduction to github, check out (this guide on github.com)[https://guides.github.com/activities/hello-world/]. 
* To contribute, visit [the main project page](https://github.com/colinxfleming/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* In your terminal, create a directory and use `git clone` to store the files locally on your computer. (for example: `$ git clone git@github.com:YOUR_GITHUB_USERNAME/dcaf_case_management.git`)
* When you have made changes and you want to upload them onto Github, add and commit your changes by using the following commands: `git add` and `git commit -m "description of changes"`. 
* Push to origin master by inputting `git push -u origin master` (or another branch)
* Once you have pushed your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button. Someone else on the project will review and merge your changes, then you're good to go!

## For designers
The design team has created a working InVision prototype for iteration, [here](https://projects.invisionapp.com/share/6757W6WFJ).

Current wireframe assets are available here: 
* [DCAFtaskflow.pdf](https://drive.google.com/file/d/0B2HIORWZ94L-NVJNN0VEeEdEa28/view?usp=sharing)
* [DCAFwireframe110915.ai](https://drive.google.com/open?id=0B2HlOoxw2oq1a0hDYmt0ZE55VGs)  
* [DCAFwireframe110915.pdf](https://drive.google.com/open?id=0B2HlOoxw2oq1UmhxVVJ1SlJOLTA)

## Setting up MongoDB

* Install MongoDB locally if you haven't (`$ brew install mongodb`, for example)
* `$ bundle install` to install necessary gems
* Create a folder in the root directory for the MongoDB database. `$ sudo mkdir -p /data/db`
* Allow for MongoDB read/write permissions `$ sudo chmod 777 data/db`
* Start 'er up with `$ mongod`

# Depreciated Readme stuff

## Working With Jekyll 

This repo has a `gh-pages` branch, currently used for displaying live pages. To contribute to those pages (this assumes you have ruby installed): 

* clone it -- `$ git clone git@github.com:colinxfleming/dcaf_case_management.git`
* Install the jekyll gem -- `$ gem install jekyll`
* Start the web server -- `$ jekyll serve --baseurl ''`
* Navigate to `http://localhost:4000`
* Make changes to the pages in the root directory or the assets in `_sass` and hack away!
