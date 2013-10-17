# This config script is heavily inspired by GitHub
# https://github.com/blog/517-unicorn

user 'deploy'

case ENV['RACK_ENV']
when 'development'
  deploy_to = '/var/www/adensya'  
  worker_processes 2
when 'production'
  deploy_to = '/var/www/adensya'
  worker_processes 2
end

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{deploy_to}/current/Gemfile"
end

rails_root = "#{deploy_to}/current"
pid_file   = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file = "#{deploy_to}/shared/sockets/unicorn.sock"

old_pid    = pid_file + '.oldbin'

stderr_path "#{deploy_to}/shared/log/unicorn.stderr.log"
stdout_path "#{deploy_to}/shared/log/unicorn.stdout.log"

# working_directory app_directory

timeout 300
listen socket_file, :backlog => 1024

pid pid_file

File.umask(027)

preload_app true

if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # Sidekiq.configure_client do |config|
  #   config.redis = { :url => 'redis://localhost:6379/12', :namespace => 'fish' }
  # end
end