# Tests

Right now we have Travis configured to do some basic testing:

- It runs the installation for the following OSes:
  - MacOS El Capitan (XCode 8)
  - MacOS Sierra (XCode 8.3.3)
  - Ubuntu 16.04 (via Docker)
- And afterwards it does some smoke testing to see if installation did what's expected of it.

See [.travis.yml](../.travis.yml) and the other files in this folder for details.

It's a very basic testing and we could definetely use some help to improve it ;-)

**IDEA:**

- Maybe we could add a step with https://github.com/koalaman/shellcheck ?
