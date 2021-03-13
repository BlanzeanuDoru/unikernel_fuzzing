# Unikernel fuzzing
This repo contains the work done towards a generic solution for unikernel fuzzing. 

## Running examples
### app-helloworld-gcov and app-helloworld-go
- https://github.com/cs-pub-ro/
```
# Run the setup script that clones all repos and applies patches
./setup.sh
```
- change directory to `gcov_examples` and run the examples


## Coverage solution
### Gcov
#### includeos
- checkout repo: `git clone https://github.com/includeos/IncludeOS.git"
- install conan `pip3 install conan`
- get conan config `conan config install https://github.com/includeos/conan_config.git`
```
git clone https://github.com/includeos/hello_world.git
mkdir your_build_dir && cd "$_"
conan install ../hello_world -pr <your_conan_profile>
source activate.sh
cmake ../hello_world
cmake --build .
boot hello
```
It turns out that `includeos` is no longer maintained and people have difficulties compiling the simplest example apps.
https://github.com/includeos/IncludeOS/issues/2211
https://twitter.com/perbu/status/1215931242593554434?s=19

#### osv
- clone osv `git clone https://github.com/cloudius-systems/osv.git`
- apply patch for `osv_patch_for_gcov.patch`:
	- modifies `scripts/setup.py` to work for Debian10
	- modifies `Makefile` to add gcov compile/link options
- run setup script `./scripts/setup.py`
- run build scripts `./scripts/build`
- managed to insert the gcov compile time flags, however at link time there are gcov symbols unresolved
- it seems that the libs are not correctly provided

#### mirageos
- Uses Ocaml language on which we cannot use the gcov solution
- Nevertheless it is a very well maintained, documented repo
- bisect_ppx - tool for code coverage
             - needs investigated https://github.com/aantron/bisect_ppx

#### hermitux
- needs CMake >= 3.7
- Prerequisites
	- Ubuntu/Debian packages
```
sudo apt update
sudo apt install git build-essential cmake nasm apt-transport-https wget \
	libgmp-dev bsdmainutils libseccomp-dev python libelf-dev
```
	- HermitCore toolchain installed in `/opt/hermit/`
```
echo "deb [trusted=yes] https://dl.bintray.com/hermitcore/ubuntu bionic main" \
	| sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt install binutils-hermit newlib-hermit pte-hermit gcc-hermit \
	libomp-hermit libhermit
```
- Compile
```
make
```

#### rumprun

