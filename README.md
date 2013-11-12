redis-inject
============

Inject C code and access redisServer object from running redis instance via GDB

# How does this work?

We retrieve the address of the main object symbol from redis via gdb. 
We then compile a binary which refers to symbols, but is not linked to, the original redis-server binary.
We then connect to the running binary via gdb again, and dlopen() the binary, 
which contains a constructor-tagged (using  `__attribute__((constructor))` ) function, and is so called immediately

# Why?

We needed access to 

Run as `bash redis_murder.sh`

Example run
```
$ bash redis_murder.sh
### Retrieving redis '2.4.16'
fatal: destination path 'redis' already exists and is not an empty directory.
~/redis_inject/redis ~/redis_inject
HEAD is now at 2a18c2c... Redis 2.4.16
~/redis_inject
### Getting Address
*Address: '0x106b2fdd8'
### Compiling Injection 'redis_murder_1384255605'
### Injecting Code
```

From redis
```
[12514] 12 Nov 11:26:44 - 0 clients connected (0 slaves), 922368 bytes in use
Injection successful!
Injected into Redis: Address: 106b2fdd8
Injected into Redis: Port: 6379
Injected into Redis: Channels: 0
[12514] 12 Nov 11:26:49 - 0 clients connected (0 slaves), 922368 bytes in use
```

