require 'yaml'
namespace :import_settings do
  desc 'Import all'
  task :all, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    ['import_settings:projects',
     'import_settings:locations',
     'import_settings:departments',
     'import_settings:services',
     'import_settings:settings'].each { |task| Rake::Task[task].invoke(path) }
  end

  desc 'Import able gate configuration'
  task :settings, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    common_config = get_common_settings(config)

    roles = get_service_extras(config, 'roles')
    locations = get_service_extras(config, 'locations')
    departments = get_service_extras(config, 'departments')

    data = roles.merge(locations, departments)
    common_config.each do |key, value|
      service = get_service(key)

      unless service
        puts "WARNING: #{service_key} does not exists in services table"
        next
      end

      data[service] = {} unless data.key?(service)
      data[service].merge!({ key => value })
    end

    begin
      Project.create!(id: Setting::COMMON_SETTINGS_PROJECT_ID, name: 'Common-Settings', identifier: 'common')
    rescue StandardError
      puts 'Error while creating Project Common-Settings'
    end

    settings = data.filter_map do |key, value|
      unless service = Service.find_by_identifier(key)
        puts "WARNING: #{key} is not valid to register a setting"
        next
      end

      {
        project_id: Setting::COMMON_SETTINGS_PROJECT_ID,
        service_id: service.id,
        value: value
      }
    end
    config['projects'].each do |project_key, project_value|
      project_id = Project.find_by_identifier(project_key)&.id

      unless project_id
        puts "WARNING: #{project_key} does not exists in projects table"
        next
      end

      project_value.each do |service_key, service_value|
        service_id = Service.find_by_identifier(service_key)&.id
        unless service_id
          puts "WARNING: #{service_key} in #{project_key} does not exists in services table"
          next
        end
        settings.push(
          {
            project_id: project_id,
            service_id: service_id,
            value: service_value || {}
          }
        )
      end
    end

    settings.each do |setting|
      Setting.create!(
        project_id: setting[:project_id],
        service_id: setting[:service_id],
        value: setting[:value].to_json
      )
    rescue StandardError => e
      puts 'Error:'
      puts "\tSaving project_id: #{setting[:project_id]}, service_id: #{setting[:service_id]}"
      puts "\t#{e.message}"
    end

    puts "#{settings.count} settings were created"
  end

  def get_common_settings(config)
    hash_types = %w[roles departments locations projects]
    config.filter { |key, _| !hash_types.include?(key) }
  end

  def get_service(value)
    case value
    when /abstract/i
      'abstract'
    when /asana/i
      'asana'
    when /bamboo/i
      'bamboo'
    when /figma/i
      'figma'
    when /github/i
      'github'
    when /google/i
      'google'
    when /harvest/i
      'harvest'
    when /heroku/i
      'heroku'
    when /invision/i
      'invision'
    when /notion/i
      'notion'
    when /pivotal/i
      'pivotal_tracker'
    when /sentry/i
      'sentry'
    when /slack/i
      'slack'
    when /fino/i
      'fino'
    when /core/i
      'core'
    when /calendar/i
      'calendar'
    end
  end

  def get_service_extras(config, name)
    hash = {}
    config[name].each do |extra_key, extra_value|
      extra_value.each do |service_key, service_value|
        hash[service_key] = { name => {} } unless hash[service_key]
        hash[service_key][name].merge!({ extra_key => service_value })
      end
    end
    hash
  end

  desc 'Import projects'
  task :projects, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    count = 0
    config['projects'].each do |key, _|
      Project.create!(name: key, identifier: key)
      count += 1
    rescue StandardError
      puts "WARNING: #{key} could not be created"
    end
    puts "#{count} of #{config['projects'].count} projects were created"
  end

  desc 'Import departments'
  task :departments, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    count = 0
    config['departments'].each do |key, _|
      Department.create!(name: key, identifier: key)
      count += 1
    rescue StandardError
      puts "WARNING: #{key} could not be created"
    end
    puts "#{count} of #{config['departments'].count} departments were created"
  end

  desc 'Import locations'
  task :locations, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    count = 0
    config['locations'].each do |key, _|
      Location.create!(name: key, identifier: key)
      count += 1
    rescue StandardError
      puts "WARNING: #{key} could not be created"
    end
    puts "#{count} of #{config['locations'].count} locations were created"
  end

  desc 'Import services'
  task :services, [:file_path] => :environment do |_, args|
    path = args[:file_path]
    config = YAML.load_file(path)

    services = get_common_settings(config).map { |key, _| get_service(key) }.uniq
    config['projects'].each do |_, project_value|
      project_value.each do |service_key, _|
        services.push(service_key) unless services.include?(service_key)
      end
    end
    count = 0
    services.each do |service|
      Service.create!(name: service, identifier: service)
      count += 1
    rescue StandardError
      puts "WARNING: #{service} could not be created"
    end
    puts "#{count} of #{services.count} services were created"
  end
end
