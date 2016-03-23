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
      [ /as400/i, lambda { |config, column| column.extend(ColumnMethods) } ]
    end

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
      schema = self.schema

      # Executes the +set schema+ statement using the schema identifier provided
      set_schema(schema) if schema && schema != config[:username] && schema != '*LIBL'

      # Changes the current library
      change_current_library(config[:current_library]) if config[:current_library]
    end

    def os400_version
      metadata = jdbc_connection.getMetaData()
      major = metadata.getDatabaseMajorVersion()
      minor = metadata.getDatabaseMinorVersion()
      { major: major, minor: minor }
    end

    # If true, next_sequence_value is called before each insert statement
    # to set the record's primary key.
    # By default DB2 for i supports IDENTITY_VAL_LOCAL for tables that have
    # one primary key.
    def prefetch_primary_key?(table_name = nil)
      return true if table_name.nil?
      table_name = table_name.to_s
      primary_keys(table_name.to_s).size == 0
    end

    # TRUNCATE only works with V7R2+
    # @override
    def truncate(table_name, name = nil)
      if os400_version[:major] < 7 || (os400_version[:major] == 7 && os400_version[:minor] < 2)
        raise NotImplementedError
      else
        super
      end
    end

    # @override
    def rename_column(table_name, column_name, new_column_name)
      column = columns(table_name, column_name).find { |c| c.name == column_name.to_s }
      unless column
        raise ActiveRecord::ActiveRecordError, "No such column: #{table_name}.#{column_name}"
      end
      add_column(table_name, new_column_name, column.type, column.instance_values)
      execute("UPDATE #{quote_table_name(table_name)} SET #{quote_column_name(new_column_name)} = #{quote_column_name(column_name)} WITH NC")
      remove_column(table_name, column_name)
    end

    # @override
    def execute_table_change(sql, table_name, name = nil)
      execute_and_auto_confirm(sql, name)
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

    # Execute system command with +qsys.qcmdexc+
    def execute_system_command(command)
      length = command.length
      command = quote(command)
      execute("CALL qsys.qcmdexc(#{command}, CAST(#{length} AS DECIMAL(15, 5)))")
    end

    # Change current library
    def change_current_library(current_library)
      # *CRTDFT is the nil equivalent for current library
      current_library ||= '*CRTDFT'
      execute_system_command("CHGCURLIB CURLIB(#{current_library})")
    end
  end
end
