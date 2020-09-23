# DARIA (DCAF Case Manager)

[![CircleCI](https://circleci.com/gh/DCAFEngineering/dcaf_case_management.svg?style=shield)](https://circleci.com/gh/DCAFEngineering/dcaf_case_management)
[![codecov](https://codecov.io/gh/DCAFEngineering/dcaf_case_management/branch/main/graph/badge.svg)](https://codecov.io/gh/DCAFEngineering/dcaf_case_management)
[![](https://images.microbadger.com/badges/image/colinxfleming/dcaf_case_management.svg)](https://microbadger.com/images/colinxfleming/dcaf_case_management "Get your own image badge on microbadger.com")

[A deployed demo version of what's in the main branch is at: https://sandbox.dcabortionfund.org/](https://sandbox.dcabortionfund.org/)  
User: test@example.com, Password: P4ssword

## Are you from an abortion fund and are interested in seeing this will work for you?
Join the Code for DC slack, go to the channel `#dcaf_case_management`, and let us know!

## [Come hang out with us on slack!](https://codefordc.slack.com/messages/dcaf_case_management)

[Join via the Code for DC website](https://codefordc.org/resources/slack.html).

## I'm new, how do I set stuff up?

[We have detailed instructions on how to get started here!](docs/SETUP.md)

## I'm not new, what's changed?

We renamed our primary branch to `main` in 2020-July. Either re-clone the repo or do these steps:

```shell
git branch -m master main
git push -u origin main
```

## Project description
This project is a case management system for the [DC Abortion Fund](http://dcabortionfund.org/) (DCAF), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Its primary goal is to simplify routine case management processes, such as keeping track of patient data, pledges, and contact information.

Before this app went into production at DCAF, a team of 75 case managers were inputting around 3,500 calls a year into shared Excel sheets. This app replaces that with a nice, clean, useable and shareable rails system that ditches spreadsheets forever! This lets DCAF and other funds continue to operate at a fast pace, and prevents volunteers from getting frustrated with shared Excel sheets.

In addition, other abortion funds doing similar work in other places can adopt this system to their use. It follows DCAF's workflow, but several other abortion funds with similar workflows have also adopted it to great success.

Get started with the how-and-why of the project by [checking out DCAF](http://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](docs/DCAF_101.md), reading the [Code of Conduct](CODE_OF_CONDUCT.md), and reading the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files). You can also check out [some of the other buzz](docs/PRESS.md) or [read about how it's impacted DCAF](docs/IMPACT_ON_DCAF.md).

There's still work to do, but generally we're pretty stable these days. Our general administration/maintenance plan is [here](docs/ADMINISTRATION_AND_MAINTENANCE_PLAN.md).

## Who's in charge here?
The team leads are:

* @lomky (rails and technical lead) & @colinxfleming (on 2020 Sabbatical)
* @mebates (design and UI lead)
* @alisonnjones & @mdworken (data lead)
* @nerdygirl573 (DARIA manager)
* @lwaldsc (DCAF liaison)

Feel free to hit any of us up with questions about the project, we're nice!

## Contributing to this Project

### tl;dr
* We are best reached via the [Code for DC slack](https://codefordc.org/resources/slack.html)
* We run on forks and pull requests
* Our [list of issues in Github](https://github.com/colinxfleming/dcaf_case_management/issues) is our project's remaining TODO list
* Post in an issue when you're starting work on something, so @colinxfleming can keep track of it and so we don't duplicate work
* We <3 new people and beginners

### We <3 new people and beginners!
We recognize that not everyone comes to this project intimately familiar with rails. **If you've got the time and energy to contribute, we've got the time to help guide you in the right direction and make sure your time is well spent.** We've also got a set of issues that [are good starting points](https://github.com/DCAFEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) if you're fresh to this project.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception of MongoDB and a couple gems.

**We prioritize inclusivity of all skill levels on this project** -- in general, if you are willing to put in the time to learn, a team member will be willing to work with you to make it happen!

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
* @mdworken
* @rudietuesdays
* @harumhelmy

## Special thanks

The following are people who have been uniquely generous with their time, resources, and expertise:

* [Team Brakeman, a group of security specialists who have been very kind to us](https://brakemanpro.com/)
* Mike from OWASP DC, who provided critical guidance and insights when we were really bolting this down for production use

## License

Made available under an MIT license. See `LICENSE.txt` for more info.
