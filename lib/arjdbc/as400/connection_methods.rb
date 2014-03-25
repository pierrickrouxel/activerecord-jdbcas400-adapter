ArJdbc::ConnectionMethods.module_eval do
  # @note Assumes AS400 driver (*jt400.jar*) is on class-path.
  def as400_connection(config)
    
    unless config[:native]
      begin
        require 'jdbc/as400'
        ::Jdbc::AS400.load_driver(:require) if defined?(::Jdbc::AS400.load_driver)
      rescue LoadError # assuming driver.jar is on the class-path
      end

      config[:transaction_isolation] ||= 'none'
    end
    
    config[:url] ||= begin
      url = 'jdbc:'
      if config[:native]
        # jdbc:db2:*local;naming=[naming];libraries=[libraries]
        url << 'db2:*local'
      else
        # jdbc:as400://[host];proxy server=[proxy:port];naming=[naming];libraries=[libraries];prompt=false
        url << 'as400://'
        url << config[:host] if config[:host]
        url << ";database name=#{config[:database]}" if config[:database]
        url << ";proxy server=#{config[:proxy]}" if config[:proxy]
        url << ';prompt=false'
      end
      url << ";naming=#{config[:naming]}" if config[:naming]
      url << ";libraries=#{config[:libraries]}" if config[:libraries]
      url << ";auto commit=#{config[:auto_commit]}" if config[:auto_commit]
      url << ";transaction isolation=#{config[:transaction_isolation]}" if config[:transaction_isolation]
      url
    end
    require 'arjdbc/as400/adapter'
    config[:driver] ||= if defined?(::Jdbc::AS400.driver_name)
      ::Jdbc::AS400.driver_name
    elsif config[:native]
      ::ArJdbc::AS400::NATIVE_DRIVER_NAME
    else
      ::ArJdbc::AS400::DRIVER_NAME
    end
    config[:adapter_spec] ||= ::ArJdbc::AS400
    config[:connection_alive_sql] ||= 'SELECT 1 FROM sysibm.tables FETCH FIRST 1 ROWS ONLY'
    jdbc_connection(config)
  end
end