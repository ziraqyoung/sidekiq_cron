require "sidekiq/web"
require "sidekiq/cron/web"

require "rack/session"
require "securerandom"

File.write(".session.key", SecureRandom.hex(32)) unless File.exist?(".session.key")

use Rack::Session::Cookie, secret: File.read(".session.key"), same_site: true, max_age: 86400

run Sidekiq::Web
