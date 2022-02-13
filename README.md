# DARIA (DCAF Case Manager)
![GithubActions Workflow](https://github.com/DARIAEngineering/dcaf_case_management/actions/workflows/test_dev_env.yml/badge.svg)

[A deployed demo version of what's in the main branch is at: https://sandbox.dariaservices.com/](https://sandbox.dariaservices.com/)  
User: test@example.com, Password: AbortionsAreAHumanRight1

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
This project is a case management system for the [DC Abortion Fund](https://dcabortionfund.org/) (DCAF), an all-volunteer, 501(c)(3) non-profit organization that gives grants to people in DC, Maryland, and Virginia who cannot afford the full cost of abortion care. Its primary goal is to simplify routine case management processes, such as keeping track of patient data, pledges, and contact information.

Before this app went into production at DCAF, a team of 75 case managers were inputting around 3,500 calls a year into shared Excel sheets. This app replaces that with a nice, clean, useable and shareable rails system that ditches spreadsheets forever! This lets DCAF and other funds continue to operate at a fast pace, and prevents volunteers from getting frustrated with shared Excel sheets.

In addition, other abortion funds doing similar work in other places can adopt this system to their use. It follows DCAF's workflow, but several other abortion funds with similar workflows have also adopted it to great success.

Get started with the how-and-why of the project by [checking out DCAF](https://dcabortionfund.org), checking out [DCAF Case Manager Lisa's explanation of DCAF's business logic](docs/DCAF_101.md), reading the [Code of Conduct](CODE_OF_CONDUCT.md), and reading the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files). You can also check out [some of the other buzz](docs/PRESS.md) or [read about how it's impacted DCAF](docs/IMPACT_ON_DCAF.md).

There's still work to do, but generally we're pretty stable these days. Our general administration/maintenance plan is [here](docs/ADMINISTRATION_AND_MAINTENANCE_PLAN.md).

## Who's in charge here?
The team leads are:

* @colinxfleming & @lomky (rails and technical leads)
* @mebates (design and UI lead)
* @alisonnjones & @mdworken (data leads)
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
We recognize that not everyone comes to this project intimately familiar with rails. **If you've got the time and energy to contribute, we've got the time to help guide you in the right direction and make sure your time is well spent.** We've also got a set of issues that [are good starting points](https://github.com/DARIAEngineering/dcaf_case_management/issues?q=is%3Aissue+is%3Aopen+label%3A%22beginner+friendly%22) if you're fresh to this project.

We've tried to structure the project in such a way that minimal specialized knowledge is required to contribute; we use the default Rails stack wherever possible, with the exception a couple gems.

**We prioritize inclusivity of all skill levels on this project** -- in general, if you are willing to put in the time to learn, a team member will be willing to work with you to make it happen!

## Project Wall of Appreciation ✨

Like all volunteer projects, we'd be dead in the water if it weren't for the hard work of our valuable team. Championship contributors to this project (so far!) include ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-35-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.simpsonsworld.com/video/436278339668"><img src="https://avatars.githubusercontent.com/u/3866868?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Colin</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=colinxfleming" title="Code">💻</a> <a href="#eventOrganizing-colinxfleming" title="Event Organizing">📋</a> <a href="#infra-colinxfleming" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-colinxfleming" title="Maintenance">🚧</a> <a href="#mentoring-colinxfleming" title="Mentoring">🧑‍🏫</a> <a href="#projectManagement-colinxfleming" title="Project Management">📆</a> <a href="#question-colinxfleming" title="Answering Questions">💬</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+reviewed-by%3Acolinxfleming" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/mebates"><img src="https://avatars.githubusercontent.com/u/6223901?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mollie Bates</b></sub></a><br /><a href="#design-mebates" title="Design">🎨</a> <a href="#eventOrganizing-mebates" title="Event Organizing">📋</a> <a href="#ideas-mebates" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/ajohnson052"><img src="https://avatars.githubusercontent.com/u/14868930?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alexis Johnson</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=ajohnson052" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Kevin-Wei"><img src="https://avatars.githubusercontent.com/u/1946584?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kevin Wei</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=Kevin-Wei" title="Code">💻</a> <a href="#ideas-Kevin-Wei" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/charleshuang80"><img src="https://avatars.githubusercontent.com/u/1174907?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Charles Huang</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=charleshuang80" title="Code">💻</a> <a href="#ideas-charleshuang80" title="Ideas, Planning, & Feedback">🤔</a> <a href="#security-charleshuang80" title="Security">🛡️</a></td>
    <td align="center"><a href="https://github.com/lwaldsc"><img src="https://avatars.githubusercontent.com/u/10578608?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lisa</b></sub></a><br /><a href="#content-lwaldsc" title="Content">🖋</a> <a href="#design-lwaldsc" title="Design">🎨</a> <a href="#ideas-lwaldsc" title="Ideas, Planning, & Feedback">🤔</a> <a href="#question-lwaldsc" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/NerdyGirl537"><img src="https://avatars.githubusercontent.com/u/15252633?v=4?s=100" width="100px;" alt=""/><br /><sub><b>NerdyGirl537</b></sub></a><br /><a href="#design-NerdyGirl537" title="Design">🎨</a> <a href="#ideas-NerdyGirl537" title="Ideas, Planning, & Feedback">🤔</a> <a href="#question-NerdyGirl537" title="Answering Questions">💬</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/drownedout"><img src="https://avatars.githubusercontent.com/u/10971884?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Daniel</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=drownedout" title="Code">💻</a></td>
    <td align="center"><a href="http://www.rebeccaestes.com/"><img src="https://avatars.githubusercontent.com/u/3891862?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rebecca G. Estes</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=rebeccaestes" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/eheintzelman"><img src="https://avatars.githubusercontent.com/u/17989540?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Eva Heintzelman</b></sub></a><br /><a href="#design-eheintzelman" title="Design">🎨</a></td>
    <td align="center"><a href="http://www.ashlynnpai.com/"><img src="https://avatars.githubusercontent.com/u/7366046?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ashlynn Pai</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=ashlynnpai" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/CamLatimer"><img src="https://avatars.githubusercontent.com/u/13918431?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cam</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=CamLatimer" title="Code">💻</a></td>
    <td align="center"><a href="https://twitter.com/mchelen"><img src="https://avatars.githubusercontent.com/u/30691?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mike Chelen</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/issues?q=author%3Amchelen" title="Bug reports">🐛</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=mchelen" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/ewiggins"><img src="https://avatars.githubusercontent.com/u/4694248?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Elisheba</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=ewiggins" title="Code">💻</a> <a href="#infra-ewiggins" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://www.katschroeder.me/"><img src="https://avatars.githubusercontent.com/u/11823445?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kat Schroeder</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=KatSDC" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/DarthHater"><img src="https://avatars.githubusercontent.com/u/5544326?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jeffry Hesse</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=DarthHater" title="Code">💻</a> <a href="#infra-DarthHater" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-DarthHater" title="Maintenance">🚧</a> <a href="#mentoring-DarthHater" title="Mentoring">🧑‍🏫</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+reviewed-by%3ADarthHater" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/lomky"><img src="https://avatars.githubusercontent.com/u/6129479?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Kat Tipton</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=lomky" title="Code">💻</a> <a href="#eventOrganizing-lomky" title="Event Organizing">📋</a> <a href="#maintenance-lomky" title="Maintenance">🚧</a> <a href="#mentoring-lomky" title="Mentoring">🧑‍🏫</a> <a href="#projectManagement-lomky" title="Project Management">📆</a> <a href="#question-lomky" title="Answering Questions">💬</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+reviewed-by%3Alomky" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/FeminismIsAwesome"><img src="https://avatars.githubusercontent.com/u/5641692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ian Norris</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=FeminismIsAwesome" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/tingaloo"><img src="https://avatars.githubusercontent.com/u/8662824?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lew</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=tingaloo" title="Code">💻</a> <a href="#ideas-tingaloo" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+reviewed-by%3Atingaloo" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://github.com/colinmcglynn"><img src="https://avatars.githubusercontent.com/u/4335814?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Colin McGlynn</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=colinmcglynn" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/mdworken"><img src="https://avatars.githubusercontent.com/u/31595784?v=4?s=100" width="100px;" alt=""/><br /><sub><b>mdworken</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=mdworken" title="Code">💻</a> <a href="#mentoring-mdworken" title="Mentoring">🧑‍🏫</a> <a href="#question-mdworken" title="Answering Questions">💬</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+reviewed-by%3Amdworken" title="Reviewed Pull Requests">👀</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://throneless.tech/"><img src="https://avatars.githubusercontent.com/u/10843135?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rae</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=rudietuesdays" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/harumhelmy"><img src="https://avatars.githubusercontent.com/u/13320420?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Harum!</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=harumhelmy" title="Code">💻</a> <a href="#design-harumhelmy" title="Design">🎨</a> <a href="#translation-harumhelmy" title="Translation">🌍</a></td>
    <td align="center"><a href="https://github.com/montanezp"><img src="https://avatars.githubusercontent.com/u/36459660?v=4?s=100" width="100px;" alt=""/><br /><sub><b>montanezp</b></sub></a><br /><a href="#translation-montanezp" title="Translation">🌍</a></td>
    <td align="center"><a href="https://github.com/BintLopez"><img src="https://avatars.githubusercontent.com/u/5728859?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nicole</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/issues?q=author%3ABintLopez" title="Bug reports">🐛</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=BintLopez" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/elimbaum"><img src="https://avatars.githubusercontent.com/u/7085805?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Eli Baum</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/issues?q=author%3Aelimbaum" title="Bug reports">🐛</a> <a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=elimbaum" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/verbingthenoun"><img src="https://avatars.githubusercontent.com/u/19561734?v=4?s=100" width="100px;" alt=""/><br /><sub><b>alexa silverman</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/issues?q=author%3Averbingthenoun" title="Bug reports">🐛</a> <a href="#ideas-verbingthenoun" title="Ideas, Planning, & Feedback">🤔</a> <a href="#question-verbingthenoun" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/xmunoz"><img src="https://avatars.githubusercontent.com/u/1065196?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cristina</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=xmunoz" title="Code">💻</a> <a href="#infra-xmunoz" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/sofijaj"><img src="https://avatars.githubusercontent.com/u/60895168?v=4?s=100" width="100px;" alt=""/><br /><sub><b>sofijaj</b></sub></a><br /><a href="#ideas-sofijaj" title="Ideas, Planning, & Feedback">🤔</a> <a href="#question-sofijaj" title="Answering Questions">💬</a></td>
    <td align="center"><a href="https://github.com/features/security"><img src="https://avatars.githubusercontent.com/u/27347476?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Dependabot</b></sub></a><br /><a href="#security-dependabot" title="Security">🛡️</a></td>
    <td align="center"><a href="https://github.com/arjunrawal07"><img src="https://avatars.githubusercontent.com/u/46463756?v=4?s=100" width="100px;" alt=""/><br /><sub><b>arjunrawal07</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=arjunrawal07" title="Code">💻</a></td>
    <td align="center"><a href="https://allcontributors.org"><img src="https://avatars.githubusercontent.com/u/46410174?v=4?s=100" width="100px;" alt=""/><br /><sub><b>All Contributors</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=all-contributors" title="Documentation">📖</a></td>
    <td align="center"><a href="http://ccedacero.com/"><img src="https://avatars.githubusercontent.com/u/44513825?v=4?s=100" width="100px;" alt=""/><br /><sub><b>ccedacero(Cristian Cedacero)</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=ccedacero" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/nsiwnf"><img src="https://avatars.githubusercontent.com/u/34173394?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sree P</b></sub></a><br /><a href="https://github.com/DARIAEngineering/dcaf_case_management/commits?author=nsiwnf" title="Code">💻</a></td>
    <td align="center"><a href="https://www.emiliaportfolio.com/"><img src="https://avatars.githubusercontent.com/u/90362047?v=4?s=100" width="100px;" alt=""/><br /><sub><b>emtot22</b></sub></a><br /><a href="#design-emtot22" title="Design">🎨</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

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


