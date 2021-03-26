config_file = Rails.root.join('config.yaml')
Rake::Task['import_settings:all'].invoke(config_file)
users_file = Rails.root.join('users.yaml')
Rake::Task['import_users:all'].invoke(users_file)
