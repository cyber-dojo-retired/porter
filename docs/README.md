
[![CircleCI](https://circleci.com/gh/cyber-dojo/porter.svg?style=svg)](https://circleci.com/gh/cyber-dojo/porter)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/porter docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Ports old practice sessions from
[storer](https://github.com/cyber-dojo/storer)
to
[saver](https://github.com/cyber-dojo/saver).

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET ready()](#get-ready)
- [GET sha()](#get-sha)
- [GET ported?(id6)](#get-portedid6)
- [GET ported_id(partial_id)](#get-portedidpartialid)

- - - -

## GET ready()
- parameters, none
```
  {}
```
- returns true if the service is ready, otherwise false.
```
  { "ready": "true" }
```

- - - -

## GET sha()
Returns the git commit sha used to create the cyberdojo/porter docker image.
- parameters, none
```
  {}
```
- returns the sha, eg
```
  { "sha": "8210a96a964d462aa396464814d9e82cad99badd" }
```

- - - -

## GET ported?(id6)
Asks if id6 matches the first 6 digits of any already ported storer
session's 10-digit id.
- parameter, a 6-digit id, eg
```
    { "id6": "55D3B9" }
```
- returns, true if it does, false if it doesn't.
```
  { "ported": true }
  { "ported": false }
```

- - - -

## GET ported_id(partial_id)
Asks for the 6-digit saver id (if it exists) of the already ported storer
session whose 10-digit id uniquely completes the given 6-10 digit partial_id.
- parameter, a 6-10 digit storer session id, eg
```
    { "partial_id": "55D3B9" }
    { "partial_id": "55D3B97" }
    { "partial_id": "55D3B97E" }    
```
- returns the 6-digit saver id if it exists, otherwise the empty string.
```
    { "ported_id": "55D3B9" }
    { "ported_id": "E5pL3S" }
    { "ported_id": "" }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
