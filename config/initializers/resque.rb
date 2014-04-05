# Dir["#{config.root}/app/jobs/*.rb"].each { |file| require file }

# Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
