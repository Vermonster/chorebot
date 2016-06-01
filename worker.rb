require "rack"
require "rufus/scheduler"
require_relative "./chorebot"

$stdout.sync = true

puts "starting http server on port #{ENV["PORT"]} in background thread"
server = Rack::Server.new(
  :config => File.expand_path("../config.ru", __FILE__),
  :Port   => ENV["PORT"]
)
server_thread = Thread.new { server.start }

puts "starting scheduler in foreground"

scheduler = Rufus::Scheduler.new

# first reminder is 9:45am
scheduler.cron "45 9 * * 1-5 #{ENV['TZ']}" do
  morning_chore_messages
end

# last reminder is 4:15pm
scheduler.cron "15 16 * * 1-5 #{ENV['TZ']}" do
  afternoon_chore_messages
end

# cleanup is every Monday at 9:50
scheduler.cron "50 9 * * 1 #{ENV['TZ']}" do
  weekly_cleanup_message
end

# snack message is 9am on Wednesday
scheduler.cron "0 9 * * 3 #{ENV['TZ']}" do
  weekly_snack_message
end

scheduler.join

puts "stopping http server"
server.stop
server_thread.join
