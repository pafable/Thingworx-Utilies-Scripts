#!/bin/bash
#pafable@ptc.com 

display_usage() {
   echo
   echo -e " Usage: $0 "
   echo -e " Designed to automatically import extensions through the server-side"
   echo -e " Make sure /tmp/extensions is created before executing script"
   echo -e " Extensions need to be in .jar format to be imported"
   echo
}

case $1 in
  
        -h)
        display_usage
        exit 0
        ;;

        -help)
        display_usage
        exit 0
        ;;
        
        --h)
        display_usage
        exit 0
        ;;
esac


############### Curls the rest of the jar files #########################
echo
echo -n " Enter full path of the TWX extensions directory: "
read EXTDIR
A=$(ls -1 $EXTDIR | wc -l)
echo -n " Enter full path of the extensions that need to be IMPORTED: "
read IMPORT
B=$(ls -1  $IMPORT | wc -l)
TMP=$(ls -1 $IMPORT)
echo -n " Enter TWX composer username: "
read TUSER
echo -n " Enter TWX composer password: "
read -s TPW

if [[ $(ps -ef | grep tomcat | grep twadmin | awk '{print $2}') -gt 0 ]]; then
   if [[ -d $IMPORT ]]; then
   cd $IMPORT
     while [[ $A -lt $B ]]; do
           for X in $TMP
           do
             echo
             curl -u $TUSER:$TPW  'https://localhost:443/Thingworx/ExtensionPackageUploader?purpose=import&validate=false' -H 'X-XSRF-TOKEN: TWX-XSRF-TOKEN-VALUE' --form file=@$X
             A=$(ls -1 $EXTDIR | wc -l)
             B=$(ls -1  $IMPORT | wc -l)
             echo
           done
     done
   else
      echo
      echo " $IMPORT does not exist."
      echo
    fi
else
   echo "[ERROR] Apache Tomcat is not running. Please turn it on and re-run the script."
fi

echo
echo
echo -n "# Extension in $IMPORT: "
ls -1  $IMPORT | wc -l
echo
echo -n "# Extensions in ThingworxStorage: "
ls -1 $EXTDIR | wc -l
echo