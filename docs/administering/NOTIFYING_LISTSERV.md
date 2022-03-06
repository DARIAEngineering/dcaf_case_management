# Notifying the listserv of updates

We have a google group set up to let funds know about DARIA updates and other important matters. Generally we email them as a courtesy when deploying updates, so they're aware of new features, security patches, etc. This is a guide to assembling the notification email.

## You can copy this part

> Hi, we're deploying the following updates to DARIA shortly:

### And then we get the bullets of specific updates

* Go to the Heroku dashboard to figure out when the last deploy to production was
* Go to [the list of merged PRs](https://github.com/DARIAEngineering/dcaf_case_management/pulls?q=is%3Apr+is%3Aclosed+sort%3Aupdated-desc) to see what PRs have been merged since then. We'll include them as follows:
  * For PRs tagged `feature`, include the title of the PR as a bullet
  * If there are any PRs tagged `dependencies`, include one bullet as follows: 'Routine maintenance, library patches, etc.'
  * You do not need to include PRs that are not tagged

#### Example

Assuming these PRs tagged `feature` have been merged since the last deploy:

* Fix bug around accountants search
* Add ability to configure clinics list

And these PRs tagged `dependencies` have been merged since the last deploy:

* Upgrade rails to 6.0.3
* Fight with JQuery to squash a vulnerability

You would send the following email to the listserv when you deployed:

```
Hi, we're deploying the following updates to DARIA shortly:

* Fix bug around accountants search
* Add ability to configure clinics list
* Routine maintenance, library patches, etc.
```
