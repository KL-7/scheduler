desc "Default: run thin"
task :default => :start

desc "Start thin server"
task :start do
  system "bundle exec rackup -s thin config.ru"
end