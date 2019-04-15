#!/bin/bash

##Input looks like printtest.sh [-t check_type] [-p printer_tocheck] [-h] 
#https://chronicle.cat.pdx.edu/projects/deskcat-manual/wiki/Printer_queue_check_tickets_-_Morning_and_Afternoon

img="/tmp/print_test.png"
img_location="web.cecs.pdx.edu/~mwilliam/testpage.png"
#array of printers
# maybe allow specifying a file to print, or a file containing printers?
fab_printers=( fab5517clr1 fab5517bw1 fab5517bw2 fab6001bw1 fab6019bw1 fab8201bw1 fab84clr1 fabc8802bw1 ) 
eb_printers=( eb325bw1 eb325bw2 eb423bw1 eb325clr1 eb423clr1 )
dog_printers=( fab8201bw1 ) 
fabnc_printers=( fab5517bw1 fab5517bw2 fab6001bw1 fab6019bw1 fab8201bw1 fabc8802bw1 ) 
ebnc_printers=( eb325bw1 eb325bw2 eb423bw1 )
fabc=( fabc8802bw1 )


time="$(date)"
username=$USER
#maybe from a file? 

#make flags work
args=( `getopt -o h?:t:p:u: -l help -- $*` )



###functions ##actual input params come in the next section
print_test ()
{
	wget $img_location -O "${img}" 1&> /dev/null ## get the test page

	width=$(identify -format %W ${img}) ##formatting to make teh convert command work nicely
	width=$(( ${width} * 9 / 10 )) # image adjusting stuff #-background '#0008'

	for i in "${printers[@]}"
	do
		caption="User $username is checking the status of $i at ${time}"
	 	convert  -gravity center   -size ${width}x100  caption:"${caption}"    "${img}"    +swap    -gravity south     -composite  "${img}" 
		echo "printing to $i"
		lpr -P $i ${img}
	 done 
	 rm ${img}
}

help_resp ()
{
    echo -e "\nUsage: printscript.sh with flags. \nPossible flags are: -t type [-p printer] [-h] [-?] [--help] \nrunning with impropper commands or -h or --help or -? will show this"
	echo -e "\nTypes of checks: EB,FAB,BOTH,BOTHNC,DOG,PRINTER remember to use -p printername with -p flag."

}


if [ -z "${1}" ] #if no arguments given
then
    check_type="both"
    echo "Print test sent to ${fab_printers[@]} and ${eb_printers[@]}"

else
for i in "${args[@]}" ##arguments given to script
do
	case "$i" in 
	"-t")
		check_type=$2
		shift #shifts to arguments thrown to script???? clever relsqui so $2 is what you want eg -t cpu -m 32 $2 will be cpu, after shift
		shift 
		echo "print test selected as $check_type"
        break 
	;;
#	"-u")
#		$usrname=$2
#		echo "using username $username on test pages"
#		shift; shift
#	;;
	"-p")
        check_type="printer"
		user_printer=$2
		shift; shift
        echo "Print test sent to $user_printer"
	    break
    ;;
    
	"-h" | "--help" | "-?" | *)
		shift
        help_resp
        exit
    ;;
	
    esac
done
fi


case "$check_type" in
	"FAB" | "fab")		
        printers=( ${fab_printers[@]} )
        print_test 
		echo "complete"
	;;

	"EB" | "EB325" | "eb" | "eb325")	
        printers=( ${eb_printers[@]} )
        print_test  
		echo "complete"
	;;

	"DOG" | "dog")
        printers=( ${dog_printers[@]} ) 
		print_test
		echo "complete"
	;;
    
    "both" | "Both" | "BOTH")
        printers=( ${fab_printers[@]} )
        print_test 
        printers=( ${eb_printers[@]} )
        print_test 
        echo "complete, did both"
    ;;
    "both_nc" | "Both_nc" | "BOTH_NC" | "bothnc" | "BOTHNC")
        printers=( ${fabnc_printers[@]} )
        print_test 
        printers=( ${ebnc_printers[@]} )
        print_test
        echo "complete, did both"
        echo "NOTE: did not print to color printers"
    ;;
    "fabc" | "tutors" | "tutor")
        printers=( ${fabc} )
        print_test 
        echo "complete, sent to tutor printer only"
    ;;

    "printer") #is set in getargs case section
        #could jsut move that down here, condence cases
        #possibly add printing to multiple printers 
        printers=$user_printer   
		print_test
		echo "complete"
        ;;
    *)
        echo -e "\nInvalid selection\n"
        ;;

esac

echo -e "\n Dont forget to check the job queue in cups and HELA!\n30+min jobs need to be killed.\send user a form letter in /cat/doc/formletters/printer_killjob"
