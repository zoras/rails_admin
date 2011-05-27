require 'active_support/core_ext/string/inflections'
require 'rails_admin/generic_support'

module RailsAdmin
  class AbstractModel

    @models = []

    # Returns all models for a given Rails app
    def self.all
      if @models.empty?
        if RailsAdmin::Config.included_models.any?
          # Whitelist approach, use only models explicitly listed
          possible_models = RailsAdmin::Config.included_models.map(&:to_s)
        else
          # orig regexp -- found 'class' even if it's within a comment or a quote
          filenames = Dir.glob(Rails.application.paths.app.models.collect { |path| File.join(path, "**/*.rb") })
          class_names = []
          filenames.each do |filename|
            class_names += File.read(filename).scan(/class ([\w\d_\-:]+)/).flatten
          end
          possible_models = Module.constants | class_names
        end

        excluded_models = RailsAdmin::Config.excluded_models.map(&:to_s)
        excluded_models << ['History']

        #Rails.logger.info "possible_models: #{possible_models.inspect}"
        add_models(possible_models, excluded_models)

        #Rails.logger.info "final models: #{@models.map(&:model).inspect}"
        @models.sort!{|x, y| x.model.to_s <=> y.model.to_s}
      end

      @models
    end

    def self.add_models(possible_models=[], excluded_models=[])
      possible_models.each do |possible_model_name|
        next if excluded_models.include?(possible_model_name)
        #Rails.logger.info "possible_model_name: #{possible_model_name.inspect}"
        add_model(possible_model_name)
      end
    end

    def self.add_model(model_name)
      model,orm_adapter = *lookup(model_name,false)
      @models << new(model) if model
    end
    
    def self.orm_adapters
      @orm_adapters if @orm_adapters
      @orm_adapters = []
      if defined?(ActiveRecord)
        require 'rails_admin/adapters/active_record'
        @orm_adapters << RailsAdmin::Adapters::ActiveRecord
      end
      if defined?(Mongoid)
        require 'rails_admin/adapters/mongoid'
        @orm_adapters << RailsAdmin::Adapters::Mongoid
      end
    end

    # Given a string +model_name+, finds the corresponding model class
    def self.lookup(model,raise_error=true)
      unless model.is_a?(Class)
        begin
          model = model.to_s.camelize.constantize
        rescue NameError
          #Rails.logger.info "#{model_name} wasn't a model"
          raise "RailsAdmin could not find model #{model_name}" if raise_error
          return [nil,nil]
        end
      end
      
      adapter = orm_adapters.select {|one| one.can_handle_model(model)}.first
      
      if adapter
        [model,adapter]
      else
        [nil,nil]
      end

    end

    attr_accessor :model

    def initialize(model)
      model,orm_adapter = *self.class.lookup(model)
      @model = model
      self.extend(GenericSupport) 
      self.extend(orm_adapter) if orm_adapter
    end 
    
    private

    def self.superclasses(klass)
      superclasses = []
      while klass
        superclasses << klass.superclass if klass && klass.superclass
        klass = klass.superclass
      end
      superclasses
    end
  end
end