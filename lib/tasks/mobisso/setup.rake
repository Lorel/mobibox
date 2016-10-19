desc 'Setup MobiSSO'


migration_content =<<MIG
class ChangeUserToMeetMobiSso < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      @COLUMNDEF
    end
  end
end
MIG

namespace :mobisso do
  task :setup => :environment do
    puts "Checking User missing columns..."


    align = "  "*3
    newcols = []

    {
      integer: ['sso_id', 'stu_id'],
      string: ['account', 'email', 'name', 'nickname'],
      index: ['sso_id', 'stu_id', 'account']
    }.each do |k,v|
      v.each do |atr|
        c = User.columns.find{ |c| c.name==atr }
        next unless c.nil?
        newcols << "t.#{k} :#{atr}"
      end
    end

    if newcols.empty?
        puts "User is already satsisfied with SSO!"
        return
    end

    new_col_statement = newcols.join("\n#{align}")

    migration_content.gsub!("@COLUMNDEF", new_col_statement)

    path = Rails.root.join('db', 'migrate')
    t = Time.now.strftime("%Y%m%d%H%M%S")
    filename = "#{t}_change_user_to_meet_mobi_sso.rb"
    File.open("#{path}/#{filename}", "w") do |f|
        f.puts migration_content
    end

    "Migration #{filename} generate"
  end
end
