
[![Build Status](https://travis-ci.org/cyber-dojo/porter.svg?branch=master)](https://travis-ci.org/cyber-dojo/porter)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/porter docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Ports old practice sessions from
[storer](https://github.com/cyber-dojo/storer)
to
[saver](https://github.com/cyber-dojo/saver).
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha()](#get-sha)
- [POST port(id)](#post-portid)

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

## POST port(id)
Ports an old-format practice-session with the given id from storer to saver.
- parameter, the 10-digit id of the practice session (in storer), eg
```
    { "id": "55D3B97E1E" }
```
- returns, the 6-digit id of the practice session in saver.
- if possible the 6-digit id will be the 1st 6 chars of the 10-digit id.
- if not possible, the id10->id6 mapping will be recorded in /porter/mapped-ids/
```
  { "port": "55D3B9" }
  { "port": "79s7Bk" }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
