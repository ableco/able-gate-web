projects = [
  { name: 'Tractus' },
  { name: 'Aloha' },
  { name: 'Parker Networks' },
  { name: 'Preheels' },
  { name: 'HSS' },
  { name: 'SNP Media' },
  { name: 'Crestron' },
  { name: 'Merlin' },
  { name: 'Codeable' },
  { name: 'Born This Way' },
  { name: 'CIP' },
  { name: 'Bargain Hunt' },
  { name: 'Able' },
  { name: 'Cerebro' },
  { name: 'Wishbone' },
  { name: 'Mighty Portfolio' },
  { name: 'Core' },
  { name: 'Fino' },
  { name: 'PICI' },
  { name: 'Screening Room' },
  { name: 'We The Action' }
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
  { name: 'Business' },
  { name: 'Engineering' },
  { name: 'Fino' },
  { name: 'Leadership' },
  { name: 'Product' }
]

locations = [
  { name: 'Osaka' },
  { name: 'Lima' },
  { name: 'Denver' },
  { name: 'San Francisco' },
  { name: 'New York' }
]

projects.each { |project| Project.create!(project) }
services.each { |service| Service.create!(service) }
departments.each { |department| Department.create!(department) }
locations.each { |location| Location.create!(location) }

any_project = Project.first

admin_users = [
  { first_name: 'Hector', last_name: 'Paz', email: 'hector@able.co', admin: true, project_id: any_project.id },
  { first_name: 'Marcelo', last_name: 'Milera', email: 'marcelo@able.co', admin: true, project_id: any_project.id },
  { first_name: 'Cristhiam', last_name: 'Teran', email: 'cristhiam@able.co', admin: true, project_id: any_project.id }
]

admin_users.each { |user| User.create!(user) }
