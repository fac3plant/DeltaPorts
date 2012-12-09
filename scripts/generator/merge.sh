#!/bin/sh

CONFFILE=/usr/local/etc/dports.conf

if [ ! -f ${CONFFILE} ]; then
   echo "Configuration file ${CONFFILE} not found"
   exit 1
fi

checkdir ()
{
   eval "MYDIR=\$$1"
   if [ ! -d ${MYDIR} ]; then
     echo "The $1 directory (${MYDIR}) does not exist."
     exit 1
  fi
}

confopts=`grep "=" ${CONFFILE}`
for opt in ${confopts}; do
   eval $opt
done

checkdir DELTA
checkdir DPORTS
checkdir FPORTS
checkdir MERGED

AWKCMD='{ n=split($1,a,"-") }{ print substr($2,12) " " a[n] }'
TMPFILE=/tmp/tmp.awk
WORKAREA=/tmp/merge.workarea

rm -rf ${WORKAREA}
mkdir ${WORKAREA}
mount -t tmpfs tmpfs ${WORKAREA}

merge()
{
   local M1=${MERGED}/$1
   local DP=${DELTA}/ports/$1
   local MD=0
   local DDIFF=0
   local DDRAG=0
   rm -rf ${M1}
   mkdir -p ${M1}

   if [ $2 -eq 1 ]; then
      isDPort=
   else
      isDPort=`grep ^DPORT ${DP}/STATUS`
   fi
   if [ -n "${isDPORT}" ]; then
      cpdup -i0 ${DP}/newport ${M1}
   else
      [ -f ${DP}/Makefile.DragonFly ] && MD=1
      [ -d ${DP}/dragonfly ] && DDRAG=1
      [ -d ${DP}/diffs ] && DDIFF=1
      if [ ${MD} -eq 0 -a ${DDRAG} -eq 0 -a ${DDIFF} -eq 0 ]; then
        cpdup -i0 ${FPORTS}/${1} ${M1}
      else
        rm -rf ${WORKAREA}/*
        cp -pr ${FPORTS}/$1/* ${WORKAREA}/
        [ ${MD} -eq 1 ] && cp -p ${DP}/Makefile.DragonFly ${WORKAREA}/
        [ ${DDRAG} -eq 1 ] && cp -pr ${DP}/dragonfly ${WORKAREA}/
        if [ ${DDIFF} -eq 1 ]; then
         diffs=$(find ${DP}/diffs -name \*\.diff)
         for difffile in ${diffs}; do
            patch -d ${WORKAREA} < ${difffile}
         done
         rm ${WORKAREA}/*.orig
        fi
        cpdup -i0 ${WORKAREA} ${M1}
      fi
   fi
}


awk -F \| "${AWKCMD}" ${INDEX} | sort > ${TMPFILE}
while read fileline; do
   counter=0
   for element in ${fileline}; do
      counter=$(expr ${counter} '+' 1)
      eval val_${counter}=${element}
   done

   # val_1 = category/portname
   # val_2 = version,portrevision
   PORT=${DELTA}/ports/${val_1}
   
   if [ ! -f ${PORT}/STATUS ]; then
      merge ${val_1} 1
   else
      ML=$(grep -E '^(MASK|LOCK)' ${PORT}/STATUS)
      if [ "${ML}" = "LOCK" ]; then
         # locked, do nothing
      elif [ "${ML}" = "MASK" ]; then
         # remove if existed previously
         rm -rf ${MERGED}/${val_1}
      elif [ ! -d ${MERGED}/${val_1} ]; then
         merge ${val_1} 2
      else
         # check previous attempts
         lastatt=`grep "^Last attempt: " ${PORT}/STATUS | cut -c 15-80`
         if [ "${lastatt}" != "${val_2}" ]; then
            merge ${val_1} 3
         fi
      fi
   fi

done < ${TMPFILE}

rm -f ${TMPFILE}

cpdup -i0 ${FPORTS}/Tools ${MERGED}/Tools

rm -rf ${WORKAREA}/*

for k in Mk Templates; do
  cp -pr ${FPORTS}/${k} ${WORKAREA}/
  diffs=$(find ${DELTA}/special/${k}/diffs -name \*\.diff)
  for difffile in ${diffs}; do
    patch --quiet -d ${WORKAREA}/${k} < ${difffile}
  done
  rm ${WORKAREA}/${k}/*.orig
  cpdup -i0 ${WORKAREA}/${k} ${MERGED}/${k}
done

umount ${WORKAREA}
rm -rf ${WORKAREA}
