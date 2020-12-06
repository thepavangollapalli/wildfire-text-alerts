# from https://rubyonfire.com/setup-ruby-on-rails-with-sidekiq-on-heroku
if Rails.env.production?
    Sidekiq.configure_client do |config|
        config.redis = { url: ENV.fetch('REDIS_URL'), size: 1, network_timeout: 5 }
    end

    Sidekiq.configure_server do |config|
        config.redis = { url: ENV.fetch('REDIS_URL'), size: 12, network_timeout: 5 }
    end
end