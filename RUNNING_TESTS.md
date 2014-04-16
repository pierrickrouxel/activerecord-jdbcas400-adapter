## Running activerecord-jdbcas400-adapter's tests

Running test requires configuration. You should specify your credentials and schemas in your environment variables.

```
export AS400_HOST=host
export AS400_USERNAME=user
export AS400_PASSWORD=password
export AS400_SCHEMA=ARJDBC_TEST
export AS400_LIBRARIES=QTEMP,ARJDBC_TEST
```

All tests can run out of rails. You can just write in console 'jruby test_file.rb'.