#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

diablo_selfprofiling() {
  echo "Building Diablo-Selfprofiling..."

  mkdir -p /opt/diablo/obj/
  cd /opt/framework/diablo/self-profiling
  ./generate.sh /opt/diablo-gcc-toolchain/bin/arm-diablo-linux-gnueabi-cc printarm_linux.o arm
  make
  cp printarm_linux.o /opt/diablo/obj/
  ./generate.sh /opt/diablo-android-gcc-toolchain/bin/arm-linux-androideabi-gcc printarm_android.o arm
  make
  cp printarm_android.o /opt/diablo/obj/
}

# Set up the symlinks for the modules that don't require anything special.
setup_symlinks() {
  echo "Setting up symlinks..."
  ln -s /opt/framework/actc/src/ /opt/ACTC
  ln -s /opt/framework/annotation_extractor /opt/annotation_extractor
  ln -s /opt/framework/code-guards /opt/codeguard
}

communications() {
  echo "Building Communications libraries..."

  echo "  Building ACCL..."
  /opt/framework/accl/build.sh /opt/ACCL

  echo "  Building ASCL..."
  /opt/framework/ascl/build.sh /opt/ASCL
}

anti_debugging() {
  echo "Building anti_debugging..."
  /opt/framework/anti_debugging/build.sh /opt/anti_debugging
}

codemobility() {
  echo "Building code mobility..."
  /opt/framework/code-mobility/build.sh /opt/code_mobility
}

renewability() {
  echo "Building renewability..."

  /etc/init.d/mysql restart || true
  /opt/framework/renewability/build.sh /opt/renewability
  /opt/renewability/setup/database_setup.sh
}

RA() {
  echo "Building remote attestation..."

  /etc/init.d/mysql restart || true
  /opt/framework/remote-attestation/build.sh /opt/RA
  /opt/RA/setup/database_setup.sh
}

setup_symlinks

[ -d /opt/framework/anti_debugging ] && anti_debugging
diablo_selfprofiling
communications
codemobility
renewability
RA
