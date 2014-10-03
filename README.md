# activerecord-jdbcas400-adapter

[![Gem Version](http://img.shields.io/gem/v/activerecord-jdbcas400-adapter.svg)][gem]
[![Dependency Status](http://img.shields.io/gemnasium/pierrickrouxel/activerecord-jdbcas400-adapter.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/pierrickrouxel/activerecord-jdbcas400-adapter.svg)][codeclimate]

[gem]: https://rubygems.org/gems/activerecord-jdbcas400-adapter
[gemnasium]: https://gemnasium.com/pierrickrouxel/activerecord-jdbcas400-adapter
[codeclimate]: https://codeclimate.com/github/pierrickrouxel/activerecord-jdbcas400-adapter


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

To use native DB2 connection (directly on IBM i JVM only), you can add this to database.yml:
```yml
  native: true
```
This connection doesn't require credentials.

### Transaction isolation : no commit
If your database supports setting the isolation level for a transaction, you can set it like so:

```ruby
Post.transaction(isolation: :no_commit) do
  #...
end
```

Valid isolation levels are:
```
  :read_uncommitted
  :read_committed
  :repeatable_read
  :serializable
  :no_commit
```

## Experimental features
### Current library
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

## Compatibility

Actually activerecord-jdbcas400-adapter is only compatible with IBM i V6R1 and later versions.
It requires JDBC 4.0 driver and Java 6.

## Dependency

You can embed the JTOpen driver in your application. It is distributed in a separate gem : 'as400-jdbc'
