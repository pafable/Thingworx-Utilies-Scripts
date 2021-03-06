$USER='C:\Users\Administrator\Desktop'
$SUP='C:\Program Files\thingworxData\ThingWorxStorage\extensions\Support.tools'  #Change with actual location of TWX Support Tools Extension dir
$TMCAT='C:\Program Files\Apache Software Foundation\Tomcat 8.5\logs'
$TWXST='C:\Program Files\thingworxData\ThingWorxStorage\logs'                    #Change with actual location of TWX logs dir
$TWX_REPO='C:\Program Files\thingworxData\ThingWorxStorage\repository\'                   
$H=hostname
$D=Get-Date -UFormat "%Y%m%d%H%M%S"
$TPID=get-process "tomcat8w" | select -expand id
New-Item -ItemType directory -Path C:\Users\Administrator\Desktop\$H-LOGS-$D
$FOLDER="C:\Users\Administrator\Desktop\$H-LOGS-$D"
Copy-Item -Path "$TWXST\*.Log-*" -Destination "$FOLDER"
Copy-Item -path "$TMCAT\catalina.*" -Destination "$FOLDER"
Copy-Item -path "$TMCAT\tomcat8-stderr.*" -Destination "$FOLDER"
Copy-Item -Path "$TMCAT\tomcat8-stdout.*" -Destination "$FOLDER"
#Copy-Item -path "$TWXST\*.log" -Destination "$FOLDER"
Write-Host
Write-Host " Support Tools extension is NOT installed gathering thread heap dumps manually."
Write-Host 


Function THREAD1 {
####### Collects stacktrace using TWX Support tools ######
Write-Host ' Collecting logs using runstacktrace file'
New-Item $TWX_REPO\runstacktrace -ItemType file
Start-Sleep -s 180
Copy-Item -path "$TWX_REPO\stacktrace" -destination "$FOLDER"
Remove-Item –path  $TWX_REPO\runstacktrace
Remove-Item –path  $TWX_REPO\stacktrace
 }

Function THREAD2 {
####### Collects Threads using jstack.exe #############
$THREAD=Read-Host -Prompt ' How many threads do you want?'
$T_DELAY=Read-Host -Prompt ' Delay in seconds?'    
$N=0

        while($N -lt $THREAD) {
        Write-Host "Collecting thread $N from pid $TPID at $T_DELAY sec intervals... "
        .'C:\Program Files\Java\jdk1.8.0_161\bin\jstack.exe'-F $TPID >> $FOLDER\threads-$N.log
        Start-sleep -s $T_DELAY
        $N++
        }
    }

Function HEAP1 {
###### Collects heap dump with dumpheap file
Write-Host ' Collecting logs using runstacktrace file'
New-Item $TWX_REPO\dumpheap -ItemType file
Start-Sleep -s 120
Copy-Item -Path "$TMCAT\*.hprof" -destination "$FOLDER"
Remove-Item –Path  $TMCAT\*.hprof
    }
    
Function HEAP2 {
####### Collects heap dump using jmap.exe
.'C:\Program Files\Java\jdk1.8.0_161\bin\jmap.exe' -F -dump:file=C:\Program Files\Apache Software Foundation\Tomcat 8.5\logs\heapdump.hprof $TPID
Copy-Item -Path "$TMCAT\*.hprof" -destination "$FOLDER"
    }

###### Main ######
If (Test-Path $SUP) {
    THREAD1
    HEAP1
    } else {
    THREAD2
    HEAP2
    }