# from https://rubyonfire.com/setup-ruby-on-rails-with-sidekiq-on-heroku
if Rails.env.production?
    Sidekiq.configure_client do |config|
        config.redis = { url: ENV.fetch('REDIS_URL'), size: 1, network_timeout: 5 }
    end

    Sidekiq.configure_server do |config|
        config.redis = { url: ENV.fetch('REDIS_URL'), size: 12, network_timeout: 5 }
    end
end

# execute 5 minutes after every hour, ex: 12:05, 1:05, 2:05, etc
# temp executes every 5 minutes
Sidekiq::Cron::Job.create(name: 'Poll Irwin API - every hour', cron: '*/5 * * * *', class: 'IrwinApiPollingWorker')