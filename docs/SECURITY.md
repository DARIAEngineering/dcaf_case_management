# Our security practices

By reaching out to a fund, a patient is implicitly trusting us to be discreet and safeguard their personal data. To make good on funds' promise to keep our patients safe and offer them the best advice and support we can, our development team's top priority is keeping patient data secure and safe.

This document outlines some specific practices that we follow as a development team to keep our data secure and safe.


## Code review

The first line of defense is a regular review of code as it is developed and deployed. We accomplish this through two main means.

1. **All code changes are submitted as pull requests**, which means that they are submitted to the project as proposed changes before making it into the codebase. This gives the team a chance to review and offer suggestions before code gets to the point where anyone interacts with it. Furthermore, code can only be approved by a select group of project leaders.

2. After a change is merged into the codebase, we **redeploy a fresh version of the app to a testing sandbox environment**. This environment is isolated from our production system. This environment gives us a chance to confirm that code changes work as intended, do not introduce any security holes, and meet the project's high standard of quality.


## Static code checking

Our project uses a variety of industry standard methods to ensure our existing codebase stays secure and free of vulnerabilities.

1. The team at Brakeman Pro have generously donated our team a license for their software, which scans our entire codebase to alert us about potential holes we've left open. We perform this scan on a regular basis and, in the event that the scan flags a security hole, we fix it as soon as possible. (Thank you, team Brakeman!)

2. Because difficult-to-read code can lead to security holes, we regularly revise our code to conform to a standard style. We also make it a point to revise code in pull requests during code review.

## Dependency checking

A reality of most projects nowadays is they use a LOT of Open Source code, and DCAF is no exception. Old dependencies in turn depend on other old things, and this can cause a compound problem when attempting to remediate security issues. While we don't live on the very extreme edge of dependencies, keeping things fresh allows us to more easily absorb a fix if one is released. We use Gemnasium to keep track of our dependencies and if they are out of date. This manifests as a badge on the README, as well as a more comprehensive list if you click through to Gemnasium.

## Automated testing

We use it a point to write unit and integration tests for our codebase, which ensures a high level of code quality. This means that we break our app into individual features and functions, and have code which runs them all and confirms that they produce the intended output.

Proposed code changes are expected to be accompanied by tests proving that they work as intended. If one or more of our automated tests fails, code changes do not get deployed into our sandbox or production environments.


## Vulnerability monitoring

In addition to automated tests, we have several tools which automatically run at the same time to alert us of any security holes. It effectively provides an "Everything is okay alarm" every time there's a proposed code change. The libraries we use and their area of focus are as follows:

1. **Ruby-audit**: This tool keeps track of known vulnerabilities in the Ruby language.
2. **Bundler-audit**: This tool keeps track of known vulnerabilities in the libraries we use to construct the app.
3. **Brakeman Pro**: See above for information on Brakeman Pro.


## Vendor selection and hosting

For hosting purposes, we have selected service vendors which are backed by significant security engineering teams. This enables us to effectively have security professionals monitoring our apps against intrusion, and allows us to benefit from their practices to safeguard our own data.


## SSL

All traffic going to and from any environment we're in is protected by SSL, per industry best practice.


## User management

Given that a very common attack vector for an app of this type is a user account hijack, we take a few steps to harden against this potential threat.

1. We give users the option to log in through Google, which lets us take advantage of Google's user security best practices. To this end, we encourage our users to set up 2-factor authentication on their accounts.

2. We use an industry-standard library, `devise`, for user authentication, to avoid having to write and maintain our own secure authentication system.

3. We recommend against using a password, but for users who insist on logging in via a password, we enforce a high password standard. We also send email notifications on password change, so that potential intrusions can be flagged as soon as possible.


## Data access

We follow the principle of least use; most users are permissioned to see only necessary data.

For users with heightened permissions, we have a user-accessible way to bulk-export anonymized data for aggregation. We don't have a user-accessible way to bulk-lookup data.


## Limiting data we collect

See [our data collection practices document](OUR_DATA_COLLECTION_PRACTICES.md) for a fuller accounting of what we collect and why.


## Other attack vectors

We have solutions in place to prevent common attack vectors. Keeping our framework, Rails, up to date protects us from a lot of common attacks. In addition, we use the ibraries `rack-attack` and `secure_headers` to prevent some less common attack vectors, such as DDOS attacks and javascript injection.


## Data encryption practices

TK.

<!-- Archiving records TK, encryption at rest TK -->


## Monitoring

TK.


## Pen testing

TK.


## Backups

TK.

<!-- Regularly scheduled backups of the last week of data taken 2x daily and stored in the cloud tk -->
