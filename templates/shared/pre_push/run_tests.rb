# frozen_string_literal: true

# Runs the full test suite before push; aborts push if tests fail.
# Uses bundle exec rspec. For Minitest, edit to use bundle exec rake test.

require 'english'

system('bundle exec rspec')
exit $CHILD_STATUS.to_s[-1].to_i
