require 'arjdbc'
require 'arjdbc/db2/adapter'
require 'arjdbc/as400/connection_methods'
require 'arjdbc/as400/adapter'

# Register AS400 to database tasks
require 'arjdbc/tasks/database_tasks'
module ArJdbc
  module Tasks

    require 'arjdbc/tasks/db2_database_tasks'
    register_tasks(/as400/, DB2DatabaseTasks)

  end
end
