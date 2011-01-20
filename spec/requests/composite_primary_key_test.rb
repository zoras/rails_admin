require 'spec_helper'

describe 'a model with natural composite primary keys' do

  before(:all) do
    RailsAdmin::Config.excluded_models = []
  end

  after(:all) do
    RailsAdmin::Config.excluded_models = [RelTest, CompositePrimaryKeyTest]
    RailsAdmin::AbstractModel.instance_variable_get("@models").clear
    RailsAdmin::Config.reset
  end

  before(:each) do
    @abstract_model = RailsAdmin::AbstractModel.new(CompositePrimaryKeyTest)
    @object = @abstract_model.create(:pk1 => 1, :pk2 => "test", :pk3 => "2011-01-01")
  end

  it 'should report correct primary keys' do
    @abstract_model.primary_keys.should == ["pk1", "pk2", "pk3"]
  end

  it 'should report primary key value correctly' do
    @abstract_model.get_id(@object).should == [1, "test", Date.parse("2011-01-01")]
  end

  it 'should have a create page with primary key fields visible' do
    get rails_admin_new_path(:model_name => @abstract_model.to_param)

    response.should have_tag(".field") do |elements|
      elements.should have_tag("#composite_primary_key_tests_pk1")
      elements.should have_tag("#composite_primary_key_tests_pk2")
      elements.should have_tag("#composite_primary_key_tests_pk3")
      elements.should have_tag("#composite_primary_key_tests_description")
    end
  end

  it 'should have an update page with primary key fields hidden' do

    get rails_admin_edit_path(:model_name => @abstract_model.to_param, :id => @abstract_model.get_id(@object))

    response.should have_tag(".field") do |elements|
      elements.should_not have_tag("#composite_primary_key_tests_pk1")
      elements.should_not have_tag("#composite_primary_key_tests_pk2")
      elements.should_not have_tag("#composite_primary_key_tests_pk3")
      elements.should have_tag("#composite_primary_key_tests_description")
    end
  end
end
