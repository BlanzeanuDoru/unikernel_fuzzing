#!/bin/bash

### GCOV examples

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

# Clone kraft
cd ../ && git clone https://github.com/unikraft/kraft

# To run:
# /usr/local/bin/qemu-guest -k build/app-helloworld-gcov_kvm-x86_64 -e fs0
echo "To run: /usr/local/bin/qemu-guest -k build/app-helloworld-gcov_kvm-x86_64 -e fs0"

