require 'test_helper'

class TestConnection < Test::Unit::TestCase
  def test_tasks_registered
    adapter_name = connection.config[:adapter]
    assert_nothing_raised do
      ActiveRecord::Tasks::DatabaseTasks.class_eval{class_for_adapter("#{adapter_name}")}
    end
  end
end