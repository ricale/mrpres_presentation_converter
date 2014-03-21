set :application, "mrpres_converter"
set :repository,  "git@github.com:ricale/mrpres_presentation_converter.git"

set :scm, :git

set :user, 'root'
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "ricalest.net"                          # Your HTTP server, Apache/etc
role :app, "ricalest.net"                          # This may be the same as your `Web` server
role :db,  "ricalest.net", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

ssh_options[:forward_agent] = true
default_run_options[:pty] = true