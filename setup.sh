#!/bin/bash

### GCOV examples
gcov_example() {
	GCOV_EXAMPLE_DIR=gcov_examples

	# Github Organizations
	UPB_ORG=https://github.com/cs-pub-ro/
	UNIKRAFT_ORG=https://github.com/unikraft/

	LIBS_DIR=libs

	# UPB repos checked out
	APP1=app-helloworld-gcov
	APP2=app-helloworld-go
	UNIKRAFT=unikraft
	LIB_GCC=lib-gcc

	# Unikraft repos checked out
	LIBS="lib-pthread-embedded lib-libunwind lib-compiler-rt lib-libcxxabi lib-libcxx lib-newlib"

	# create libs dir
	mkdir -p ${GCOV_EXAMPLE_DIR}/${LIBS_DIR}

	# change directory
	cd ${GCOV_EXAMPLE_DIR}

	git clone ${UPB_ORG}/${UNIKRAFT}
	git clone ${UPB_ORG}/${APP1}
	git clone ${UPB_ORG}/${APP2}

	cd ${LIBS_DIR}
	git clone ${UPB_ORG}/${LIB_GCC}

	for lib in ${LIBS}; do
    	git clone ${UNIKRAFT_ORG}/${lib}
	done

	# get gcov branch
	cd lib-gcc && git checkout gcov
	cd ../../unikraft && git checkout gcov

	# Apply patch to change paths in makefile
	cd ../app-helloworld-gcov && patch -p1 < ../../patches/app_helloworld_gcov.patch

	# Rebase unikraft repo to official one
	cd ../unikraft
	git remote add official https://github.com/unikraft/unikraft
	git fetch official
	git rebase official/staging

	# Run `make menuconfig` and select uksignal and save the configuration
	cd ../app-helloworld-gcov && make && make

	# To run:
	# /usr/local/bin/qemu-guest -k build/app-helloworld-gcov_kvm-x86_64 -e fs0
	echo "To run: /usr/local/bin/qemu-guest -k build/app-helloworld-gcov_kvm-x86_64 -e fs0"
}

# For MirageOS `opam` is needed
# opam init
# opam install mirage

# Include OS

# OSV
osv_investigation() {
	# clone repository
	git clone https://github.com/cloudius-systems/osv

	# change dir to OSV
	cd osv

	# build docker
	cd docker && docker build -t osv/builder -f Dockerfile.builder .

	# update git submodules
	git submodule update --init --recursive

	# apply patch
	patch -p1 < ../../patches/osv_patch_for_gcov.patch
	# ./scripts/setup.py     #this installs prerequisites(not needed on this machine)
	./scripts/build
}

# Hermitux
hermitux_investigation() {
	# get docker container with Hermitux
	docker pull olivierpierre/hermitux

	# run container
	docker run --privileged -it olivierpierre/hermitux
}

main() {
	if [ "$#" -ne 1 ] || ( [[ "$1" != "examples" ]] && [[ "$1" != "osv" ]] && [[ "$1" != "hermitux" ]] ); then
		echo "Usage: $0 <examples|osv|hermitux>" >&2
		exit 1
	fi
	if [[ "$1" == "examples" ]]; then
		gcov_examples
	fi
	if [[ "$1" == "osv" ]]; then
		osv_investigation
	fi
	if [[ "$1" == "hermitux" ]]; then
		hermitux_investigation
	fi
}

main $@

