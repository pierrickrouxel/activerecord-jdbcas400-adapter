require 'test_helper'

class TestAdapter < Test::Unit::TestCase
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
end