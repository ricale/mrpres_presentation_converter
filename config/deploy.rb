lock '3.6.0'

set :application, "mrpres_converter"
set :repo_url,  "https://github.com/ricale/mrpres_presentation_converter.git"

set :rvm_type, :system

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
