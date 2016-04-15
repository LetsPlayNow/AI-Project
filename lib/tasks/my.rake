namespace :my do
  task :clr_gs => :environment do
    GameSession.delete_all
    Player.delete_all
    puts "Success"
  end
  task :c => :clr_gs
end

