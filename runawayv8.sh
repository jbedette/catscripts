#!/bin/bash
usr="" # so if script is run with argument -u username, it checks if they are on.
option="both" #default values
min_cpu="20" #20
min_mem="15" #15


red='\e[0;31m' #constants
NC='\e[0m' #no color
host_list=`netgrouplist linux-login-sys`
#host_list="rita"

#########todo:########
#maybe color code cpu, mem, etc respectively
#maybe add load threshold?
#maybe change echo "." to print so they end on the same line
#edit user check to specify one or multiple computers or all computers to check
########edit so checks if they are logged in##########3

#make flags work
args=( `getopt -o h?:t:c:m:u: -l help,host: -- $*` )


for i in "${args[@]}"
do

	case "$i" in # DOESN'T WORK RIGHT NEED TO LOOK AT RELSQI's flying pigs use $2 and "shift" instead of $OPTIONARG or install long
		"-t")
			option=$2
			shift #shifts to arguments thrown to script???? clever relsqui so $2 is what you want eg -t cpu -m 32 $2 will be cpu, after shift
			      #it will be 32
			shift 
			echo "test type selected as $option"
			if [ "$option" == "cpu" ]; then echo "Checking for cpu runaways"; fi 
			if [ "$option" == "mem" -o "$option" == "memory" ]; then echo "Checking for memory runaways"; fi 
		;;
		"-c")
			min_cpu=$2
			shift; shift
		;;
		"-m")
			min_mem=$2
			shift; shift
		;;
		"-u")
			usr=$2
			shift; shift
		;;
		"--host")
			host_list=$2
			shift; shift
		;;	
		"-h" | "--help" | "-?" | "-help")
			shift
			echo -e "\nUsage: runaway.sh or with flags. \nPossible flags are: -t [type] -c [min cpu %] -m [min ram %] --host [ip or name] -h -? --help \nrunning with -h or --help or -? will show this"
		    return 0
        ;;
	esac
done

if [ "$option" == "both" ]; then echo "Checking for runaways"; fi 

##export ssh
eval `ssh-agent`
ssh-add # will ask for which id


cpu_check ()
{
	ssh -o ConnectTimeout=5 $USER@$i  'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm '| awk -v THISBOX=$i -v min_cpu=$min_cpu '{ if($3 > min_cpu){ print  $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11 "\n" "Possible CPU runaway on " THISBOX "\n" }}' | sort -k 3 -r && echo -e "."
}

memory_check ()
{
	ssh -o ConnectTimeout=5 $USER@$i ' ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm ' | awk -v THISBOX=$i -v min_mem=$min_mem '{ if($4 > min_mem)  print  $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11 "\n" "Possible CPU runaway on " THISBOX "\n"}' | sort -k 4 -r && echo -e "."
}

cpu_mem_check ()
{
    ssh -o ConnectTimeout=5 $USER@$i 'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm' \
        | awk -v HOSTNAME=$HOSTNAME -v min_cpu=$min_cpu -v min_mem=$min_mem '{ if($3 > min_cpu || $4 > min_mem)  print  "\n" $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11 "\n"} {print $HOSTNAME} ' \
        | sort -k 3 -r
}


echo -e "\n${red}USER	CPU	MEM	TTY	TIME		COMMAND${NC}"

for i in $host_list
do
case $option in

    "cpu")
	cpu_check $i $min_cpu $min_mem
        ;;

    "memory" | "mem")
	memory_check $i $min_mem $min_cpu
        ;;

    "both")
	cpu_mem_check $i $min_mem $min_cpu & 
        ;;


    "user" | "check_user")
        echo "Checking if they are logged in on $i"
        who -all | grep $usr
        ps -aux | grep $usr
        ;;
  
esac
done

kill $SSH_AGENT_PID


#graveyard of misfitt ideas
##check for multiples of command being run: if (a[$11]++ > 5) {print "\n" "\n" "COPY?" "\t\t" $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11} }'


#    echo $i
#    ssh -o ConnectTimeout=5 $USER@$i 'ps -A -o user,pid,pcpu,pmem,vsz,rss,tty,s,stime,time,comm' \
#        | awk -v HOSTNAME=$HOSTNAME -v min_cpu=$min_cpu -v min_mem=$min_mem '{ if($3 > min_cpu || $4 > min_mem)  print  $HOSTNAME "\n" $1 "\t" $3  "\t" $4 "\t" $7 "\t" $10 "\t" $11 "\n" system(uptime)}' \
#        | sort -k 3 -r 
#        &&  echo "Uptime is: " && uptime || echo -e "." '
#    echo -e "\n\n"

