require 'rails_admin/config/fields/types/datetime'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Timestamp < RailsAdmin::Config::Fields::Types::Datetime

          @datepicker_date_format_key = "dateTimeFormat"
          @datepicker_options = {
            'icon' => '/images/rails_admin/clock.png',
          }
          @css_class = "dateTime"
          @column_width = 170
          @format = :long
          @i18n_scope = [:time, :formats]
          @searchable = false
          @sortable = true

          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
        end
      end
    end
  end
end