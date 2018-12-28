
A lot of katas, mostly to soak test the porter service.

Extracted from the snapshot-2 on GCE using...

docker run --detach -it --name temp --volumes-from cyber-dojo-katas-DATA-CONTAINER alpine sh
docker exec temp tar -c -f - -C /usr/src/cyber-dojo/katas 02 | tar -x -f - -C .

which created a lot of 02/... folders which were then all pushed to a git repo
