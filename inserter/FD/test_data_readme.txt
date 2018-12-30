
A lot of katas, mostly to soak test the porter service.

Extracted from the live storer using...

docker exec cyber-dojo-storer tar -c -f - -C /usr/src/cyber-dojo/katas FD
   | tar -x -f - -C .

which created a lot of FD/... folders which were then all zipped up

tar -zcf FD.tgz FD

Something in this data-set crashes the porter script...
