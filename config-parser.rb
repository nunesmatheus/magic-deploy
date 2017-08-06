#!/usr/bin/ruby

require 'yaml'
require 'fileutils'

def quit(error=nil)
  puts error if error
  exit 1
end

def checkout(destination, ref)
  `git clone /app.git #{destination}`
  `git --work-tree=#{destination} --git-dir=#{destination}/.git checkout -f #{ref}`
  Dir.chdir destination
end

begin
  from, to, branch = STDIN.gets.chomp.split " "

  checkout "/tmp/#{ARGV[0]}", to

  unless File.exists? 'magic-deploy.yml'
    quit 'ERROR: magic-deploy.yml not found!'
  end

  app_config = YAML.load_file 'magic-deploy.yml'
  quit "ERROR: magic-deploy.yml has no content!" unless app_config

  application = app_config['application']
  if application == nil
    quit "ERROR: 'application' key on magic-deploy.yml not found!"
  end

  app_directory = "/apps/#{application}"
  Dir.mkdir app_directory unless Dir.exists?(app_directory)

  File.open("set_env_vars.sh", 'w') do |f|
    f.puts File.read('/set_env_vars.sh')
    f.puts "APPLICATION_NAME=#{application}"
  end
rescue Exception => e
  puts 'ERROR'
  quit e.message
end
