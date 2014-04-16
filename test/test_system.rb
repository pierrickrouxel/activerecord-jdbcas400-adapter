require 'test_helper'

class TestAdapter < Test::Unit::TestCase
  def test_execute_system_command
    assert_nothing_raised do
      connection.execute_system_command('DSPJOBLOG')
    end
  end

  def test_change_current_library
    connection = system_connection
    assert_nothing_raised do
      connection.change_current_library('QGPL')
      connection.change_current_library(nil)
    end
  end

  def test_current_library
    connection = system_connection
    connection.change_current_library('QSYS')
    assert_equal(connection.current_library, 'QSYS')
    assert_true(connection.current_library?)

    connection.change_current_library(nil)
    assert_nil(connection.current_library)
    assert_false(connection.current_library?)
  end

  def test_change_libraries
    connection = system_connection
    assert_nothing_raised do
      connection.change_libraries(%w(QGPL QTEMP))
      connection.change_libraries(nil)
    end
  end
end