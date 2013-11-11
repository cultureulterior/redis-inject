#include <stdio.h>
#include "redis.h"
void inject_init(void) __attribute__((constructor));
void inject_init(void)
{
  struct redisServer *murder_server = (void *) ADDRESS ;
  printf("Injected\n");
  printf("Injected into Redis: Address: %x\n", murder_server);
  printf("Injected into Redis: Port: %i\n", (*murder_server).port);
  dictIterator *di;
  dictEntry *de;
  unsigned long numchans = 0;

  di = dictGetIterator((*murder_server).pubsub_channels);
  while((de = dictNext(di)) != NULL) {
    numchans++;
  }
  printf("Channels: %li\n", numchans);
  dictReleaseIterator(di);
}
