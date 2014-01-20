# activerecord-jdbcas400-adapter

https://github.com/pierrickrouxel/activerecord-jdbcas400-adapter/

## Description

This is an ActiveRecord driver for AS/400 using JDBC running under JRuby.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-jdbcas400-adapter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-jdbcas400-adapter

## Usage

Configure your database.yml in the normal Rails style:
```yml
development:
  adapter: as400
  database: development
  username: user
  password: 1234

  naming: sql

  # This is possible only if naming=system and schema isn't defined
  libraries: lib1,lib2,lib3
```

You cas also use JNDI in production mode:
```yml
production:
  adapter: jndi # jdbc
  jndi: jdbc/dataSource
```

If your DB isn't correctly discovered you can specify the dialect:
```yml
  dialect: as400
```

## Experimental feature

To allow migrations with system naming, a configuration is added to adapter:

```yml
  current_library: lib
```

The specified library will be used to define a schema during create_table migration.
It prevents creation of a table in QGPL.

If you want to use it with JNDI you can create a JNDI string and use erb in yaml to do something like this:

```yml
<%
require 'java'
current_library = Java::JavaxNaming::InitialContext.new.lookup('java:comp/env/currentLibrary').to_s if Rails.env.production?
%>

production:
  adapter: as400
  jndi: jdbc/dataSource
  current_library: <%=current_library%>
```

## Connection pool
Websphere Application Server for i provides data sources with connection pool.
Rails has it's own connection pool management. To make them compatible you should define:

  * Connection timeout: 0
  * Maximum connections: 5 (default) or same as rails configuration
  * Minimum connections: 0 to Maximum connections
  * Reap time: 0
  * Unused timeout: 0
  * Aged timeout: 0

## Compatibility

Actually activerecord-jdbcas400-adapter is only compatible with IBM i V6R1 and later versions.
It requires JDBC 4.0 driver and Java 6.

## Dependency

You can embed the JTOpen driver in your application. It is distributed in a separate gem : 'as400-jdbc'

## Licence

This software is under GPL-3.0 licence.