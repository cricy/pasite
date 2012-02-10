# encoding: utf-8
# http://gembundler.com/deploying.html
require 'bundler/capistrano'

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2-p290@gist'
set :rvm_type, :user

# set this to keep from missing any password prompts
default_run_options[:pty] = true

set :application, "gist"
set :scm, 'git'

default_environment['LANG'] = 'en_US.UTF-8'

task :production do
  load 'deploy/assets'

  set :user, 'xifeng'
  set :gateway, 'login1.corp.alimama.com'
  set :domain, 'ued2.mm.cnz.alimama.com'
  set :deploy_to, "/var/www/host/#{application}"
  set :repository, "git@ued.alimama.com:#{application}.git"
  set :branch, ENV['BRANCH'] || 'master'
  set :rails_env, 'production'

  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{deploy_to}/current; bundle exec thin start -C /etc/thin/#{application}.yml"
  end

  task :stop, :roles => :app do
    run "cd #{deploy_to}/current; bundle exec thin stop -C /etc/thin/#{application}.yml"
  end

  desc "Restart Creative Center"
  task :restart, :roles => :app do
    run "cd #{deploy_to}/current; bundle exec thin restart -O -C /etc/thin/#{application}.yml"
  end
end

task :link_uploads do
  #run "rm -rf #{deploy_to}/current/public/uploads"
  #run "ln -s #{deploy_to}/shared/uploads #{deploy_to}/current/public/uploads"
end
before "deploy:assets:precompile" do
  run "ln -s #{deploy_to}/db/database.yml #{release_path}/config/database.yml"
  run "ln -s #{deploy_to}/db/sphinx.yml #{release_path}/config/sphinx.yml"
end
after 'deploy:symlink', :link_uploads, "deploy:migrate"


default_environment["RUBY_VERSION"] = "ruby 1.9.2"
default_environment["GEM_HOME"] = "/home/xifeng/.rvm/gems/ruby-1.9.2-p290@gist"
default_environment["GEM_PATH"] = "/home/xifeng/.rvm/gems/ruby-1.9.2-p290@gist"
default_environment["BUNDLE_PATH"] = "/home/xifeng/.rvm/gems/ruby-1.9.2-p290@gist"

