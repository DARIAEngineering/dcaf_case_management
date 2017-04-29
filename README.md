# DCAF Case Manager

[![CircleCI](https://circleci.com/gh/colinxfleming/dcaf_case_management.svg?style=shield)](https://circleci.com/gh/colinxfleming/dcaf_case_management)
[![codecov](https://codecov.io/gh/colinxfleming/dcaf_case_management/branch/master/graph/badge.svg)](https://codecov.io/gh/colinxfleming/dcaf_case_management)
[![](https://images.microbadger.com/badges/image/colinxfleming/dcaf_case_management.svg)](https://microbadger.com/images/colinxfleming/dcaf_case_management "Get your own image badge on microbadger.com")

[A deployed demo version of what's in the master branch is at: https://sandbox.dcabortionfund.org/](https://sandbox.dcabortionfund.org/)


## Next major project milestone: June 15: Launch to Baltimore!

## [Come hang out with us on slack!](https://codefordc.slack.com/messages/dcaf_case_management)

[Join via the Code for DC website](http://codefordc.org/joinslack).

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Before this app, a team of 75 case managers were inputting around 3,500 calls a year into shared Excel sheets. This app replaced that with a nice, clean, useable and shareable rails system that ditches spreadsheets forever! This will let DCAF continue to operate at a fast pace, and prevent volunteers from getting frustrated with shared Excel sheets.

Get started with the how-and-why of the project by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](docs/DCAF-101.md), looking at the design team's [InVision prototype](https://projects.invisionapp.com/share/6757W6WFJ), and reading the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files/). You can also check out a [blog post about how we're using agile-ish](http://codefordc.org/blog/2016/09/12/code-for-dcaf.html).

The three co-leads on this project are @colinxfleming (rails and technical lead), @mebates (design and UI lead), and @adinneen (project manager and UX lead). We also have a large presence from DCAF actively consulting on this project, led by @lwaldsc and @nerdygirl537. Feel free to hit any of us up with questions about the project, we're nice!


## Contributing to this Project

### [If this is your first time, a good way to get oriented is to leave our users a nice note! Check out instructions here.](docs/YOUR_FIRST_CONTRIBUTION.md)

### tl;dr
* We run on forks and pull requests
* Look in milestones for stuff in active development
* Post in an issue when you're starting work on something
* We <3 new people and beginners


### Our structure
We run two week sprints where we try to complete 2-3 small features. These sync up with [Code for DC meetups](https://www.meetup.com/code-for-dc/).

At any given time, we have a list of active features or pieces of features we're working on (marked `Active development`) in a [github milestone](https://github.com/DCAFEngineering/dcaf_case_management/milestones). We also have a list of major features on deck for a release. If you're looking for a place to dive in, check out the `Active development` milestone!

We also have a milestone for major features in a release. @colinxfleming breaks off pieces of these and puts them in the active development milestone, and closes them when they're implemented, confirmed working, and tested.


### We <3 new people and beginners!
We recognize that not everyone comes to this project intimately familiar with rails. **If you've got the time and energy to contribute, we've got the time to help guide you in the right direction and make sure your time is well spent.** We've also got a set of issues that [are good starting points](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) if you're fresh to this project.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception of MongoDB and a couple gems.


### Pull Requests Please!
This project runs on *Github forks and pull requests*, so we can be sure to make changes incrementally and keep everything clean. For an introduction to Github, check out [this guide on github.com](https://guides.github.com/activities/hello-world/). 

Here's how you do it:

* Visit [the main project page](https://github.com/DCAFEngineering/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* Do any work in your local environment and commit it to your fork in github.
* Once you have finished your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button.
* At least one other person (probably @colinxfleming) will review and comment on code changes, work with you to resolve issues, and merge the pull request when it's ready.


### How We Categorize Our To Do List / Issues
As noted above, this project maintains a [list of issues in Github](https://github.com/DCAFEngineering/dcaf_case_management/issues) that make up our To-Do List. We categorize things as follows:

Our major categories of software development related issues are as follows:
* [Frontend](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Afrontend) (Rails view work, CSS/JS work)
* [Backend](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Abackend) (Rails controller and model work)
* [Minitest](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Aminitest) (Feature and unit test work)
* [Bug](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Abug) (Something deployed that isn't working as intended!)
* [UX/Design](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3AUX%2Fdesign) (Design todos)
* [Beginner Friendly](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) (Issues which require minimal familiarity with our codebase to complete, *reserved for people making their first contribution to this project*)

We also keep track of our administrative issues and discussion in Github under the following issue labels:
* [Admin](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Aadmin) (Readme stuff, project organizing matters, etc)
* [Question](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Aquestion) (Issues that require a little more discussion before we settle on a plan of attack)
* [Backlog](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3Abacklog) (Low priority stuff that we'll get around to someday)


## Setting Stuff Up

[We have detailed instructions on how to get started here!](docs/SETUP.md)

If you have any trouble getting things set up, please ping us in Slack!

If you see a spot in the docs that's confusing or could be improved, please pay it forward by making a pull request!


## For designers (Team lead: @mebates, user testing lead: @eheintzelman)

The design team primarily drafts out the application layouts and works with user testers and case managers on specing out how features should work.

The design team has created a working InVision prototype for iteration, [here](https://projects.invisionapp.com/share/6757W6WFJ). We need help furthering the wireframes in InVision beyond the "Submit Pledge" button, as well as resolving questions raised by user testing.

Current UX and wireframe assets are available [here](https://github.com/DCAFEngineering/dcaf_case_management/tree/master/_design).


## For developers (Team lead: @colinxfleming)

By and large, we are executing on the fantastic work of the design team.

The stack we use is Rails, MongoDB, PhantomJS and Capybara for integration tests, and `rails_bootstrap_forms` for forms. Nearly everything else is out of the box.  Are you new to any of the technologies in the DCAF stack? We have a handy page for more on [our stack, domain, and links to useful documentation](docs/TECH_STACK_INTRO.md).

**We prioritize inclusivity of all skill levels on this project** -- in general, if you are willing to put in the time to learn, a team member will be willing to work with you to make it happen!

We generally work on tackling issues tagged `frontend`, `backend`, and `minitest`. We also occasionally serve as code guides for the designers and help them navigate rails' architecture.

There's a (slightly outdated) picture of the data model [here](_design/DataModel.png).


## For case managers or abortion fund volunteers (Team leads: @lwaldsc and @nerdygirl537)

**If you are an abortion fund volunteer interested in the work we're doing, please reach out!**

DCAF's case management corps has a steady presence on this project -- we have users and stakeholders from DCAF who consult with other teams to ensure the success of the project. We regularly pair case managers with devs or designers to work on specific features.

@nerdygirl537 serves as the primary liaison to other funds interested in adopting the system. If you are interested in putting this software to work for your organization, reach out to her in our slack channel.


## I'm not really any of these but want to help!

Don't let that stop you! Hit us up, we'll find something for you to do.


## Project Wall of Appreciation

Like all volunteer projects, we'd be dead in the water if it weren't for the hard work of our valuable team. Championship contributors to this project (so far!) include:

* @ajohnson051
* @Kevin-Wei
* @charleshuang80
* @drownedout
* @rebeccaestes
* @ashlynnpai
* @camlatimer
* @mchelen
* @ewiggins
* @katsdc
* @eheintzelman
* @DarthHater
* @lomky


## Special thanks

The following are people who have been uniquely generous with their time, resources, and expertise:

* [Team Brakeman, a group of security specialists who have been very kind to us](https://brakemanpro.com/)
* Mike from OWASP DC, who provided critical guidance and insights when we were really bolting this down for production use


## License

Made available under an MIT license. See `LICENSE.txt` for more info.
