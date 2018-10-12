
The test data
=============

This dir holds six examples of katas used as data for storer tests.
They are tar-piped into the storer container.
They are used to test methods which rely on
  o) handling of old style avatar .git dirs
  o) using starter.old_manifest(language) to convert from the
     old-style manifest.json format to the new-style manifest.json
     format. See below.


There are four katas with the old-style .git dirs:
---------------------------------------------------------------
id           avatar       lights     language         renaming?
---------------------------------------------------------------
5A/0F824303  spider       8          Python-behave    no
42/0BD5D5BE  hummingbird  0          Python-py.test   no
42/1AFD7EC5  wolf         1          Ruby-Rspec       yes Ruby-RSpec
42/1F303E80  buffalo      36         C                yes 'C (gcc)-assert'

There are two katas with the new style (no .git dirs)
---------------------------------------------------------------
id           avatar       lights     language         renaming?
---------------------------------------------------------------
42/0B05BA0A  dolphin      20         Java-JUnit       no
42/0F2A2979  snake        0          PHP-PHPUnit      no

There is one defect-driven kata (it has a custom display-name)
---------------------------------------------------------------
id           avatar       lights     language         renaming?
---------------------------------------------------------------
1F/00C1BFC8  turtle       2          Ruby-Cucumber    no

