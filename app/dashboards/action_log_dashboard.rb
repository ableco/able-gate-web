require 'administrate/base_dashboard'

class ActionLogDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    user: Field::String,
    project: Field::String,
    service: Field::String,
    note: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    action: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                        field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                      }),
    status: Field::Select.with_options(searchable: false, collection: lambda { |field|
                                                                        field.resource.class.send(field.attribute.to_s.pluralize).keys
                                                                      })
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    user
    action
    project
    service
    status
    note
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    project
    service
    note
    created_at
    updated_at
    action
    status
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    user
    project
    service
    note
    action
    status
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how action logs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(action_log)
  #   "ActionLog ##{action_log.id}"
  # end
end
