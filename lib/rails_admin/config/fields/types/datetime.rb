require 'rails_admin/config/fields/base'

module RailsAdmin
  module Config
    module Fields
      module Types
        class Datetime < RailsAdmin::Config::Fields::Base

          @datepicker_date_format_key = "dateTimeFormat"
          @datepicker_options = {}
          @css_class = "dateTime"
          @column_width = 170
          @format = :long
          @i18n_scope = [:time, :formats]
          @searchable = false
          @sortable = true

          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          class << self

            attr_reader :column_width, :css_class, :searchable, :sortable
            attr_reader :datepicker_date_format_key, :datepicker_options, :format, :i18n_scope

            def abbr_day_names
              begin
                I18n.t('date.abbr_day_names', :raise => true)
              rescue I18n::ArgumentError
                I18n.t('date.abbr_day_names', :locale => :en)
              end
            end

            def abbr_month_names
              begin
                names = I18n.t('date.abbr_month_names', :raise => true)
              rescue I18n::ArgumentError
                names = I18n.t('date.abbr_month_names', :locale => :en)
              end
              names[1..-1]
            end

            def date_format
              I18n.t('date.formats.default', :default => I18n.t('date.formats.default', :locale => :en))
            end

            def day_names
              begin
                I18n.t('date.day_names', :raise => true)
              rescue I18n::ArgumentError
                I18n.t('date.day_names', :locale => :en)
              end
            end

            def month_names
              begin
                names = I18n.t('date.month_names', :raise => true)
              rescue I18n::ArgumentError
                names = I18n.t('date.month_names', :locale => :en)
              end
              names[1..-1]
            end

            def normalize(date_string, format)
              unless I18n.locale == "en"
                format.to_s.match(/%[AaBbp]/).each do |match|
                  case match
                  when '%A'
                    english = I18n.t('date.day_names', :locale => :en)
                    day_names.each_with_index {|d, i| date_string.gsub!(/#{d}/, english[i]) }
                  when '%a'
                    english = I18n.t('date.abbr_day_names', :locale => :en)
                    abbr_day_names.each_with_index {|d, i| date_string.gsub!(/#{d}/, english[i]) }
                  when '%B'
                    english = I18n.t('date.month_names', :locale => :en)
                    month_names.each_with_index {|m, i| date_string.gsub!(/#{m}/, english[i]) }
                  when '%b'
                    english = I18n.t('date.abbr_month_names', :locale => :en)
                    abbr_month_names.each_with_index {|m, i| date_string.gsub!(/#{m}/, english[i]) }
                  when '%p'
                    date_string.gsub!(/#{I18n.t('date.time.am', :default => "am")}/, "am")
                    date_string.gsub!(/#{I18n.t('date.time.pm', :default => "pm")}/, "pm")
                  end
                end
              end
              Date.parse(date_string, format)
            end

          end

          def datepicker_options
            options = {
              self.class.datepicker_date_format_key => datepicker_date_format,
              'firstWeekDay' => 1,
              'icon' => '/images/rails_admin/calendar.png',
              'language' => I18n.locale,
              'locale' => 'en',
              'timePicker' => true,
              'timePickerAdjacent' => true,
              'weekend' => [0,6],
            }

            options = options.merge self.class.datepicker_options

            ActiveSupport::JSON.encode(options).html_safe
          end

          # Ruby to prototype datepicker formatting options translator
          def datepicker_date_format
            # Ruby format options as a key and prototype
            # date extensions format options as a value
            translations = {
              "%a" => "E",          # The abbreviated weekday name ("Sun")
              "%A" => "EE",         # The  full  weekday  name ("Sunday")
              "%b" => "NNN",        # The abbreviated month name ("Jan")
              "%B" => "MMM",        # The  full  month  name ("January")
              "%d" => "dd",         # Day of the month (01..31)
              "%D" => "MM/dd/yy",   # American date format mm/dd/yy
              "%e" => "d",          # Day of the month (1..31)
              "%F" => "yyyy-MM-dd", # ISO 8601 date format
              "%H" => "HH",         # Hour of the day, 24-hour clock (00..23)
              "%I" => "hh",         # Hour of the day, 12-hour clock (01..12)
              "%m" => "MM",         # Month of the year (01..12)
              "%M" => "mm",         # Minute of the hour (00..59)
              "%p" => "a",          # Meridian indicator ("AM" or "PM")
              "%S" => "ss",         # Second of the minute (00..60)
              "%Y" => "yyyy",       # Year with century
              "%y" => "yy",         # Year without a century (00..99)
            }
            format.gsub(/%\w/) {|match| translations[match]}
          end

          register_instance_option(:column_css_class) do
            self.class.css_class
          end

          register_instance_option(:column_width) do
            self.class.column_width
          end

          register_instance_option(:date_format) do
            self.class.format
          end

          register_instance_option(:formatted_value) do
            unless (time = value).nil?
              I18n.l(time, :format => format)
            else
              "".html_safe
            end
          end

          register_instance_option(:parse_input) do |params|
            params[name] = self.class.normalize(params[name], format) if params[name]
          end

          register_instance_option(:searchable?) do
            self.class.searchable
          end

          register_instance_option(:sortable?) do
            self.class.sortable
          end

          register_instance_option(:format) do
            format = date_format.to_sym
            I18n.t(format, :scope => self.class.i18n_scope, :default => [
              I18n.t(format, :scope => self.class.i18n_scope, :locale => :en),
              I18n.t(self.class.format, :scope => self.class.i18n_scope, :locale => :en),
            ]).to_s
          end
        end
      end
    end
  end
end