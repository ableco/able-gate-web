namespace :import_users do
  desc 'Import users'
  task :all, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    count = 0
    config['users'].each do |key, value|
      user = User.new(
        first_name: value['first_name'] || key,
        last_name: value['last_name'] || key,
        email: value['email'],
        github: value['github_handle'],
        project: Project.find_by_identifier(value['team']),
        department: Department.find_by_identifier(value['department']),
        location: Location.find_by_identifier(value['location'])
      )
      if user.save
        count += 1
      else
        puts "- User #{key} could not be created!"
        puts "\t#{user.errors.full_messages}"
      end
    end
    puts "#{count} users were created"
  end
end
