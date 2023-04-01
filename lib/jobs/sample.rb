require "sidekiq"

class Sample
  include Sidekiq::Job

  def perform
    logs_dirname = "./logs"
    # Create ./logs directory if missing
    Dir.mkdir(logs_dirname) unless Dir.exist?(logs_dirname)
    # Build a log path file
    file_name = File.join(logs_dirname, "logs.log")
    # NB: the logs/ directory must be created
    File.write(file_name, "#{Time.now}\n", mode: "a")
  end
end
