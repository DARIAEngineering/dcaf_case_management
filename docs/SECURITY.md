# Our security practices

This application houses a lot of sensitive data, to put it mildly; our development team's top priority is keeping that data secure.

This document outlines some specific practices that we follow as a development team to keep our data secure and safe.


## Code review

PRs all go thru me before we merge, utilize a staging environment


## Static code checking

Stuff about our use of brakeman pro and other best practice linters (since nonstandardized unreadable code is a security hole)


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