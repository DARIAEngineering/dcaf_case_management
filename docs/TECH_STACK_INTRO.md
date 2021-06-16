## Code!!
### Rails
Ruby on Rails is a web app framework written in Ruby. It's got a lot of opinions and conventions that you'll learn if you work with it! 

If you're new to programming or Rails, RailsBridge is a non-profit that has written [a few curriculums](http://docs.railsbridge.org/docs/) that can walk you through Rails and all those conventions.

* The [Rails Guides](http://guides.rubyonrails.org/) are short but thorough introductions to lots of different aspects of Rails.
* The full documentation of Rails is at http://api.rubyonrails.org, which you'll usually get to if you Google a Rails method.

### PostgreSQL
PostgreSQL is a relational database we use to store patient information. Data is stored in tables.

You'll primarily interact with the database via [ActiveRecord](http://guides.rubyonrails.org/active_record_basics.html). Most 

---

## Tests!!
We love tests! All the tests can be found in the test directory, and it's a great idea to unit and/or integration test the feature that you're working on. Try checking out the other tests in the app if you're not sure what or how to test something.

### MiniTest
* MiniTest is the default Rails testing framework! As such, there's a [handy Rails Guide](http://guides.rubyonrails.org/testing.html) about the various ways that Rails wants you to test.
* Google will probably also lead you to the [MiniTest docs](http://ruby-doc.org/stdlib-2.0.0/libdoc/minitest/rdoc/MiniTest.html) at some point in your journey, too.

### Capybara

* [Capybara](http://teamcapybara.github.io/capybara/) is a Ruby integration testing library that can uses browser to fill in forms, click buttons, and generally interact with the app, and then verifies that things worked as we expected!
* Here are [the Capybara docs](http://www.rubydoc.info/github/teamcapybara/capybara/master)
* Generally we have CircleCI run these for us, so you don't need to worry about setting up Capybara unless you need to write system tests.

---

## Intro to DCAF!!
We love our case managers and the UX team that figures out how we can help them be more happy and more efficient. Check out these resources for more context about the hows and whys of this app:
* [The DCAF website](https://dcabortionfund.org)
* [DCAF 101](DCAF_101.md), and explanation of how case managers use the app
* Join and read through the `#dcaf_case_management` [channel on Slack](https://codefordc.slack.com/messages/dcaf_case_management/files/)
* Read this [blog post about how we're using agile-ish](https://codefordc.github.io/blog/2016/09/12/code-for-dcaf.html).
* Read [the README](https://github.com/DCAFEngineering/dcaf_case_management/) (if you haven't already) :sparkling_heart:
