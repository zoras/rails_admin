require 'rails_admin/config/fields/types/datetime'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Date < RailsAdmin::Config::Fields::Types::Datetime

          @datepicker_date_format_key = "dateFormat"
          @datepicker_options = {
            'datePicker' => true,
            'timePicker' => false,
            'timePickerAdjacent' => false,
          }
          @css_class = "date"
          @column_width = 90
          @format = :long
          @i18n_scope = [:date, :formats]
          @searchable = false
          @sortable = true

          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
        end
      end
    end
  end
end