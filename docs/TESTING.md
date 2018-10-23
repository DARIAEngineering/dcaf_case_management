# Testing locally before submitting PRs

## Since we would like all contributors to respect others' times, and also keep the Continuous Integration in a green state, we request that you run the following steps before submitting PRs.

### One-time setup for testing
- `gem update --system # Update rubygems`
- `gem install --no-rdoc bundler brakeman ruby_audit bundler-audit`

### For each commit
- `bundle check || bundle install`
- `bundle exec rake knapsack:minitest`
(The test results can be found in this folder: test-results)
- `brakeman --exit-on-warn .`
- `bundle exec ruby-audit check`
- `bundle-audit update; bundle-audit check`
