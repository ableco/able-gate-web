namespace :create_or_set do
  desc 'Create new admin user or update a existent one as admin'
  task :admin_user, %i[first_name last_name email] => :environment do |_, args|
    first_name = args[:first_name]
    last_name = args[:last_name]
    email = args[:email]
    user = User.where(email: email)
               .first_or_create(
                 first_name: first_name,
                 last_name: last_name,
                 project: Project.first
               )
    user.able_gate_admin = true
    if user.save!
      puts "#{email} was set as Able Gate admin"
    else
      puts user.errors.full_messages.inspect
    end
  end
end
