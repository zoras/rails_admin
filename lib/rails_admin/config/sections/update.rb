require "rails_admin/config/sections/create"

module RailsAdmin
  module Config
    module Sections
      # Configuration of the edit view for a new object
      class Update < RailsAdmin::Config::Sections::Create
        def initialize(parent)

          super(parent)

          # Primary key fields should be hidden, manipulating them after
          # creation causes difficulties with ActiveRecord
          @fields.each do |f|
            f.hide if f.primary?
          end
        end
      end
    end
  end
end