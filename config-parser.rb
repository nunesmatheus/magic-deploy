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
    quit 'magic-deploy.yml not found!'
  end

  app_config = YAML.load_file 'magic-deploy.yml'
  quit "magic-deploy.yml has no content!" unless app_config

  application = app_config['application']
  if application == nil
    quit "'application' key on magic-deploy.yml not found!"
  end

  before_deploy_command = app_config['before_deploy_command']
  if before_deploy_command.is_a?(Array) && before_deploy_command.any?
    before_deploy_command = before_deploy_command.join ' && '
  else
    before_deploy_command = ''
  end

  deploy_command = app_config['deploy_command']
  if deploy_command.is_a?(Array) && deploy_command.any?
    deploy_command = deploy_command.join ' && '
  else
    deploy_command = 'kubectl set image deployment $APPLICATION_NAME $APPLICATION_NAME=$APPLICATION_TAG'
  end

  app_directory = "/apps/#{application}"
  Dir.mkdir app_directory unless Dir.exists?(app_directory)

  File.open("set_env_vars.sh", 'w') do |f|
    f.puts File.read('/set_env_vars.sh')
    f.puts "APPLICATION_NAME=#{application}"
    f.puts "BEFORE_DEPLOY_COMMAND='#{before_deploy_command}'"
    f.puts "DEPLOY_COMMAND='#{deploy_command}'"
  end
rescue Exception => e
  quit "ERROR #{e.message}"
end
