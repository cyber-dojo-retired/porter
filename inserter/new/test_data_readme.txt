
These IDs include some which have an l (ell) in them.

Extracted from the live storer using...

docker exec cyber-dojo-storer tar -c -f - -C /usr/src/cyber-dojo/katas 9f
   | tar -x -f - -C .

which created...

9f/8TeZMZAq/...
9f/67Q9PyZm/...
etc

Then create tgz files for each of these dirs...

tar -czvf 9f8TeZMZAq.tgz 9f/8TeZMZAq
tar -czvf 9f67Q9PyZm.tgz 9f/67Q9PyZm
etc


9fH6TumFV2 is a large kata:
 48 antelope
 62 beetle
 26 buffalo
 69 hyena
104 ostrich
 80 squid
