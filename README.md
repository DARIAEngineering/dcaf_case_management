# DARIA (DCAF Case Manager)

[![CircleCI](https://circleci.com/gh/DCAFEngineering/dcaf_case_management.svg?style=shield)](https://circleci.com/gh/DCAFEngineering/dcaf_case_management)
[![codecov](https://codecov.io/gh/DCAFEngineering/dcaf_case_management/branch/master/graph/badge.svg)](https://codecov.io/gh/DCAFEngineering/dcaf_case_management)
[![](https://images.microbadger.com/badges/image/colinxfleming/dcaf_case_management.svg)](https://microbadger.com/images/colinxfleming/dcaf_case_management "Get your own image badge on microbadger.com")
[![Dependency Status](https://gemnasium.com/badges/github.com/DCAFEngineering/dcaf_case_management.svg)](https://gemnasium.com/github.com/DCAFEngineering/dcaf_case_management)

[A deployed demo version of what's in the master branch is at: https://sandbox.dcabortionfund.org/](https://sandbox.dcabortionfund.org/) User: test@test.com, Pass: P4ssword

## Next major project milestone: Sharing with other funds

Major new feature development on this project has more or less drawn to a close. If you are an abortion fund interested in whether this would work for you, hit us up and let us know!

## [Come hang out with us on slack!](https://codefordc.slack.com/messages/dcaf_case_management)

[Join via the Code for DC website](http://codefordc.org/joinslack).

## Are you from an abortion fund and are interested in seeing this will work for you?

Join the Code for DC slack, go to the channel `#dcaf_case_management`, and let us know!

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/) (DCAF), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Its primary goal is to simplify routine case management processes, such as keeping track of patient data, pledges, and contact information.

Before this app went into production at DCAF, a team of 75 case managers were inputting around 3,500 calls a year into shared Excel sheets. This app replaces that with a nice, clean, useable and shareable rails system that ditches spreadsheets forever! This lets DCAF and other funds continue to operate at a fast pace, and prevents volunteers from getting frustrated with shared Excel sheets.

In addition, other abortion funds doing similar work in other places can adopt this system to their use. We have a 

Get started with the how-and-why of the project by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](docs/DCAF_101.md), reading the [Code of Conduct](CODE_OF_CONDUCT.md), and reading the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files). You can also check out [some of the other buzz](docs/PRESS.md).

## Who's in charge here?

The team leads are:

* @colinxfleming (rails and technical lead)
* @mebates (design and UI lead)
* @nerdygirl573 (DARIA manager)
* @lwaldsc (DCAF liaison)
* @alisonnjones (data lead)

Feel free to hit any of us up with questions about the project, we're nice!

## Contributing to this Project

### tl;dr
* We are a regular presence at [Code for DC meetups](https://www.meetup.com/code-for-dc/)
* We run on forks and pull requests
* Our [list of issues in Github](https://github.com/colinxfleming/dcaf_case_management/issues) is our project's remaining TODO list
* Post in an issue when you're starting work on something, so @colinxfleming can keep track of it and so we don't duplicate work
* We <3 new people and beginners

### [If this is your first time, a good way to get oriented is to leave our users a nice note! Check out instructions here.](docs/YOUR_FIRST_CONTRIBUTION.md)

### Setting Stuff Up

[We have detailed instructions on how to get started here!](docs/SETUP.md)

If you have any trouble getting things set up, please ping us in Slack!

If you see a spot in the docs that's confusing or could be improved, please pay it forward by making a pull request!

### We <3 new people and beginners!
We recognize that not everyone comes to this project intimately familiar with rails. **If you've got the time and energy to contribute, we've got the time to help guide you in the right direction and make sure your time is well spent.** We've also got a set of issues that [are good starting points](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) if you're fresh to this project.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception of MongoDB and a couple gems.

**We prioritize inclusivity of all skill levels on this project** -- in general, if you are willing to put in the time to learn, a team member will be willing to work with you to make it happen!

### Pull Requests Please!
This project runs on *Github forks and pull requests*, so we can be sure to make changes incrementally and keep everything clean. For an introduction to Github, check out [this guide on github.com](https://guides.github.com/activities/hello-world/).

Here's how you do it:

* Visit [the main project page](https://github.com/DCAFEngineering/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* Do any work in your local environment and commit it to your fork in github.
* Once you have finished your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button.
* At least one other person will review and comment on code changes, work with you to resolve issues, and merge the pull request when it's ready.

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
* @ian.norris
* @tingaloo
* @colinmcglynn

## Special thanks

The following are people who have been uniquely generous with their time, resources, and expertise:

* [Team Brakeman, a group of security specialists who have been very kind to us](https://brakemanpro.com/)
* Mike from OWASP DC, who provided critical guidance and insights when we were really bolting this down for production use

## License

Made available under an MIT license. See `LICENSE.txt` for more info.
