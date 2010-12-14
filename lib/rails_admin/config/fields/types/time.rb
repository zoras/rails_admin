require 'rails_admin/config/fields/types/datetime'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Time < RailsAdmin::Config::Fields::Types::Datetime

          @datepicker_date_format_key = "timeFormat"
          @datepicker_options = {
            'datePicker' => false,
            'icon' => '/images/rails_admin/clock.png',
          }
          @css_class = "time"
          @column_width = 60
          @i18n_scope = [:time, :formats]
          @searchable = false
          @sortable = true

          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option(:format) do
            "%I:%M%p"
          end
        end
      end
    end
  end
end