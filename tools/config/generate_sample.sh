#!/usr/bin/env bash

# Generate sample configuration for your project.
#
# Aside from the command line flags, it also respects a config file which
# should be named oslo.config.generator.rc and be placed in the same directory.
#
# You can then export the following variables:
# GUTS_CONFIG_GENERATOR_EXTRA_MODULES: list of modules to interrogate for options.
# GUTS_CONFIG_GENERATOR_EXTRA_LIBRARIES: list of libraries to discover.
# GUTS_CONFIG_GENERATOR_EXCLUDED_FILES: list of files to remove from automatic listing.

BASEDIR=${BASEDIR:-`pwd`}

NOSAMPLE=0
if [ ! -z ${2} ] ; then
    if [ "${2}" == "--nosamplefile" ]; then
        NOSAMPLE=1
    fi
fi

print_error ()
{
    echo -en "\n\n##########################################################"
    echo -en "\nERROR: ${0} was not called from tox."
    echo -en "\n        Execute 'tox -e genconfig' for guts.conf.sample"
    echo -en "\n        generation."
    echo -en "\n##########################################################\n\n"
}

if [ -z ${1} ] ; then
    print_error
    exit 1
fi

if [ ${1} != "from_tox" ] ; then
    print_error
    exit 1
fi

if ! [ -d $BASEDIR ] ; then
    echo "${0##*/}: missing project base directory" >&2 ; exit 1
elif [[ $BASEDIR != /* ]] ; then
    BASEDIR=$(cd "$BASEDIR" && pwd)
fi

PACKAGENAME=${PACKAGENAME:-$(python setup.py --name)}
TARGETDIR=$BASEDIR/$PACKAGENAME
if ! [ -d $TARGETDIR ] ; then
    echo "${0##*/}: invalid project package name" >&2 ; exit 1
fi

BASEDIRESC=`echo $BASEDIR | sed -e 's/\//\\\\\//g'`
find $TARGETDIR -type f -name "*.pyc" -delete

export TARGETDIR=$TARGETDIR
export BASEDIRESC=$BASEDIRESC

if [ -e $TARGETDIR/opts.py ] ; then
    mv $TARGETDIR/opts.py $TARGETDIR/opts.py.bak
fi

python guts/config/generate_guts_opts.py

if [ $? -ne 0 ] ; then
    echo -en "\n\n#################################################"
    echo -en "\nERROR: Non-zero exit from generate_guts_opts.py."
    echo -en "\n       See output above for details.\n"
    echo -en "#################################################\n"
    if [ -e $TARGETDIR/opts.py.bak ] ; then
        mv $TARGETDIR/opts.py.bak $TARGETDIR/opts.py
    fi
    exit 1
fi

if [ $NOSAMPLE -eq 0 ] ; then
    oslo-config-generator --config-file=guts/config/guts-config-generator.conf

    diff $TARGETDIR/opts.py $TARGETDIR/opts.py.bak &> /dev/null
    if [ $? -ne 0 ] ; then
        mv $TARGETDIR/opts.py.bak $TARGETDIR/opts.py
    else
       rm -f $TARGETDIR/opts.py.bak
    fi

    if [ $? -ne 0 ] ; then
        echo -en "\n\n#################################################"
        echo -en "\nERROR: Non-zero exit from oslo-config-generator."
        echo -en "\n       See output above for details.\n"
        echo -en "#################################################\n"
        exit 1
    fi
    if [ ! -s ./etc/guts/guts.conf.sample ] ; then
        echo -en "\n\n#########################################################"
        echo -en "\nERROR: etc/guts/guts.sample.conf not created properly."
        echo -en "\n        See above output for details.\n"
        echo -en "###########################################################\n"
        exit 1
    fi
else
    rm -f $TARGETDIR/opts.py.bak
fi
