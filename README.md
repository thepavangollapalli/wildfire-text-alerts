# Wildfire Text Alerts

## [Check it out!](https://www.firealert.me)

Polls the US Government's IRWIN fire reporting service and sends texts to users who have signed up with a ZIP code within 25 miles of a fire. Runs Ruby on Rails with Sidekiq background workers, and is deployed on Heroku.

* Dependencies
    * Ruby 2.7.2
    * Rails 6
    * Sidekiq
    * Postgres

* Getting started
    * git clone this repository: git clone (link)
    * Create a database named `wildfire_text_alerts_development`
    * Sign up for a Twilio account and obtain a phone number with Programmable SMS link to (https://www.twilio.com/docs/sms)
    * Set environment variables `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_FROM_PHONE`
    * Install all dependencies
    * Start Rails and Sidekiq: `rails server` and `bundle exec Sidekiq`
    * Enjoy!

* How to run the test suite
    * `rails test`