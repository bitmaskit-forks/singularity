#!/bin/bash
#
# Copyright (c) 2017, Michael W. Bauer. All rights reserved.
# Copyright (c) 2017, Gregory M. Kurtzer. All rights reserved.
#
# "Singularity" Copyright (c) 2016, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.
#
# This software is licensed under a customized 3-clause BSD license.  Please
# consult LICENSE file distributed with the sources of this project regarding
# your rights to use or distribute this software.
#
# NOTICE.  This Software was developed under funding from the U.S. Department of
# Energy and the U.S. Government consequently retains certain rights. As such,
# the U.S. Government has been granted for itself and others acting on its
# behalf a paid-up, nonexclusive, irrevocable, worldwide license in the Software
# to reproduce, distribute copies to the public, prepare derivative works, and
# perform publicly and display publicly, and to permit other to do so.
#
#

## TEMP - Will come from test.sh export ##
prefix="/usr/local"
exec_prefix="${prefix}"
libexecdir="${exec_prefix}/libexec"
sysconfdir="${prefix}/etc"
localstatedir="${prefix}/var"
bindir="${exec_prefix}/bin"

SINGULARITY_libexecdir="$libexecdir"
SINGULARITY_sysconfdir="$sysconfdir"
SINGULARITY_localstatedir="$localstatedir"
SINGULARITY_PATH="$bindir"
## TEMP ##


STARTDIR=`pwd`
TEMPDIR=`mktemp -d /tmp/singularity-test.XXXXXX`
CONTAINER="container.img"
CONTAINERDIR="container_dir"
SINGULARITY_MESSAGELEVEL=5
export SINGULARITY_MESSAGELEVEL

. ../libexec/functions

/bin/echo
/bin/echo "Running "
/bin/echo

/bin/echo "Creating temp working space at: $TEMPDIR"
stest 0 mkdir -p "$TEMPDIR"
stest 0 pushd "$TEMPDIR"


/bin/echo
/bin/echo "Building test container..."

stest 0 sudo singularity create -s 568 "$CONTAINER"
stest 0 sudo singularity bootstrap "$CONTAINER" "$STARTDIR/../examples/busybox.def"
echo -ne "#!/bin/sh\n\neval \"\$@\"\n" > singularity
stest 0 chmod 0644 singularity
stest 0 sudo singularity copy "$CONTAINER" -a singularity /


/bin/echo
/bin/echo "Checking NO_NEW_PRIVS"

stest 0 singularity create -F -s 568 "$CONTAINER"
stest 0 singularity import ${CONTAINER} docker://centos
stest 0 sudo singularity exec "$CONTAINER" ping localhost -c 1
stest 1 singularity exec "$CONTAINER" ping localhost -c 1
stest 0 sudo singularity exec $CONTAINERDIR ping localhost -c 1
stest 1 singularity exec $CONTAINERDIR ping localhost -c 1


/bin/echo
/bin/echo "Checking target UID mode"

stest 0 sh -c "sudo SINGULARITY_TARGET_GID=`id -g` SINGULARITY_TARGET_UID=`id -u` singularity exec $CONTAINER whoami | grep -q `id -un`"


stest 0 popd
stest 0 sudo rm -rf "$TEMPDIR"

/bin/echo
/bin/echo "06-importexport.sh tests OK"
/bin/echo