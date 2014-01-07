# activerecord-jdbcas400-adapter

https://github.com/pierrickrouxel/activerecord-jdbcas400-adapter/

## Description

This is an ActiveRecord driver for AS/400 using JDBC running under JRuby.

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

## Compatibility

Actually activerecord-jdbcas400-adapter is only compatible with IBM i V6R1 and later versions.
It requires JDBC 4.0 driver and Java 6.

## Dependency

You can embed the JTOpen driver in your application. It is distributed in a separate gem : 'as400-jdbc'

## Licence

This software is under GPL-3.0 licence.