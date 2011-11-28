desc "Default: run thin"
task :default => :start

desc "Start thin server"
task :start do
  system "shotgun --server=thin config.ru"
end