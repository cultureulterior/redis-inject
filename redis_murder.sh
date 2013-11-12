export DATE=$(date "+%s")
git clone git@github.com:antirez/redis.git
pushd redis
git checkout $(redis-server -v | cut -f 4 -d " " )
popd
echo "Getting Address"
export ADDRESS=$( printf "p &server \n detach" | gdb -q --batch --pid=`pgrep -f redis-server` 2>&1 | tee -a redis_murder.log | grep -F "data variable" | cut -f 2 -d ')' | tr -d ' ' )
echo "Address: '$ADDRESS'"
if [[ $(uname) -eq  "Darwin" ]]
   then
   ## Using options from https://github.com/scummvm/scummvm/blob/master/configure
   gcc -Wall -DADDRESS=$ADDRESS -I$PWD/redis/src -bundle -bundle_loader $(which redis-server) -o redis_murder_$DATE redis_murder.c
else
   gcc -Wall -DADDRESS=$ADDRESS -I$PWD/redis/src -Wl,--just-symbols,$(which redis-server) -c redis_murder.c -o redis_murder_$DATE
fi
echo "Injecting Code"
printf "p (void *) dlopen(\"$PWD/redis_murder_$DATE\",2) \n detach" | gdb -q --batch --command=redis_murder.gdb_tmp --pid=`pgrep -f redis-server` 2>&1 >> redis_murder.log
echo $DATE
redis-server -v
