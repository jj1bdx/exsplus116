# exsplus116: xorshift116plus PRNG for Erlang

xorshift116plus is a 58-bit PRNG of (2^116-1) period.

See [emprng](https://github.com/jj1bdx/emprng/) for the further details.

## LICENSE

MIT License.

(The code under `c-example` directory is licensed CC0/public domain.)

# Tested platforms

* FreeBSD/amd64 10.1-STABLE with Erlang/OTP 17.5.2 and HiPE
* OS X x86\_64 10.10.3 with Erlang/OTP 17.5.2 and HiPE
* HiPE is not a requirement but recommended to be enabled.
* This code will run on 18.0.

A preliminary test shows the `exsplus116` functions takes *nearly the same*
execution time than twice of `random` module on a x86\_64 or amd64 architecture
environment.

## Make options (of erlang.mk)

* `Makefile` works on both BSD/GNU make
* `Makefile.[module_name]` is the real GNU make file; edit this file for modification
* Building: `make`
* Documentation: `make docs`
* Testing: `make tests`
* Execution speed benchmark: `make speed`
* See also [erlang.mk](https://github.com/extend/erlang.mk) for the details

## TODO

* More seeding algorithms
* More evaluation and refactoring

## Authors

Algorithm by Sebastiano Vigna.

Programmed by Kenji Rikitake and Dan Gudmundsson.
