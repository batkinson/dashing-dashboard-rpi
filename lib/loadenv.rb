require 'dotenv'

envfile = File.expand_path(File.dirname(__FILE__) + '/..') + '/.env'
Dotenv.load(envfile)
puts("Loading environment from #{envfile}")
