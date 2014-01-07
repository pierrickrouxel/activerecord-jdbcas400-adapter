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

  def test_migration_support
    assert_true(connection.supports_migrations?)

    connection = system_connection
    connection.config[:current_library] = 'QTEMP'
    assert_true(connection.supports_migrations?)

    connection.config[:current_library] = nil
    assert_false(connection.supports_migrations?)
  end
end