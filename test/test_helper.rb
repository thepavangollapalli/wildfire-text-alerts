ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    # Stub Twilio API out because fire creation can trigger texts being sent
    stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts//Messages.json")
    .to_return(status: 200, body: "", headers: {})
  end
end
