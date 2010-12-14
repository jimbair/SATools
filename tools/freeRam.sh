#!/bin/bash
# Script to calculate free memory on the system 
# Takes all - (free + cached) for our result.
# Still need to validate.

total="$(free -m | grep 'Mem:' | awk '{print $2}')"
free="$(free -m | grep 'Mem:' | awk '{print $4}')"
cached="$(free -m | grep 'buffers/cache' | awk '{print $NF}')"
free="$((${free}+${cached}))"
diff="$((${total}-${free}))"
result="$(echo "scale=2; ${diff}/${total}" | bc | cut -d '.' -f 2- | tr -d '\n'; echo %)"

echo "Total: ${total}MB"
echo "Free: ${free}MB"
echo "Percentage used: ${result}"

exit 0
