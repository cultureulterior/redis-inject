#!/bin/bash
if [[ -z $(pgrep -f redis-server) ]]
then
    echo "### No redis server"
    exit -1
fi

export DATE=$(date "+%s")
export VERSION=$(redis-server -v | cut -f 4 -d " " )

echo "### Retrieving redis '${VERSION}'"
git clone git@github.com:antirez/redis.git
pushd redis
git checkout $VERSION
popd

echo "### Getting Address"
export ADDRESS=$( printf "p &server \n detach" | gdb -q --pid=`pgrep -f redis-server` 2>&1 | tee -a redis_murder.log | grep -F "data variable" | cut -f 3 -d ')' | tr -d ' ' )
echo "*Address: '$ADDRESS'"

echo "### Compiling Injection 'redis_murder_$DATE'"
if [[ $(uname) -eq  "Darwin" ]]
   then
   ## Using options from https://github.com/scummvm/scummvm/blob/master/configure
   gcc -Wall -DADDRESS=$ADDRESS -I$PWD/redis/src -bundle -bundle_loader $(which redis-server) -o redis_murder_$DATE redis_murder.c
else
   gcc -Wall -DADDRESS=$ADDRESS -I$PWD/redis/src -Wl,--just-symbols,$(which redis-server) -c redis_murder.c -o redis_murder_$DATE
fi

echo "### Injecting Code"
printf "p (void *) dlopen(\"$PWD/redis_murder_$DATE\",2) \n detach" | gdb -q --pid=`pgrep -f redis-server` 2>&1 | tee -a redis_murder.log > /dev/null
