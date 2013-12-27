module ::ArJdbc
  extension :AS400 do |name, config|
    # The native JDBC driver always returns "DB2 UDB for AS/400"
    if name =~ /as\/?400/i
      require 'arjdbc/as400'
      true
    end
  end
end