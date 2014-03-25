require 'arjdbc/db2/adapter'

module ArJdbc
  module AS400
    include DB2

    # @private
    def self.extended(adapter); DB2.extended(adapter); end

    # @private
    def self.initialize!; DB2.initialize!; end

    # @see ActiveRecord::ConnectionAdapters::JdbcAdapter#jdbc_connection_class
    def self.jdbc_connection_class; DB2.jdbc_connection_class; end

    # @see ActiveRecord::ConnectionAdapters::Jdbc::ArelSupport
    def self.arel_visitor_type(config = nil); DB2.arel_visitor_type(config); end

    def self.column_selector
      [ /as400/i, lambda { |config, column| column.extend(Column) } ]
    end

    # @private
    Column = DB2::Column

    # Boolean emulation can be disabled using :
    #
    #   ArJdbc::AS400.emulate_booleans = false
    #
    def self.emulate_booleans; DB2.emulate_booleans; end
    def self.emulate_booleans=(emulate); DB2.emulate_booleans = emulate; end

    ADAPTER_NAME = 'AS400'.freeze

    def adapter_name
      ADAPTER_NAME
    end

    # Return only migrated tables
    def tables
      if config[:current_library]
        @connection.tables(nil, config[:current_library])
      else
        @connection.tables(nil, schema)
      end
    end

    # Force migration in current library
    def create_table(name, options = {})
      execute("SET SCHEMA #{config[:current_library]}") if config[:current_library]
      super
      execute('SET SCHEMA DEFAULT') if config[:current_library]
    end

    # Prevent migration in QGPL
    def supports_migrations?
      !(system_naming? && config[:current_library].nil?)
    end

    # @override
    def prefetch_primary_key?(table_name = nil)
      return true if table_name.nil?
      table_name = table_name.to_s
      columns(table_name).count { |column| column.primary } == 0
    end

    # @override
    def rename_column(table_name, column_name, new_column_name)
      column = columns(table_name, column_name).find { |column| column.name == column_name.to_s}
      add_column(table_name, new_column_name, column.type, column.instance_values)
      execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(new_column_name)} = #{quote_column_name(column_name)}")
      remove_column(table_name, column_name)
    end

    # @override
    def execute_table_change(sql, table_name, name = nil)
      execute_and_auto_confirm(sql, name)
    end

    # holy moly batman! all this to tell AS400 "yes i am sure"
    def execute_and_auto_confirm(sql, name = nil)

      begin
        execute_system_command('QSYS/CHGJOB INQMSGRPY(*SYSRPYL)')
        execute_system_command("ADDRPYLE SEQNBR(9876) MSGID(CPA32B2) RPY('I')")
      rescue Exception => e
        raise "Could not call CHGJOB INQMSGRPY(*SYSRPYL) and ADDRPYLE SEQNBR(9876) MSGID(CPA32B2) RPY('I').\n" +
              "Do you have authority to do this?\n\n#{e.inspect}"
      end

      begin
        result = execute(sql, name)
      rescue Exception
        raise
      else
        # Return if all work fine
        result
      ensure

        # Ensure default configuration restoration
        begin
          execute_system_command('QSYS/CHGJOB INQMSGRPY(*DFT)')
          execute_system_command('RMVRPYLE SEQNBR(9876)')
        rescue Exception => e
          raise "Could not call CHGJOB INQMSGRPY(*DFT) and RMVRPYLE SEQNBR(9876).\n" +
                    "Do you have authority to do this?\n\n#{e.inspect}"
        end

      end
    end
    private :execute_and_auto_confirm

    # Disable all schemas browsing
    def table_exists?(name)
      return false unless name
      @connection.table_exists?(name, schema)
    end

    def indexes(table_name, name = nil)
      @connection.indexes(table_name, name, schema)
    end

    DRIVER_NAME = 'com.ibm.as400.access.AS400JDBCDriver'.freeze
    NATIVE_DRIVER_NAME = 'com.ibm.db2.jdbc.app.DB2Driver'.freeze

    # Set schema is it specified
    def configure_connection
      set_schema(config[:schema]) if config[:schema]
    end

    # Do not return *LIBL as schema
    def schema
      db2_schema
    end

    def execute_system_command(command)
      length = command.length
      command = ::ActiveRecord::Base.sanitize(command)
      @connection.execute_update("CALL qsys.qcmdexc(#{command}, CAST(#{length} AS DECIMAL(15, 5)))")
    end

    # Disable transactions when they are not supported
    def begin_db_transaction
      super unless config[:transaction_isolation] == 'none'
    end

    def commit_db_transaction
      super unless config[:transaction_isolation] == 'none'
    end

    def rollback_db_transaction
      super unless config[:transaction_isolation] == 'none'
    end

    def begin_isolated_db_transaction(isolation)
      super unless config[:transaction_isolation] == 'none'
    end

    def create_savepoint(name = current_savepoint_name(true))
      super unless config[:transaction_isolation] == 'none'
    end

    private
    # If naming is really in system mode CURRENT_SCHEMA is *LIBL
    def system_naming?
      schema == '*LIBL'
    end

    # SET SCHEMA statement put connection in sql naming
    def set_schema(schema)
      execute("SET SCHEMA #{schema}")
    end

    # @override
    def db2_schema
      return @db2_schema if defined? @db2_schema
      @db2_schema =
        if config[:schema].present?
          config[:schema]
        else
          # Only found method to set db2_schema from jndi
          result = select_one('VALUES CURRENT_SCHEMA')
          result['00001']
        end
    end
  end
end
