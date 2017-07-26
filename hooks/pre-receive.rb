#!/usr/bin/ruby

require 'yaml'
require 'fileutils'

def quit(error=nil)
  puts error if error
  Dir.chdir '/app.git'
  FileUtils.rm_rf('/deploy')
  exit 1
end

def bash_command(command)
  system(command, out: $stdout, err: :out)
end

begin
  from, to, branch = ARGF.read.split " "

  repo = `pwd`
  `git clone /app.git /deploy`
  Dir.chdir '/deploy'
  `git --work-tree=/deploy --git-dir=/deploy/.git checkout #{to}`

  unless File.exists? 'magic-deploy.yml'
    puts 'ERROR: magic-deploy.yml not found!'
    quit
  end

  app_config = YAML.load_file 'magic-deploy.yml'
  unless app_config
    puts "ERROR: magic-deploy.yml has no content!"
    quit
  end

  application = app_config['application']
  unless application != nil
    puts "ERROR: 'application' key on magic-deploy.yml not found!"
    quit
  end

  project_config = YAML.load_file('/project-config.yml')

  ENV['DOCKER_API_VERSION'] = "#{project_config['docker_api_version']}"

  `cp -r /buildpack .`

  bash_command("docker build -t #{application} .")
  tag_hash=`< /dev/urandom tr -dc a-z-0-9 | head -c10`
  project_id = project_config['project_id']
  application_tag = "gcr.io/#{project_id}/#{application}:#{tag_hash}"
  latest_tag = "gcr.io/#{project_id}/#{application}:latest"

  bcash_command("docker tag #{application} #{application_tag}")
  bcash_command("docker tag #{application} #{latest_tag}")
  bcash_command("docker login -u _json_key -p #{project_config['container_registry_sa']} https://gcr.io")
  bcash_command("docker push #{application_tag}")
  bcash_command("docker push #{latest_tag}")
  bcash_command("/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file /gke_sa.json --project #{project_id}")
  bcash_command("/google-cloud-sdk/bin/gcloud container clusters get-credentials #{project_config['cluster']} --zone $ZONE")
  bcash_command("kubectl set image deployment #{application} #{application}=#{application_tag}")
rescue Exception => e
  quit(e.message)
end
~
