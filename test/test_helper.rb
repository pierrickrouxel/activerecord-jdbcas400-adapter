require 'java'

begin
  require 'bundler'
rescue LoadError => e
  require('rubygems') && retry
  raise e
end
Bundler.require(:default, :test)

class Test::Unit::TestCase
  def config
    @config ||= YAML::load(File.open('config.yml'))
    @config.symbolize_keys
  end

  def data_source_connection
    return @connection if @connection && @connection_type == 'data_source'
    # Create a data source to the iSeries database.
    datasource = com.ibm.as400.access.AS400JDBCDataSource.new
    datasource.setServerName(config[:host])
    datasource.setLibraries(config[:libraries])
    datasource.setUser(config[:username])
    datasource.setPassword(config[:password])

    ActiveRecord::Base.establish_connection(adapter: 'as400', data_source: datasource)
    @connection_type = 'data_source'
    @connection = ActiveRecord::Base.connection
  end

  def connection
    return @connection if @connection && @connection_type == 'connection'
    ActiveRecord::Base.establish_connection(
        adapter: 'as400',
        host: config[:host],
        username: config[:username],
        password: config[:password],
        schema: config[:schema]
    )
    @connection_type = 'connection'
    @connection = ActiveRecord::Base.connection
  end

  def system_connection
    return @connection if @connection && @connection_type == 'system'
    ActiveRecord::Base.establish_connection(
        adapter: 'as400',
        host: config[:host],
        username: config[:username],
        password: config[:password],
        naming: 'system',
        libraries: config[:libraries]
    )
    @connection_type = 'system'
    @connection = ActiveRecord::Base.connection
  end
end