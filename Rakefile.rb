desc "Clean build directory"
task :clean do
  system_or_exit "rm -rf #{build_root}/*"
end

desc "Pull changes from origin master"
task :pull do
  system_or_exit "git pull --rebase origin master"
end

desc "Run all specs"
task :specs => [:clean, "ObjectPropertyMapper:specs"]

desc "Push changes to origin master"
task :push do
  system_or_exit "git push origin master"
end

desc "Integrate local changes"
task :integrate => [:pull, :specs, :push]

namespace :ObjectPropertyMapper do
  scheme_name = 'ObjectPropertyMapper'
  app_target_name = 'ObjectPropertyMapper'

  desc "Build ObjectPropertyMapper"
  task :build do
    system_or_exit "xcodebuild -scheme #{scheme_name} build SYMROOT='#{build_root}'", output_file("build-#{app_target_name}")
  end

  desc "Run spec bundle against ObjectPropertyMapper"
  task :specs do
    system_or_exit "xcodebuild -scheme #{scheme_name} test SYMROOT='#{build_root}'"
  end
end


#
#  Helper functions
#

def project_root
  File.dirname(__FILE__)
end

def build_root
  build_root = File.join(project_root, "build")
  Dir.mkdir(build_root) unless File.exists?(build_root)
  build_root
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or raise ">>>>>>> Command failed"
end

def output_file(target)
  output_file = File.join(build_root, "#{target}.output")
  puts "Output: #{output_file}"
  output_file
end
