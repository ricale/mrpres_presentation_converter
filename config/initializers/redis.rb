uri = URI.parse(ENV["REDISTOGO_URL"])
$redis = Redis.connect(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis = $redis
