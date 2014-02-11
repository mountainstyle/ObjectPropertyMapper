# Copyright (c) 2013-2014 Pivotal Labs.  This software is licensed under the MIT License.

desc 'Clean build directory'
task :clean do
  system_do "rm -rf #{build_dir}/*"
end

desc 'Pull changes from origin master'
task :pull do
  system_do 'git pull --rebase origin master'
end

desc 'Run all specs'
task :spec => [:clean, 'ObjectPropertyMapper:spec']

desc 'Push changes to origin master'
task :push do
  system_do 'git push origin master'
end

desc 'Integrate local changes'
task :integrate => [:pull, :spec, :push]

namespace :ObjectPropertyMapper do
  scheme_name = 'ObjectPropertyMapper'

  desc 'Build ObjectPropertyMapper'
  task :build do
    system_do "xcodebuild -scheme #{scheme_name} build SYMROOT='#{build_dir}'"
  end

  desc 'Run spec bundle against ObjectPropertyMapper'
  task :spec do
    system_do "xcodebuild -scheme #{scheme_name} clean build test SYMROOT='#{build_dir}'"
  end
end


#
#  Helper functions
#

def system_do(command)
  puts "$ #{command}"
  system(command) or raise '>>>>>>> Command failed'
end

def project_dir
  File.dirname(__FILE__)
end

def build_dir
  build_dir = File.join(project_dir, 'build')
  Dir.mkdir(build_dir) unless File.exists?(build_dir)
  build_dir
end
