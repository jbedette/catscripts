#!/bin/bash




#variables
min_cpu="20" #min cpu usage for a process to be categorized as a runaway, play around with this number 
min_mem="15" #ditto for memory

red="\033[0;32m"
no_color="\033[0m"

host_list=`netgrouplist  linux-login-sys`

##export ssh
eval `ssh-agent`
ssh-add 


#making a bash function that does all the work
cpu_mem_check ()
{
    echo -e "\n\n $red${i}$no_color"        #The $red and $no_color are to make text green
    ssh -o ConnectTimeout=5 $1@$2 ps -A -o user,pcpu,pmem,tty,time,comm \
        | awk -v min_cpu=$3 -v min_mem=$4 '{ if($2 > min_cpu || $3 > min_mem){ 
    print "USER\tCPU\tMEM\tTTY\tTIME\t\t\tCOMMAND"; 
    print  $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\n"; }}' #$0 in awk refers to the entire line it read
    ssh -o ConnectTimeout=5 $1@$2 "echo 'Uptime is: '; uptime"
}



#where the magic happens (loop through list of hosts, doing magic^)
for i in $host_list
do
   cpu_mem_check $USER $i $min_cpu $min_mem #pass in the $USERNAME, function uses it as $1, etc
done

#so we don't leave our ssh agent running in the background
kill $SSH_AGENT_PID
