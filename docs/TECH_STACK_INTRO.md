## Code!!
### Rails
Ruby on Rails is a web app framework written in Ruby. It's got a lot of opinions and conventions that you'll learn if you work with it! 

If you're new to programming or Rails, RailsBridge is a non-profit that has written [a few curriculums](http://docs.railsbridge.org/docs/) that can walk you through Rails and all those conventions.

* The [Rails Guides](http://guides.rubyonrails.org/) are short but thorough introductions to lots of different aspects of Rails.
* The full documentation of Rails is at http://api.rubyonrails.org, which you'll usually get to if you Google a Rails method.

### MongoDB
MongoDB is a NoSQL database that stores data as collections and documents (rather than rows and columns that you be familiar with from more SQL-ish databases). 

* Here are [the MongoDB docs](https://docs.mongodb.com/manual/)!
* Since this is a Rails app, you'll be interacting with Mongo primarily through [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html), so you won't have to write Mongo-specific queries immediately, depending on the feature you're working on.
* Here's a [brief introduction to Rails and MongoDB](http://kerrizor.com/blog/2014/04/02/quick-intro-to-mongodb-in-rails), including more resources at the end of the article.

---

## Tests!!
We love tests! All the tests can be found in the test directory, and it's a great idea to unit and/or integration test the feature that you're working on. Try checking out the other tests in the app if you're not sure what or how to test something.

### MiniTest
* MiniTest is the default Rails testing framework! As such, there's a [handy Rails Guide](http://guides.rubyonrails.org/testing.html) about the various ways that Rails wants you to test.
* Google will probably also lead you to the [MiniTest docs](http://ruby-doc.org/stdlib-2.0.0/libdoc/minitest/rdoc/MiniTest.html) at some point in your journey, too.

### Capybara & PhantomJS

* [Capybara](http://teamcapybara.github.io/capybara/) is a Ruby integration testing library that can uses browser (in our case, a headless one, meaning you don't see it) to fill in forms, click buttons, and generally interact with the app, and then verifies that things worked as we expected!
* Here are [the Capybara docs](http://www.rubydoc.info/github/teamcapybara/capybara/master)
* [PhantomJS](http://phantomjs.org/) is the driver that we use to run these tests -- it's the technology that actually spins up the browser that the Capybara tests run against. If everything goes as planned, you won't have to interact directly with PhantomJS at all! :ghost:

---

## Intro to DCAF!!
We love our case managers and the UX team that figures out how we can help them be more happy and more efficient. Check out these resources for more context about the hows and whys of this app:
* [The DCAF website](http://dcabortionfund.org)
* [DCAF 101](DCAF-101.md), and explanation of how case managers use the app
* Our design team's [InVision prototype](https://projects.invisionapp.com/share/6757W6WFJ)
* Join and read through the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files/)
* Read this [blog post about how we're using agile-ish](http://codefordc.org/blog/2016/09/12/code-for-dcaf.html)
* Read [the README](https://github.com/DCAFEngineering/dcaf_case_management/) (if you haven't already) :sparkling_heart:
