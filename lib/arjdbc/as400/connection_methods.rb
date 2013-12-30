ArJdbc::ConnectionMethods.module_eval do
  # @note Assumes AS400 driver (*jt400.jar*) is on class-path.
  def as400_connection(config)
    begin
      require 'jdbc/as400'
      ::Jdbc::AS400.load_driver(:require) if defined?(::Jdbc::AS400.load_driver)
    rescue LoadError # assuming driver.jar is on the class-path
    end
    
    config[:url] ||= begin
      # jdbc:as400://[host]
      url = 'jdbc:as400://'
      url << config[:host] if config[:host]
      # jdbc:as400://myiSeries;database name=IASP1
      url << ";database name=#{config[:database]}" if config[:database]
      # jdbc:as400://[host];proxy server=HODServerName:proxyServerPort
      url << ";proxy server=#{config[:proxy]}" if config[:proxy]
      url
    end
    require 'arjdbc/as400/adapter'
    config[:driver] ||= ::ArJdbc::AS400::DRIVER_NAME
    config[:adapter_spec] ||= ::ArJdbc::AS400
    config[:connection_alive_sql] ||= 'SELECT 1 FROM sysibm.tables FETCH FIRST 1 ROWS ONLY'
    jdbc_connection(config)
  end
end