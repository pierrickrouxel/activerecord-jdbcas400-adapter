require 'test_helper'

class TestConnection < Test::Unit::TestCase
  def test_system_naming
    assert_false(connection.instance_eval {system_naming?})
    assert_true(system_connection.instance_eval {system_naming?})
  end

  def test_schema
    assert_equal(connection.instance_eval {db2_schema}, config[:schema])
    assert_equal(connection.schema, config[:schema])

    assert_equal(system_connection.instance_eval {db2_schema}, '*LIBL')
    assert_nil(system_connection.schema)
  end
end