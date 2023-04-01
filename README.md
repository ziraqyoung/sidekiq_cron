# Sidekiq Cron and web in Plain Ruby

> Intro
## Sidekiq
- Sidekiq is a simple and efficient background processing library in Ruby.
- It uses threads to handle many jobs at the same time in the same process.

## Sidekiq Cron
- Sidekiq Cron runs a thread alongside Sidekiq workers to schedule jobs at specified intervals
  (using cron notation * * * * * parse by Fugit)
- Checks for new jobs to schedule every 30 seconds and doesnot schedule the same job multiple time, when more than one sidekiq worker is running.
- Schesduling jobs are added only when atleast one sidekiq process is running. 
- It is safe to use Sidekiq-cron in envs where multiple sidekiq processes are running

## Sidekiq Web
- Build-in-panel(Web UI) to monitor Sidekiq jobs and crons
- You could use System cron jobs and use shell scripts to do scheduling stuffs but sometimes using Ruby is easier.

> Setup
- Run `bundle init` to generate a `Gemfile`
- Add `sidekiq` and `sidekiq-cron` gems and run `bundle install`

> How to Run Sidekiq
- Sidekiq depends on Redis, so make sure its installed.
- You also need a config file for Sidekiq Usually `config/sidekiq.yml`:
- You also need to define a job for Sidekiq(usually called worker). eg in `lib/jobs/sample.rb`
 - - Include `Sidekiq::Worker` and define a `perform()`
- Sidekiq uses to Environment variables to get `REDIS URL`. `REDIS_PROVIDER` is like a pointer to the name of the environment variable  containing the address.
  `REDIS_PROVIDER=REDIS_URL` && `REDIS_URL=redis://127.0.0.1:6379/1` 
  To run Sidekiq: `REDIS_PROVIDER=REDIS_URL REDIS_URL=redis://127.0.0.1:6379/1 bundle exec sidekiq -C config/sidekiq.yml -r $PWD/lib/jobs/sample.rb`

- With this: we can push a job and it will be processed. and sidekiq is ready to handle Sample jobs

> How to Add Cron Jobs
- We have already added `sidekiq-cron`, Next: We are going to add schedule file and tell sidekiq about it.
- The `config/schedule.yml` is going to define how often the job is processed.
- Next a Ruby script is needed to tell sidekiq about these schedules. This is done in `crons.rb`
- The Code uses `Sidekiq::Cron::Job.load_from_has()` where:
- 1. Each schedule name is the main key eg. sample:
  2. The schedule cron is defined by `cron`, `class` and `queue`.
- For this we only need to run Sidekiq only requiring `crons.rb`
  `bundle exec sidekiq -C config/sidekiq.yml -r ./lib/crons.rb`
- If successfull, after every time, an enty is made into `logs/logs.log` a log entry is made in the console
- You can add as many custom jobs you want in `lib/jobs` dir. Just remember each job must have a `unique class`, must include `Sidekiq::Worker` and define a `perform` method.
- The register it in `config/schedule.yml` file with keys/values for `cron`, `class`, `queue`

> How to add Web Monitoring
- Sidekiq comes with an inbuild web monitoring panel, easily runnable and is used to monitor jobs and cron jobs 
- To run sidekiq/web UI, add the following gems `rackup` & `rack-session` then `bundle install`
- For Rack, a `rackup` file is need to run `Sidekiq::Web` panel. Add `lib/web/panel.ru`
- A valid rack session is required, hence for this `securerandom` is needed.
- To run sidekiq web: `REDIS_PROVIDER=REDIS_URL REDIS_URL=redis://127.0.0.1:6379/1 bundle exec rackup lib/web/panel.ru -o 0.0.0.0 -p 9292`
or simply: `bundle exec rackup lib/web/panel.ru -o 0.0.0.0 -p 9292`
- To use Rack session cookie.
- 1. `require 'rack/session'`
- 2. `use Rack::Session::Cookie, secret: File.read('.session.key'), same_site: true, max_age: 86400`
- To run sidekiq web `run Sidekiq::Web`
