#############################################################
# New Relic
# require 'new_relic/recipes'# require 'new_relic/recipes'

#############################################################
# RVM bootstrap
# $:.unshift(File.expand_path("~/.rvm/lib"))

require 'rvm/capistrano'
set :rvm_type, :system

set :keep_releases, 20

set :application, 'mcnlp'
#############################################################
# Bundler bootstrap
require 'bundler/capistrano'

#############################################################
# Capistrano Colors
require 'capistrano_colors'

#############################################################
# Multistage
# require 'capistrano/ext/multistage'
# set :default_stage, "staging"
# set :stages, %w(production staging)

#############################################################
# Whenever
# require "whenever/capistrano"
# set :whenever_command, "bundle exec whenever"
# set :whenever_environment, "production"


# set :rvm_type, :system
set :application, "adensya"
set :deploy_to, "/var/www/adensya"

set :rails_env, "production"
set :user, "deploy"

role :app, 'shmoter.ru'
role :web, 'shmoter.ru'
role :db,  'shmoter.ru', :primary => true

# set :rvm_ruby_string, '1.9.3-p385'
set :rvm_ruby_string, '2.0.0-p0'
# set :rvm_type, :system



#############################################################
# Settings
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :group_writable, false
set :scm_verbose, true

#############################################################
# Git
set :scm, :git
set :repository, "git@github.com:benone/adensya.git"
set :deploy_via, :remote_cache

set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :shared_children, shared_children << "#{deploy_to}/shared/sockets/unicorn.sock"

namespace :deploy do
  # task :parse do
  #   run "cd #{release_path}; /home/kirill/.rvm/gems/ruby-1.9.2-p180@pluslook/bin/rake parse:feed RAILS_ENV=production"
  # end

  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then #{try_sudo} kill -USR2 `cat #{unicorn_pid}`; else cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D; fi"
  end


  task :clear_cache, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle exec rake RAILS_ENV=production cache:clear"
  end
  
  task :build_assets, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:clean"
    run "cd #{release_path}; bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile"
  end
  
  task :create_symlinks do
    run "ln -nfs #{deploy_to}/#{shared_dir}/log #{release_path}/log"
    run "ln -nfs #{deploy_to}/#{shared_dir}/tmp #{release_path}/tmp"
    

  end
  
  
  
end

rails_env = "production"



# after "deploy:update_code", "deploy:bundle"
after "deploy:update_code", "deploy:create_symlinks"
after "deploy:update_code", "deploy:build_assets"
# after "deploy", "deploy:create_sitemaps"
# after "deploy", "deploy:clear_cache"
after "deploy", "deploy:cleanup"
# after "deploy:update_code", "ts:reindex"
# after "deploy", "delayed_job:restart"



# location ~*^(?!\/assets\/).+\.(jpg|jpeg|gif|png|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|wav|bmp|rtf|js|swf)$
# after "deploy:start", "delayed_job:start" 
# after "deploy:stop", "delayed_job:stop" 
# after "deploy:restart", "delayed_job:restart"