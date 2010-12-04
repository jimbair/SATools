#!/bin/bash
# Script to print the # of minutes until filesystem fills up
# Based on the following one-liner:
# echo "`df / | tail -n1 | awk '{print $4}'` / (`df / | tail -n1 | awk '{print $4}' ; sleep 60` - `df /| tail -n1 | awk '{print $4}'`)" | bc

# How many seconds to sleep between df pools
sleepTime='60'

# If given a single arg, use that as our mount point
if [ "$#" -eq '1' ]; then
    ourMount="${1}"
elif [ "$#" -eq '0' ]; then
    ourMount='/'
else
    echo "Usage: $(basename $0) [OPTION]" >&2
    echo "" >&2
    echo "Options:" >&2
    echo "Mount point ('/' used by default if none given)" >&2
    exit 1
fi


# Used to poll df for available blocks
mountAvailable() {

    df ${ourMount} | tail -n1 | awk '{print $4}'

}

########
# MAIN #
########

echo -n "Getting first number of available blocks for ${ourMount}..."
firstMount="$(mountAvailable)"
if [ -z "${firstMount}" ]; then
    echo 'failed.' >&2
    exit 1
fi
echo 'done.'

echo "Sleeping for ${sleepTime} seconds."
sleep ${sleepTime}

echo -n "Getting second number of available blocks for ${ourMount}..."
secondMount="$(mountAvailable)"
if [ -z "${secondMount}" ]; then
    echo 'failed.' >&2
    exit 1
fi
echo 'done.'

# Build string
string="${firstMount} / ( ${firstMount} - ${secondMount} )"

# Make sure we have work to do
if [ "${firstMount}" -lt "${secondMount}" ]; then
    echo "The number of blocks available went up, not down."
    echo "Something is freeing up space on ${ourMount}"
    exit 1
elif [ "${firstMount}" -eq "${secondMount}" ]; then
    echo "The number of available blocks has not moved."
    echo "The free space on ${ourMount} is stagnant."
    exit 1
fi

result="$(echo "${string}" | bc)"
resultType='minutes'

# Move up to hours
if [ "${result}" -gt '60' ]; then
    lastNum="${result}"
    lastType="${resultType}"
    result="$((result/60))"
    resultType='hours'
fi

# Move up to days
if [ "${result}" -gt '24' ]; then
    lastNum="${result}"
    lastType="${resultType}"
    result="$((result/24))"
    resultType='days'
fi

# Print our summary
echo -n "Our mount point ${ourMount} will fill up in ${result} ${resultType} "
echo "(${lastNum} ${lastType})"
exit 0
