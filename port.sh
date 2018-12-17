#!/bin/bash

# checker docker installed

# check data-container exists
# check storer service is NOT already up
# docker pull cyberdojo/storer (to get eg kata_delete)
# bring up storer service

# docker pull cyberdojo/saver
# make sure /cyber-dojo dir exists
# bring up saver service and volume-mount /cyber-dojo dir
# check saver-uid has write access to /cyber-dojo (with docker exec)
#    (if on DockerToolbox with will be on default VM)

# docker pull cyberdojo/porter
# make sure /id-map exists (??? OR PUT JSON FILES IN /tmp ???)
# bring up porter container - needs to link to storer and saver
# check porter-uid has write access to /id-map (with docker exec)
#    (if on DockerToolbox with will be on default VM)
# docker exec -it porter-container sh -c 'ruby /app/port.rb ${*}'

# always remove porter container
# always remove saver container
