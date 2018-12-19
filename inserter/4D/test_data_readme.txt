
A lot of katas, mostly to soak test the porter service.

Extracted from the live storer using...

docker exec cyber-dojo-storer tar -c -f - -C /usr/src/cyber-dojo/katas 4D
   | tar -x -f - -C .

which created a lot of 4D/... folders which were then all zipped up

tar -zcf 4D.tgz 4D
