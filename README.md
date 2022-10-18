# DARIA Case Manager
![GithubActions Workflow](https://github.com/DARIAEngineering/dcaf_case_management/actions/workflows/test_dev_env.yml/badge.svg)

[A deployed demo version of what's in the main branch is at: https://sandbox.dariaservices.com/](https://sandbox.dariaservices.com/)  
User: test@example.com, Password: AbortionsAreAHumanRight1

## Are you from an abortion fund and are interested in seeing this will work for you?

Join the Code for DC slack, go to the channel `#daria`, and let us know!

## [Come hang out with us on slack!](https://codefordc.slack.com/)

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
This project is a case management system for abortion funds. [Abortion funds](http://www.fundabortionnow.org) are organizations that give grants to people who cannot afford the full cost of abortion care. Our primary goal with this project is to simplify routine case management processes, such as keeping track of patient data, pledges, and contact information.

This originated with the [DC Abortion Fund](http://www.dcabortionfund.org) (DCAF). Before this app went into production at DCAF, a team of 75 case managers were inputting around 3,500 calls a year into shared Excel sheets. Since adopting this system, DCAF and several other funds have been able to operate at a much faster pace, and lowered the stress levels of their volunteers.

Get started with the how-and-why of the project by [checking out[Abortion funds](http://www.fundabortionnow.org), checking out [case manager Lisa's explanation of DCAF's business logic](docs/DCAF_101.md), reading the [Code of Conduct](CODE_OF_CONDUCT.md), and reading the `#daria` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files). You can also check out [some of the other buzz](docs/PRESS.md) or [read about how it's impacted DCAF](docs/IMPACT_ON_DCAF.md).

There's still work to do, but generally we're pretty stable these days. Our general administration/maintenance plan is [here](docs/ADMINISTRATION_AND_MAINTENANCE_PLAN.md).

## Who's in charge here?
The team leads are:

* @colinxfleming (general lead)
* @lomky (technical leads)
* @lwaldsc (process lead)

Feel free to hit any of us up with questions about the project, we're nice!

## Contributing to this Project

### tl;dr
* We are best reached via the [Code for DC slack](https://codefordc.org/resources/slack.html)
* We run on forks and pull requests
* Our [list of issues in Github](https://github.com/DARIAEngineering/dcaf_case_management/issues) is our project's remaining TODO list
* Post in an issue when you're starting work on something, so @colinxfleming can keep track of it and so we don't duplicate work
* We <3 new people and beginners

### We <3 new people and beginners!
We recognize that not everyone comes to this project intimately familiar with rails. **If you've got the time and energy to contribute, we've got the time to help guide you in the right direction and make sure your time is well spent.** We've also got a set of issues that [are good starting points](https://github.com/DARIAEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) if you're fresh to this project.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception a couple gems.

**We prioritize inclusivity of all skill levels on this project** -- in general, if you are willing to put in the time to learn, a team member will be willing to work with you to make it happen!

## Project Appreciation ✨

Like all volunteer projects, we'd be dead in the water if it weren't for the hard work of our valuable team. We are eternally grateful to every contributor, be they programmers, designers, researchers, case managers, project managers, bug hunters, documenters, or anyone else keeping us afloat!

## Special thanks

The following are people who have been uniquely generous with their time, resources, and expertise:

* [Team Brakeman, a group of security specialists who have been very kind to us](https://brakemanpro.com/)
* Mike from OWASP DC, who provided critical guidance and insights when we were really bolting this down for production use

## License

Made available under an MIT license. See `LICENSE.txt` for more info.

### Research notice

Please note that this repository is participating in a study into sustainability of open source projects. Data will be gathered about this repository for approximately the next 12 months, starting from June 2021.

Data collected will include number of contributors, number of PRs, time taken to close/merge these PRs, and issues closed.

For more information, please visit [the informational page](https://sustainable-open-science-and-software.github.io/) or download the [participant information sheet](https://sustainable-open-science-and-software.github.io/assets/PIS_sustainable_software.pdf).


