# Deploying to production

We have a heroku pipeline configured that sets up a staging and production environment. Deploying to staging is automatic, and deploying to production requires a manual button press in the Heroku dashboard.

Staging is deployed when a build on `main` succeeds automagically. This is configured in Heroku via `Enable Automatic Deploys` and hopefully we never need to touch it.

To deploy production, you'll need to log in to Heroku, open up the pipeline, and then hit the Promote to Production button. When you do this, you should [notify the DARIA updates listserv](https://github.com/DCAFEngineering/dcaf_case_management/blob/main/docs/administering/ONBOARDING_A_NEW_FUND.md).

