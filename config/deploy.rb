# frozen_string_literal: true

lock '3.16.0'

server 'oppelt.ru', port: 2222, roles: %w(app db web), primary: true

set :rbenv_ruby,      '3.0.1'
set :application,     'oppelt'
set :repo_url,        'git@github.com:dpr0/oppelt.git'
set :deploy_user,     'deploy'
set :linked_files,    fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/master.key', 'config/credentials.yml.enc', '.env')
set :linked_dirs,     fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
set :keep_releases,   1
set :user,            'deploy'
set :use_sudo,        false
set :stage,           :production
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :ssh_options, {
  user: 'deploy',
  keys: '~/.ssh/id_rsa',
  forward_agent: true,
  auth_methods: %w(publickey password),
  port: 2222
}

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Runs rake assets:precompile'
  task :precompile do
    on roles(:app) do
      execute("cd #{application}/current && RAILS_ENV=production rvm #{ruby_string} do rake assets:precompile") if stage == :production
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      invoke 'deploy'
    end
  end

  before :starting, :check_revision
end
