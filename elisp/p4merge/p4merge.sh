#!/bin/bash
#
# Copyright 1996 MYDATA automation AB; http://www.mydata.se
# Tom Bjorkholm tomb@mydata.se
#
# p4merge base their yours result
#
# Make sure we have TMPDIR
#
if [ -z "$TMPDIR" ]
then
  TMPDIR=/tmp
fi
#
# Define the space_merge function. 
# space_merge from_file to_file
#
function space_merge() {
  from_file=$1
  to_file=$2
  patch=$TMPDIR/p4_spc_m_p_$$.tmp
  diff_1=$TMPDIR/p4_spc_m_1_$$.tmp
  diff_2=$TMPDIR/p4_spc_m_2_$$.tmp
  diff_tmp=$TMPDIR/p4_spc_m_t_$$.tmp
  rm -f $diff_org $diff_1 $diff_2 $patch $diff_tmp
  diff -U 0 $to_file $from_file |  while read a 
  do
    if echo "$a" | egrep '^\-\-\- ' > /dev/null ; then echo "$a" > $patch; else
      if echo "$a"| egrep '^\+\+\+ ' > /dev/null ; then echo "$a" >> $patch; else
        if echo "$a" | egrep '^@@ ' > /dev/null ; then 
          if [ -f $diff_tmp ]
          then
            egrep '^\+' $diff_tmp | sed 's/^[+]//' | sed 's/ //g' > $diff_1
            egrep '^\-' $diff_tmp  | sed 's/^[-]//'| sed 's/ //g' > $diff_2
            if [ `diff -B -b $diff_1 $diff_2 | wc -l` = 0 ]
            then
               cat $diff_tmp >> $patch
            fi
            rm -f $diff_tmp $diff_1 $diff_2
          fi           
          echo "$a" > $diff_tmp
        else
          echo "$a" >> $diff_tmp
        fi
      fi
    fi
  done
  num=`cat $patch | egrep '^@@ ' | wc -l` 
  num=`expr $num`
  if [ `cat $patch | wc -l` -gt 2 ]
  then
    echo "Could fix $num space conflicts" 
    echo "          ($from_file - $to_file)"
    patch -s -p0 < $patch 
  else
    echo "Could not fix space conflicts ******** "
    echo "          ($from_file - $to_file) ($num)"
  fi
  rm -f $diff_1 $diff_2  $diff_tmp
}
#
# Fix temporary files that we can change
#
base=$TMPDIR/p4_base_$$.tmp
their=$TMPDIR/p4_their_$$.tmp
yours=$TMPDIR/p4_yours_$$.tmp
#
rm -f $base $their $yours
cp $1 $base
cp $2 $their
cp $3 $yours
#
# Check for (and eventually fix) space related conflicts
#
if [ `diff -U 0 $their $yours | wc -l` -gt `diff -b -B -U 0 $their $yours | wc -l` ]
then
  a='b'
  while [ "$a" != "y" -a "$a" != "n" -a "$a" != "Y" -a "$a" != "N" ]
  do
    echo -n "There are space related conflicts. Try to fix? [y/n] "
    read a
  done
  if [ "$a" = "y" -o "$a" = "Y" ]
  then
    space_merge $yours $base
    space_merge $yours $their
    if [ `diff -U 0 $their $yours | wc -l` -gt `diff -b -B -U 0 $their $yours | wc -l` ]
    then
      echo "There are still space related conflicts, sorry!"
    fi
  fi
fi
#
# Do the actual merge
#
merge -p -A -L yours -L base -L their $yours $base $their > $4
ret=$?
#
# Report conflicts
#
echo -n "Conflicts: " `grep -c '<<<<<' $4`
echo -n , `grep -c '======' $4` 
echo , `grep -c '>>>>>' $4` 
#
# Start editor to resolv conflicts, if necessary.
#
if [ -z "$EDITOR" ]
then
  export EDITOR=emacs
fi
if [ `basename $EDITOR` = emacs ]
then
  EDIT_SWITCH=' -l /usr/local/lib/p4_merge_mode.el'
fi
if [ $ret = 1 ] 
then
  $EDITOR $4 $EDIT_SWITCH 
else
  if [ $ret = 2 ] 
  then
    echo "Merge reported trouble"
    $EDITOR $4 $EDIT_SWITCH 
  fi
fi
#
# Clean up and exit
#
rm -f $base $their $yours
exit $ret
