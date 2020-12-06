web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production}

# -c is number of threads. -t gives the job max 25 seconds to run before pushing it back to the queue
sidekiqworkers: bundle exec sidekiq -c 4 -t 25