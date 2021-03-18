COMMON_SETTINGS_PROJECT_ID = Setting::COMMON_SETTINGS_PROJECT_ID

PROJECT_STAGING_ID = 1

projects = [
  { id: COMMON_SETTINGS_PROJECT_ID, name: 'Common-Settings', identifier: 'common' },
  { id: PROJECT_STAGING_ID, name: 'Project Staging', identifier: 'project-staging' },
  { name: 'Tractus', identifier: 'tractus' },
  { name: 'Aloha', identifier: 'aloha' },
  { name: 'Parker Networks', identifier: 'parker' },
  { name: 'Preheels', identifier: 'preheels' },
  { name: 'HSS', identifier: 'hss' },
  { name: 'SNP Media', identifier: 'snp' },
  { name: 'Crestron', identifier: 'crestron' },
  { name: 'Merlin', identifier: 'merlin' },
  { name: 'Codeable', identifier: 'codeable' },
  { name: 'Born This Way', identifier: 'btw' },
  { name: 'CIP', identifier: 'cip' },
  { name: 'Bargain Hunt', identifier: 'bht' },
  { name: 'Able', identifier: 'able' },
  { name: 'Cerebro', identifier: 'cerebro' },
  { name: 'Wishbone', identifier: 'wishbone' },
  { name: 'Mighty Portfolio', identifier: 'mighty' },
  { name: 'Core', identifier: 'core' },
  { name: 'Fino', identifier: 'fino' },
  { name: 'PICI', identifier: 'pici' },
  { name: 'Screening Room', identifier: 'screening' },
  { name: 'We The Action', identifier: 'wta' }
]

services = [
  { name: 'abstract', identifier: 'abstract' },
  { name: 'asana', identifier: 'asana' },
  { name: 'aws', identifier: 'aws' },
  { name: 'bamboohr', identifier: 'bamboohr' },
  { name: 'base', identifier: 'base' },
  { name: 'calendar', identifier: 'calendar' },
  { name: 'core', identifier: 'core' },
  { name: 'dependabot', identifier: 'dependabot' },
  { name: 'fifteenfive', identifier: 'fifteenfive' },
  { name: 'figma', identifier: 'figma' },
  { name: 'fino', identifier: 'fino' },
  { name: 'github', identifier: 'github' },
  { name: 'google', identifier: 'google' },
  { name: 'gsuite', identifier: 'gsuite' },
  { name: 'harvest', identifier: 'harvest' },
  { name: 'heroku', identifier: 'heroku' },
  { name: 'invision', identifier: 'invision' },
  { name: 'notion', identifier: 'notion' },
  { name: 'pivotal_tracker', identifier: 'pivotal_tracker' },
  { name: 'sentry', identifier: 'sentry' },
  { name: 'slack', identifier: 'slack' },
  { name: 'terraform', identifier: 'terraform' }
]

departments = [
  { name: 'Business', identifier: 'business' },
  { name: 'Engineering', identifier: 'engineering' },
  { name: 'Fino', identifier: 'fino' },
  { name: 'Leadership', identifier: 'leadership' },
  { name: 'Product', identifier: 'product' }
]

locations = [
  { name: 'Osaka', identifier: 'osaka' },
  { name: 'Lima', identifier: 'lima' },
  { name: 'Denver', identifier: 'denver' },
  { name: 'San Francisco', identifier: 'sf' },
  { name: 'New York', identifier: 'ny' }
]

projects.each { |project| Project.create!(project) }
services.each { |service| Service.create!(service) }
departments.each { |department| Department.create!(department) }
locations.each { |location| Location.create!(location) }

common_settings = [
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('github').id,
    value: { github_org: 'ableco-staging', github_main_team: 'all' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('sentry').id,
    value: { sentry_org: 'able-96' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('pivotal_tracker').id,
    value: {
      pivotal_account: '1088606',
      roles:
      {
        manager: { projects: %w[staging management] }
      }
    }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('asana').id,
    value: { asana_org: '56913400087271' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('google').id,
    value:
    {
      google_domain: 'staging.able.co',
      departments: { engineering: { teams: ['engineering'] } },
      locations: { lima: { teams: ['engineering'] } }
    }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('harvest').id,
    value: { harvest_account: '1122228' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('fino').id,
    value: { fino_api_url: 'localhost:3000/api/v2' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('figma').id,
    value: { figma_team: '853236092620792094' }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('calendar').id,
    value:
    {
      calendar_prefix: '[All]',
      onboarding_calendar: 'calendar-staging',
      departments:
      {
        engineering: { calendar_prefix: '[Eng]' },
        operations: { calendar_prefix: '[Ops]' }
      }
    }.to_json
  },
  {
    project_id: COMMON_SETTINGS_PROJECT_ID,
    service_id: Service.find_by_name('slack').id,
    value: { slack_channels: %w[announcements water-cooler] }.to_json
  }
]

project_staging_settings =
  [
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('github').id,
      value:
      {
        standard_team: 'staging',
        admin_team: 'staging-admins'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('pivotal_tracker').id,
      value:
      {
        project: 'staging'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('asana').id,
      value:
      {
        team: 'Staging'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('heroku').id,
      value:
      {
        team: 'able-staging'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('google').id,
      value:
      {
        standard_team: 'able-staging-project@staging.able.co',
        admin_team: 'able-staging-admins@staging.able.co'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('harvest').id,
      value:
      {
        project: 'able-staging'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('slack').id,
      value:
      {
        notification_channel: '#able-staging-notifications'
      }.to_json
    },
    {
      project_id: PROJECT_STAGING_ID,
      service_id: Service.find_by_name('sentry').id,
      value:
      {
        team: 'able-staging'
      }.to_json
    }
  ]

common_settings.each { |setting| Setting.create!(setting) }
project_staging_settings.each { |setting| Setting.create!(setting) }

admin_users = [
  {
    first_name: 'Hector',
    last_name: 'Paz',
    email: 'hector@able.co',
    admin: false,
    able_gate_admin: true,
    project_id: PROJECT_STAGING_ID,
    department_id: Department.find_by_identifier("engineering").id,
    location_id: Location.find_by_identifier("lima").id,
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    first_name: 'Marcelo',
    last_name: 'Milera',
    email: 'marcelo@able.co',
    admin: false,
    able_gate_admin: true,
    project_id: PROJECT_STAGING_ID,
    department_id: Department.find_by_identifier("engineering").id,
    location_id: Location.find_by_identifier("lima").id,
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    first_name: 'Cristhiam',
    last_name: 'Teran',
    email: 'cristhiam@able.co',
    admin: false,
    able_gate_admin: true,
    project_id: PROJECT_STAGING_ID,
    department_id: Department.find_by_identifier("engineering").id,
    location_id: Location.find_by_identifier("lima").id,
    created_at: Time.now,
    updated_at: Time.now
  }
]

# inset_all! method will skip callbacks
User.insert_all!(admin_users)
