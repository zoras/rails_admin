require 'active_record'
require 'rails_admin/config/sections/list'

module RailsAdmin
  module Adapters
    module ActiveRecord
      def get(ids)
        ids = [ids] unless ids.kind_of?(Array)
        query = {}
        primary_keys.each_with_index do |pk, i|
          query[pk] = ids[i]
        end
        model.where(query).first
      rescue ::ActiveRecord::RecordNotFound
        nil
      end

      def count(options = {})
        model.count(options.reject{|key, value| [:sort, :sort_reverse].include?(key)})
      end

      def first(options = {})
        model.first(merge_order(options))
      end

      def all(options = {})
        model.all(merge_order(options))
      end

      def paginated(options = {})
        page = options.delete(:page) || 1
        per_page = options.delete(:per_page) || RailsAdmin::Config::Sections::List.default_items_per_page

        page_count = (count(options).to_f / per_page).ceil

        options.merge!({
          :limit => per_page,
          :offset => (page - 1) * per_page
        })

        [page_count, all(options)]
      end

      def create(params = {})
        model.create(params)
      end

      def new(params = {})
        model.new(params)
      end

      def destroy_all!
        model.all.each do |object|
          object.destroy
        end
      end

      def has_and_belongs_to_many_associations
        associations.select do |association|
          association[:type] == :has_and_belongs_to_many
        end
      end

      def has_many_associations
        associations.select do |association|
          association[:type] == :has_many
        end
      end

      def has_one_associations
        associations.select do |association|
          association[:type] == :has_one
        end
      end

      def belongs_to_associations
        associations.select do |association|
          association[:type] == :belongs_to
        end
      end

      def associations
        model.reflect_on_all_associations.map do |association|
          {
            :name => association.name,
            :pretty_name => association.name.to_s.gsub('_', ' ').capitalize,
            :type => association.macro,
            :parent_model => association_parent_model_lookup(association),
            :parent_key => association_parent_key_lookup(association),
            :child_model => association_child_model_lookup(association),
            :child_key => association_child_key_lookup(association),
          }
        end
      end

      # Get an array of object's primary keys' values
      def get_id(object)
        primary_keys.map{|pk| object.send(pk)}
      end

      # ActiveRecord doesn't report composite primary keys properly, so we'll
      # query them via connection adapter's table_structure method
      def primary_keys
        @primary_keys ||= model.connection.send(:table_structure, model.table_name).select{|c| c["pk"] == 1}.map{|c| c["name"]}
      end

      def properties
        model.columns.map do |property|
          {
            :name => property.name.to_sym,
            :pretty_name => property.name.to_s.gsub('_', ' ').capitalize,
            :type => property.type,
            :length => property.limit,
            :nullable? => property.null,
            :serial? => property.primary,
            :primary? => !primary_keys.find{|pk| pk == property.name}.nil?
          }
        end
      end

      def model_store_exists?
        model.table_exists?
      end

      private

      def merge_order(options)
        @sort ||= options.delete(:sort) || primary_keys.first
        @sort_order ||= options.delete(:sort_reverse) ? "asc" : "desc"
        options.merge(:order => "#{@sort} #{@sort_order}")
      end

      def association_parent_model_lookup(association)
        case association.macro
        when :belongs_to
          association.klass
        when :has_one, :has_many, :has_and_belongs_to_many
          association.active_record
        else
          raise "Unknown association type: #{association.macro.inspect}"
        end
      end

      def association_parent_key_lookup(association)
        [:id]
      end

      def association_child_model_lookup(association)
        case association.macro
        when :belongs_to
          association.active_record
        when :has_one, :has_many, :has_and_belongs_to_many
          association.klass
        else
          raise "Unknown association type: #{association.macro.inspect}"
        end
      end

      def association_child_key_lookup(association)
        case association.macro
        when :belongs_to
          ["#{association.class_name.underscore}_id".to_sym]
        when :has_one, :has_many, :has_and_belongs_to_many
          [association.primary_key_name.to_sym]
        else
          raise "Unknown association type: #{association.macro.inspect}"
        end
      end
    end
  end
end