desc "Open IRB console for gem development environment"
task :console do
  require "irb"
  require "kapost-util"
  ARGV.clear
  IRB.start
end
