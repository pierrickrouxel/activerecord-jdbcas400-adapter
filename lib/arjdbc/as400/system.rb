module ArJdbc
  module AS400
    module System

      # Execute system command with QSYS.QCMDEXC
      def execute_system_command(command)
        length = command.length
        command = quote(command)
        execute("CALL QSYS.QCMDEXC(#{command}, CAST(#{length} AS DECIMAL(15, 5)))")
      end

      # Change current library
      def change_current_library(current_library)
        @current_library = current_library
        # *CRTDFT is the nil equivalent for current library
        current_library ||= '*CRTDFT'
        execute_system_command("CHGCURLIB CURLIB(#{current_library})")
      end

      # Change libraries
      def change_libraries(libraries)
        libraries = libraries.nil? || libraries.size < 1 ? '*NONE' :libraries.join(' ')
        execute_system_command("CHGLIBL LIBL(#{libraries})")
      end

      # Returns true if current library is configured
      def current_library?
        !current_library.nil?
      end

      # Returns the name current library
      def current_library
        @current_library
      end

    end
  end
end
