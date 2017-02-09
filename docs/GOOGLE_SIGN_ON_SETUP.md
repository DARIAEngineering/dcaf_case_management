# Setting up Google SSO

To avoid password related weaknesses, we give our case managers the opportunity to use their google accounts to sign in. Password authentication still works, so you can avoid this completely and it's fine.

Setting it up requires a few more hoops to jump through. You'll need to acquire a few keys from @colinxfleming or @DarthHater and then do the following:

* Define the environment variables `DCAF_GOOGLE_KEY` and `DCAF_GOOGLE_SECRET`. On OSX or linux, you can do this by two lines variables to your `.bash_profile` (or whatever you use):
    - `export DCAF_GOOGLE_KEY='public key for Google SSO API'`
    - `export DCAF_GOOGLE_SECRET='secret key for Google SSO API'`

Once you've done this, Sign In with Google functionality should start working for you. (We mock this in test environments, so you don't have to worry about that.)

Note that unlike a lot of Google SSO builds, our Sign In With Google functionality doesn't automatically create an account; you'll need to have an account associated with that email address persisted in the database already.

BUT WAIT! What about Docker?! Never fear, these environment variables will get passed through to the docker image if you are using docker-compose up. 
