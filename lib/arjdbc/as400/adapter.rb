module ArJdbc
  module AS400
    include DB2
    include System

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
    DRIVER_NAME = 'com.ibm.as400.access.AS400JDBCDriver'.freeze
    NATIVE_DRIVER_NAME = 'com.ibm.db2.jdbc.app.DB2Driver'.freeze

    def adapter_name
      ADAPTER_NAME
    end

    # Set schema is it specified
    def configure_connection
      set_schema(config[:schema]) if config[:schema]
      change_current_library(config[:current_library]) if config[:current_library]
    end

    # Do not return *LIBL as schema
    def schema
      db2_schema
    end

    # Return only migrated tables
    def tables(name = nil)
      if system_naming? and !current_library
        raise StandardError.new('Unable to retrieve tables without current library')
      else
        @connection.tables(nil, name)
      end
    end

    # Prevent migration in QGPL
    def supports_migrations?
      !(system_naming? && !current_library?)
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
      execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(new_column_name)} = #{quote_column_name(column_name)} WITH NC")
      remove_column(table_name, column_name)
    end

    # @override
    def execute_table_change(sql, table_name, name = nil)
      execute_and_auto_confirm(sql, name)
    end

    # Disable all schemas browsing
    def table_exists?(name)
      return false unless name
      @connection.table_exists?(name, schema)
    end

    def indexes(table_name, name = nil)
      @connection.indexes(table_name, name, schema)
    end

    # Disable transactions when they are not supported
    def transaction_isolation_levels
      super.merge({ no_commit: 'NO COMMIT' })
    end

    def begin_isolated_db_transaction(isolation)
      begin_db_transaction
      execute "SET TRANSACTION ISOLATION LEVEL #{transaction_isolation_levels.fetch(isolation)}"
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

    # Holy moly batman! all this to tell AS400 "yes i am sure"
    def execute_and_auto_confirm(sql, name = nil)

      begin
        execute_system_command('CHGJOB INQMSGRPY(*SYSRPYL)')
        execute_system_command("ADDRPYLE SEQNBR(9876) MSGID(CPA32B2) RPY('I')")
      rescue Exception => e
        raise unauthorized_error_message("CHGJOB INQMSGRPY(*SYSRPYL) and ADDRPYLE SEQNBR(9876) MSGID(CPA32B2) RPY('I')", e)
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
          execute_system_command('CHGJOB INQMSGRPY(*DFT)')
          execute_system_command('RMVRPYLE SEQNBR(9876)')
        rescue Exception => e
          raise unauthorized_error_message('CHGJOB INQMSGRPY(*DFT) and RMVRPYLE SEQNBR(9876)', e)
        end

      end
    end

    def unauthorized_error_message(command, exception)
      "Could not call #{command}.\nDo you have authority to do this?\n\n#{exception.inspect}"
    end
  end
end
