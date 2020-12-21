# Wildfire Text Alerts

**[Check it out!](https://www.firealert.me)**

Polls the US Government's IRWIN fire reporting service and sends texts to users who have signed up with a ZIP code within 25 miles of a fire. Runs Ruby on Rails with Sidekiq background workers, and is deployed on Heroku.

[Product Hunt link](https://www.producthunt.com/posts/wildfire-alerts)

## Dependencies
* Ruby 2.7.2
* Rails 6
* Sidekiq
* Postgres

## Getting started
* git clone this repository: 
```
git clone https://github.com/thepavangollapalli/wildfire-text-alerts
```
* Create a database named `wildfire_text_alerts_development`: 
```
psql -U {username} -c "CREATE DATABASE wildfire_text_alerts_development;"
```
* Sign up for a Twilio account and obtain a phone number with Programmable SMS link to (https://www.twilio.com/docs/sms)
* Set environment variables (make sure to add this file to your .gitignore so it doesn't end up online):
```
echo 'export TWILIO_ACCOUNT_SID={account sid} TWILIO_AUTH_TOKEN={auth token} TWILIO_FROM_PHONE={twilio phone number}' >> twilio.env
source twilio.env
```
* Install all dependencies:
```
bundle install
```
* Start Rails and Sidekiq: `rails server` and `bundle exec Sidekiq`
* Enjoy!

## How to run the test suite
* `rails test`

## Demo
![desktop screenshot](desktop_demo.png?raw=true)

![mobile screenshot](mobile_demo.png?raw=true)