#!/usr/bin/ruby

require 'yaml'
require 'fileutils'

def quit(error=nil)
  puts error if error
  Dir.chdir '/app.git'
  FileUtils.rm_rf('/deploy')
  exit 1
end

begin
  from, to, branch = ARGF.read.split " "

  `git clone /app.git /deploy`
  Dir.chdir '/deploy'
  `git --work-tree=/deploy --git-dir=/deploy/.git checkout #{to}`

  unless File.exists? 'magic-deploy.yml'
    puts 'ERROR: magic-deploy.yml not found!' and quit
  end

  app_config = YAML.load_file 'magic-deploy.yml'
  unless app_config
    puts "ERROR: magic-deploy.yml has no content!" and quit
  end

  application = app_config['application']
  unless application != nil
    puts "ERROR: 'application' key on magic-deploy.yml not found!" and quit
  end

  puts "Received application '#{application}'"
  current_config = File.read('/set_env_vars.sh')
  return if current_config.include? 'APPLICATION_NAME'

  File.open('/set_env_vars.sh', 'a') do |f|
    f.puts "APPLICATION_NAME=#{application}"
  end
rescue Exception => e
  quit(e.message)
end
~
