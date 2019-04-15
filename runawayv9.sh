#!/bin/bash

##export ssh
eval `ssh-agent`
ssh-add # will ask for which id

ido_thing(){
    netgrouplist linux-login-sys | xargs -I HOST -P 100 ssh -o ConnectTimeout=5 HOST "` sleep .01 ;declare -f another_thing`; another_thing" 
}

do_thing(){
ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm | awk  -v min_cpu="20" -v min_mem="15" '{ if($3 > min_cpu || $    4 > min_mem)  print    $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11}' && uptime && hostname 
}

another_thing(){
hostname && uptime && ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm | awk -v  min_cpu=20 -v min_mem=15 'NR >4 { if($3 > min_cpu || $4 > min_mem)  print  $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11 }'

}


# Slower but has sections broken up correctly, no collusion
#for i in $host_list
#do
#ssh  -o IdentitiesOnly=yes -o ConnectTimeout=3 $i "`declare -f do_thing` ; do_thing"; echo -e "\n" & 
#done

# much faster!
ido_thing 

kill $SSH_AGENT_PID
exit 0

#graveyard of misfitt ideas
##check for multiples of command being run: if (a[$11]++ > 5) {print "\n" "\n" "COPY?" "\t\t" $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11} }'

