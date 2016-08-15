#!/usr/bin/ksh
# Usage:
# ./test_multiple_login.sh > test_multiple_login.out 2>&1
. oraprf IEB01P
echo "Unix user is currently: "$(whoami)
echo " "
#
#
count=1
max=10
echo " "
echo "Testing system user $max times"
while [[ $count -le $max ]]; do
/usr/bin/time ./system_login.sh
((count=count+1))
done
#
#
count=1
max=10
echo "Testing anand1 user $max times"
while [[ $count -le $max ]]; do
/usr/bin/time ./anand1_login.sh
((count=count+1))
done
#
#
count=1
max=100
echo "Testing anand1 user $max times"
while [[ $count -le $max ]]; do
/usr/bin/time ./anand1_login.sh
((count=count+1))
done
