# Our security practices

By reaching out to a fund, a patient is implicitly trusting us to be discreet and safeguard their personal data. To make good on funds' promise to keep our patients safe and offer them the best advice and support we can, our development team's top priority is keeping patient data secure and safe.

This document outlines some specific practices that we follow as a development team to keep our data secure and safe.


## Code review

The first line of defense is a regular review of code as it is developed and deployed. We accomplish this through two main means.

1. **All code changes are submitted as pull requests••, which means that they are submitted to the project as proposed changes before making it into the codebase. This gives the team a chance to review and offer suggestions before code gets to the point where anyone interacts with it. Furthermore, code can only be approved by a select group of project leaders.

2. After a change is merged into the codebase, we **redeploy a fresh version of the app to a testing sandbox environment**. This environment is isolated from our production system. This environment gives us a chance to confirm that code changes work as intended, do not introduce any security holes, and meet the project's high standard of quality.


## Static code checking

Our project uses a variety of industry standard methods to ensure our existing codebase stays secure and free of vulnerabilities.

1. The team at Brakeman Pro have generously donated our team a license for their software, which scans our entire codebase. We perform this scan on a regular basis and, in the event that the scan flags a security hole, we fix it as soon as possible. (Thank you, team Brakeman!)

2. Because difficult-to-read code can lead to security holes, we regularly revise our code to conform to a standard style. We also make it a point to revise code in pull requests during code review.


## Automated testing

We use it a point to write unit and integration tests for our codebase, which ensures a high level of code quality. This means that we break our app into individual features and functions, and have code which runs them all and confirms that they produce the intended output.

Proposed code changes are expected to be accompanied by tests proving that they work as intended. If one or more of our automated tests fails, code changes do not get deployed into our sandbox or production environments.


## Vulnerability monitoring

Ruby audit, bundler audit, brakeman, other haxx


## Vendor selection and hosting

We farm out hosting and etc to services which run dedicated security teams and which have bug bounty programs.


## SSL

We aren't dumb


## Backups

Regularly scheduled backups of the last week of data taken 2x daily and stored in the cloud tk


## User management

Passwords and SSO


## Data encryption practices

Archiving records TK, encryption at rest TK


## Monitoring

New relic


## Pen testing

Someday