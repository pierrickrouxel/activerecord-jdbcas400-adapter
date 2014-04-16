require 'test_helper'

class TestAdapter < Test::Unit::TestCase

  def test_schema
    assert_equal(connection.schema, config[:schema])
    assert_equal(system_connection.schema, '*LIBL')
  end

  def test_system_naming?
    assert_false(connection.instance_eval {system_naming?})
    assert_true(system_connection.instance_eval {system_naming?})
  end

  def test_supports_migrations?
    assert_true(connection.supports_migrations?)

    system_connection.change_current_library('QGPL')
    assert_true(system_connection.supports_migrations?)

    system_connection.change_current_library(nil)
    assert_false(system_connection.supports_migrations?)
  end

  def test_prefetch_primary_key?
    begin
      connection.execute('CREATE TABLE test_table (test_column INTEGER)')
      assert_true(connection.prefetch_primary_key?('test_table'))
    ensure
      connection.execute('DROP TABLE test_table')
    end

    begin
      connection.execute('CREATE TABLE test_table (test_column INTEGER, PRIMARY KEY(test_column))')
      assert_false(connection.prefetch_primary_key?('test_table'))
    ensure
      connection.execute('DROP TABLE test_table')
    end
  end

  def test_rename_column
    begin
      connection.execute('CREATE TABLE test_table (test_column INTEGER)')
      connection.execute('INSERT INTO test_table(test_column) VALUES(1)')

      connection.rename_column('test_table', 'test_column', 'new_test_column')
      assert_not_nil(connection.columns('test_table').find { |column| column.name == 'new_test_column' })
      assert_equal(connection.select_one('SELECT new_test_column FROM test_table')['new_test_column'], 1)
    ensure
      connection.execute('DROP TABLE test_table')
    end
  end

end