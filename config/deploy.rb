# -*- encoding : utf-8 -*-
require "bundler/capistrano"
require 'sidekiq/capistrano'
load 'deploy/assets'

set :application, "youboard.lazywei.com"
set :repository, "git@git.lazywei.com:lazywei/youboard.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :scm, :git
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

set :user, "lazywei"
set :use_sudo, false

role :web, application                         # Your HTTP server, Apache/etc
role :app, application                         # This may be the same as your `Web` server
role :db,  application, :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do

  task :copy_config_files, :roles => [:app] do
    db_config = "#{shared_path}/database.yml"
    setting_config = "#{shared_path}/setting.yml"
    run "cp #{db_config} #{release_path}/config/database.yml"
    run "cp #{setting_config} #{release_path}/config/setting.yml"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:update_code", "deploy:copy_config_files"


# For "cap tail_logs"

desc "tail production log files" 
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err    
  end
end

# For "cap tail_sidekiq_logs"

desc "tail sidekiq log files" 
task :tail_sidekiq_logs, :roles => :app do
  run "tail -f #{shared_path}/log/sidekiq.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err    
  end
end
