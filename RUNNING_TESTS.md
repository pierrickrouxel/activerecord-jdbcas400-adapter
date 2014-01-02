## Running activerecord-jdbcas400-adapter's tests

Running test requires configuration. You should specify your credentials and schemas in /test/config.yml.

```yml
host: 'ip/hostname'
username: 'user'
password: 'password'
schema: 'An empty schema for tests'
libraries: 'A library list for system naming tests'
```

All tests can run out of rails. You can just write in console 'jruby test_file.rb'.