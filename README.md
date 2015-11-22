# Case management system

[http://colinxfleming.github.io/dcaf_case_management/](http://colinxfleming.github.io/dcaf_case_management/)

## Project description
This project is a case management system. 

We're working with the [DC Abortion Fund](http://dcabortionfund.org/), an all-volunteer, 501(c)(3) non-profit organization that makes grants to women and girls in DC, Maryland, and Virginia who cannot afford the full cost of an abortion. `Case Managers` receive a high volume of calls from patients seeking help accessing abortion care every night, and store that information in an Excel doc which only one person at a time can access. 

As DCAF's call volume (and volunteer corps) has increased, the shortcomings of having a spreadsheet-based system have become more pronounced. Case managers have trouble making changes to the spreadsheet, occasionally overwrite changes, and are limited by the number of case managers who can access the system at a given time. This, in turn, is slowing the organization down and frustrating volunteers on the intake hotline.

To solve this organizational challenge, the goals of this project are to build an accessible web-based system that will:
* Let case managers store and retrieve access to patient information
* Store all patient data safely and securely
* Ensure multiple case managers can access and use the system at once
* Track money spent in a given period of a week
* Simplify administrative tasks such as paying clinics and monthly expenses reporting 

## Contributing
This project runs on Github forks and pull requests, so we can be sure to make changes incrementally and keep everything clean. For an introduction to github, check out (this guide on github.com)[https://guides.github.com/activities/hello-world/]. 
* To contribute, visit [the main project page](https://github.com/colinxfleming/dcaf_case_management) and fork from the master branch by pressing the `fork` button near the top right.
* In your terminal, create a directory and use `git clone` to store the files locally on your computer. (for example: `$ git clone git@github.com:billy_everyteen/dcaf_case_management.git`)
* When you have made changes and you want to upload them onto Github, add and commit your changes by using the following commands: `git add` and `git commit -m "description of changes"`. 
* Push to origin master by inputting `git push -u origin master` (or another branch)
* Once you have pushed your changes and have confirmed they're all working, make a pull request by pressing the Pull Request button. Someone else on the project will review and merge your changes, then you're good to go!

## For designers
Current wireframe assets are available here:   
[DCAFwireframe110915.ai](https://drive.google.com/open?id=0B2HlOoxw2oq1a0hDYmt0ZE55VGs)  
[DCAFwireframe110915.pdf](https://drive.google.com/open?id=0B2HlOoxw2oq1UmhxVVJ1SlJOLTA)

## Working With Jekyll 

This repo has a `gh-pages` branch, currently used for displaying live pages. To contribute to those pages (this assumes you have ruby installed): 

* clone it -- `$ git clone git@github.com:colinxfleming/dcaf_case_management.git`
* Install the jekyll gem -- `$ gem install jekyll`
* Start the web server -- `$ jekyll serve --baseurl ''`
* Navigate to `http://localhost:4000`
* Make changes to the pages in the root directory or the assets in `_sass` and hack away!
