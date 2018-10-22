
[![Build Status](https://travis-ci.org/cyber-dojo/porter.svg?branch=master)](https://travis-ci.org/cyber-dojo/porter)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/porter docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Ports old practice sessions from storer to saver.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha()](#get-sha)
- [POST port(partial_id)](#post-portpartial_id)

- - - -

## GET sha()
Returns the git commit sha used to create the docker image.
- parameters, none
```
  {}
```
- returns the sha, eg
```
  { "sha": "8210a96a964d462aa396464814d9e82cad99badd" }
```

- - - -

## POST port(partial_id)
Ports an old-format practice-session with the given partial_id from storer into saver.
- parameter, eg
```
    { "partial_id": "55D3B9" }
    { "partial_id": "0BA7E1" }
    { "partial_id": "0BA7E1E" }
```
- partial_id must be 6..10 chars long.
- if partial_id uniquely identifies a practice-session in storer, porter will
port the practice-session to saver, and return the new id, which will be 6 chars long.
The new id will be the 1st 6 chars of the partial_id if they are unique in storer.
- if partial_id does not uniquely identify a practice-session in storer
(either because there is no match, or there is more than one match), porter
will not port anything, and will return the empty string.
- returns, eg
```
  { "port": "55D3B9" }
  { "port": "" }
  { "port": "79s7Bk" }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
