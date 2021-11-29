#!/bin/bash
function Select {
	SELECT=0
	while [[ $SELECT != [1-$1] ]]
	do
		read -n 1 -s SELECT
		if [[ $SELECT != [1-$1] ]]
		then
			echo "ERROR: INPUT MUST BE BETWEEN 1 AND $1!"
		fi
	done
}
function NameSearch {
	while [[ $SELECT != 1 ]]
	do
		echo -e "Please enter a letter to view all $2 beginning with that letter."
		while [[ $LETTER != [A-Z] ]]
		do
			INPUT=""
			read -n 1 -s INPUT
			LETTER=${INPUT^^}
			if [[ $LETTER != [A-Z] ]]
			then
				echo -e "ERROR: INPUT MUST BE A LETTER\n"
			fi
		done
		grep \"$LETTER $2.csv | sed s/\"//g
		SELECT=0
			echo -e "1. Select a $1.\n2. View more $2\n"
			read -n 1 -s SELECT
			if [[ $SELECT != [1-2] ]]
			then
				echo "ERROR: INPUT MUST BE 1 OR 2!\n"
			fi
			if [ $SELECT -eq 2 ]
			then
				LETTER=""
			fi
	done
}
function Selection {
	       COUNT=0
	       while [ $COUNT -ne 1 ]
	       do
		       echo -e "Please enter the full name of the $1\n"
		       read NAME
		       COUNT=$(grep "\"$NAME\"" $2.csv | wc -l)
					 NAME=$(grep "\"$NAME\"" $2.csv | sed s/\"//g)
	       done
	       echo -e "You selected $NAME.\n"
}
function TotalGoalsAndGoalDiff {
	HOMEGOALS=${HOMEGOALS:-0}
	HOMEGOALSAGAINST=${HOMEGOALSAGAINST:-0}
	AWAYGOALS=${AWAYGOALS:-0}
	AWAYGOALSAGAINST=${AWAYGOALSAGAINST:-0}
	TOTALGOALSBYX=$(($HOMEGOALS+$AWAYGOALS))
	TOTALGOALSAGAINST=$(($AWAYGOALSAGAINST+$HOMEGOALSAGAINST))
	GOALDIFFERENTIAL=$(($TOTALGOALSBYX-$TOTALGOALSAGAINST))
}
function RecordAndWinPct {
	HOMEWINS=${HOMEWINS:-0}
	AWAYWINS=${AWAYWINS:-0}
	HOMELOSSES=${HOMELOSSES:-0}
	AWAYLOSSES=${AWAYLOSSES:-0}
	TOTALDRAWSBYX=${TOTALDRAWSBYX:-0}
	TOTALWINSBYX=$(($HOMEWINS+$AWAYWINS))
	TOTALLOSSESBYX=$(($HOMELOSSES+$AWAYLOSSES))
	TOTALGAMESBYX=$(($TOTALWINSBYX + $TOTALLOSSESBYX + $TOTALDRAWSBYX))
	WINPCT=$(echo  "scale=2; $TOTALWINSBYX / $TOTALGAMESBYX * 100" | bc -l | sed 's/\..*//g')
	WLD
}
function WLD {
	echo "W  -  L  -  D "
	echo "$TOTALWINSBYX - $TOTALLOSSESBYX - $TOTALDRAWSBYX"
	echo "Winning Percentage: $WINPCT%"
}
function Pause {
	echo "Press any key to continue..."
	read -n 1 -s PAUSE
	clear
	ContinueWithCountry?
	clear
}
function ContinueWithCountry? {
	echo "Would you like to continue with $COUNTRY?"
	echo -e "1. Yes\n2. No"
	Select 2
	if [ $SELECT -eq 2 ]
	then
		COUNTRY=""
	fi
}
if [[ -e results.csv && -e shootouts.csv && -e CityScan.py && -e CountryScan.py ]]
then
	sleep 0
else
	if [[ -e results.csv && -e shootouts.csv ]]
	then
		sleep 0
	else
		echo "ERROR: MISSING REQUIRED DATA FILE(S)!"
		exit 1
	fi
	if [[ -e CityScan.py && -e CountryScan.py ]]
	then
		sleep 0
	elif [[ -e cities.csv && -e countries.csv ]]
	then
		echo "WARNING: MISSING PYTHON SCRIPTS."
	else
		echo "ERROR: MISSING REQUIRED DATA FILE(S)!"
		exit 2
	fi
fi
if [ -e cities.csv ]
then
	sleep 0
else
	python3 CityScan.py
fi
if [ -e countries.csv ]
then
	sleep 0
else
	python3 CountryScan.py
fi
LINES="----------------------------------------------"
MENU="1. Search for a country.\n2. Select a country.\n3. Exit\n"
echo $LINES
echo "		Hello $USER!		"
echo $LINES
echo -e "This application is designed to allow you to\nview certain insights into the history of\ninternational soccer."
echo $LINES
while [ 1 -eq 1 ]
do
	echo -e $MENU
	Select 3
	# SPECIFIC TEAM
	case $SELECT in
		# COUNTRY SEARCH / SELECTION
		1)
			NameSearch country countries
			Selection country countries
		;;
		# COUNTRY SELECTION
		2)
			Selection country countries
		;;
		3)
			exit 0
		;;
	esac
	COUNTRY=$NAME
	while [ -n "$COUNTRY" ]
	do
		echo -e "1. Total goals scored by $COUNTRY and their goal differential.\n2. Win/Loss record and winning % of $COUNTRY.\n3. Look at stats for $COUNTRY in a range of years.\n4. Look at stats for $COUNTRY when they play in a certain city.\n5. Win/Loss record of $COUNTRY in games decided by penalty kicks\n6. Exit\nPlease select an option."
		Select 6
		case $SELECT in
			# TOTAL GOALS + GOAL DIFFERENTIAL FOR CHOSEN COUNTRY
			1)
				echo -e "Scanning data...\n"
				HOMEGOALS=$(awk -F, '{print $2","$4}' results.csv | grep "^$COUNTRY," | awk -F, '{sum+=$2} {print sum}' | tail -n1)
				HOMEGOALSAGAINST=$(awk -F, '{print $2","$5}' results.csv | grep "^$COUNTRY," | awk -F, '{sum+=$2} {print sum}' | tail -n1)
				AWAYGOALS=$(awk -F, '{print $3","$5}' results.csv | grep "^$COUNTRY," | awk -F, '{sum+=$2} {print sum}' | tail -n1)
				AWAYGOALSAGAINST=$(awk -F, '{print $3","$4}' results.csv | grep "^$COUNTRY," | awk -F, '{sum+=$2} {print sum}' | tail -n1)
				TotalGoalsAndGoalDiff
				echo -e "Total goals by $COUNTRY: $TOTALGOALSBYX\n"
				echo -e "$COUNTRY's goal differential: $GOALDIFFERENTIAL\n"
				Pause
			;;
			# WIN/LOSS RECORD & WINNING %
			2)
				echo -e "Scanning data...\n"
				HOMEWINS=$(awk -F, '{print $2","$4","$5}' results.csv | grep "^$COUNTRY," | awk -v sum=0 -F, '{if ($2 > $3)  sum++; } {print sum}' | tail -n1)
				AWAYWINS=$(awk -F, '{print $3","$4","$5}' results.csv | grep "^$COUNTRY," | awk -v sum=0 -F, '{if ($2 < $3)  sum++; } {print sum}' | tail -n1)
				HOMELOSSES=$(awk -F, '{print $2","$4","$5}' results.csv | grep "^$COUNTRY," | awk -v sum=0 -F, '{if ($2 < $3)  sum++; } {print sum}' | tail -n1)
				AWAYLOSSES=$(awk -F, '{print $3","$4","$5}' results.csv | grep "^$COUNTRY," | awk -v sum=0 -F, '{if ($2 > $3)  sum++; } {print sum}' | tail -n1)
				TOTALDRAWSBYX=$(awk -F, '{print $2","$3","$4","$5}' results.csv | grep "$COUNTRY," | awk -v sum=0 -F, '{if ($3 == $4)  sum++; } {print sum}' | tail -n1)
				RecordAndWinPct
				Pause
			;;
			3)
			# YEAR RANGE
				STARTYEAR=0
				while [[ $STARTYEAR < 1872 || $STARTYEAR > 2021 ]]
				do
					echo -e "Enter first year of range.(Default: 1872)"
					read STARTYEAR
					if [ -z $STARTYEAR ]
					then
						STARTYEAR=1872
					fi
					if [[ $STARTYEAR =~ '^[0-9]+$' || $STARTYEAR < 1872 || $STARTYEAR > 2021 ]]
					then
						echo "ERROR: INPUT MUST BE A NUMBER BETWEEN 1872 AND 2021"
					fi
				done
				ENDYEAR=0
				while [[ $ENDYEAR < 1872 || $ENDYEAR > 2021 ]]
				do
					echo -e "Enter first year of range.(Default: 2021)"
					read ENDYEAR
					if [ -z $ENDYEAR ]
					then
						ENDYEAR=2021
					fi
					if [[ $ENDYEAR =~ '^[0-9]+$' || $ENDYEAR < 1872 || $ENDYEAR > 2021 ]]
					then
						echo "ERROR: INPUT MUST BE A NUMBER BETWEEN 1872 AND 2021"
					fi
				done
				YEARRANGE="$STARTYEAR-$ENDYEAR"
				echo "Year range: $YEARRANGE"
				echo -e "1. Total goals scored and goal differential for $COUNTRY between $YEARRANGE.\n2. Win/Loss record and winning percentage for $COUNTRY between $YEARRANGE.\nPlease select an option."
				Select 2
				case $SELECT in
						# TOTAL GOALS + GOAL DIFFERENTIAL FOR A RANGE OF YEARS
					1)
						echo -e "Scanning data...\n"
						TOTALGOALSBYX=0
						TOTALGOALSAGAINST=0
						CURRENTYEAR=$STARTYEAR
						while [ $CURRENTYEAR -le $ENDYEAR ]
						do
							HOMEGOALS=$(awk -F, '{print $1","$2","$4}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -F, '{sum+=$3} {print sum}' | tail -n1)
							HOMEGOALSAGAINST=$(awk -F, '{print $1","$2","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -F, '{sum+=$3} {print sum}' | tail -n1)
							AWAYGOALS=$(awk -F, '{print $1","$3","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -F, '{sum+=$3} {print sum}' | tail -n1)
							AWAYGOALSAGAINST=$(awk -F, '{print $1","$3","$4}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -F, '{sum+=$3} {print sum}' | tail -n1)
							((TOTALGOALSBYX+=(HOMEGOALS+AWAYGOALS)))
							((TOTALGOALSAGAINST+=(AWAYGOALSAGAINST+HOMEGOALSAGAINST)))
							((CURRENTYEAR++))
						done
						GOALDIFFERENTIAL=$(($TOTALGOALSBYX-$TOTALGOALSAGAINST))
						echo -e "Total goals by $COUNTRY between $YEARRANGE: $TOTALGOALSBYX\n"
						echo -e "$COUNTRY's goal differential during $YEARRANGE: $GOALDIFFERENTIAL\n"
						Pause
					;;
						# WIN/LOSS RECORD + WIN % FOR A RANGE OF YEARS
					2)
						CURRENTYEAR=$STARTYEAR
						TOTALWINSBYX=0
						TOTALLOSSESBYX=0
						TOTALGAMESBYX=0
						TOTALDRAWSBYX=0
						echo -e "Scanning data...\n"
						while [ $CURRENTYEAR -le $ENDYEAR ]
						do
							HOMEWINS=$(awk -F, '{print $1","$2","$4","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -v sum=0 -F, '{if ($3 > $4)  sum++;} {print sum}' | tail -n1)
							AWAYWINS=$(awk -F, '{print $1","$3","$4","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -v sum=0 -F, '{if ($3 < $4)  sum++;} {print sum}' | tail -n1)
							HOMELOSSES=$(awk -F, '{print $1","$2","$4","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -v sum=0 -F, '{if ($3 < $4)  sum++;} {print sum}' | tail -n1)
							AWAYLOSSES=$(awk -F, '{print $1","$3","$4","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -v sum=0 -F, '{if ($3 > $4)  sum++;} {print sum}' | tail -n1)
							DRAWS=$(awk -F, '{print $1","$2","$3","$4","$5}' results.csv | grep ",$COUNTRY," | grep $CURRENTYEAR | awk -v sum=0 -F, '{if ($4 == $5)  sum++;} {print sum}' | tail -n1)
							((TOTALWINSBYX+=(HOMEWINS+AWAYWINS)))
							((TOTALLOSSESBYX+=(HOMELOSSES+AWAYLOSSES)))
							((TOTALDRAWSBYX+=DRAWS))
							((CURRENTYEAR++))
						done
						TOTALGAMESBYX=$(($TOTALWINSBYX + $TOTALLOSSESBYX + $TOTALDRAWSBYX))
						WINPCT=$(echo  "scale=2; $TOTALWINSBYX / $TOTALGAMESBYX * 100" | bc -l | sed 's/\..*//g')
						WLD
						Pause
					;;
				esac
			;;
			# STATS FOR GAMES IN A CHOSEN CITY
			4)
				NameSearch city cities
				Selection city cities
				CITY=$NAME
				echo -e "1. Total goals scored by $COUNTRY and their goal differential when they play in $CITY.\n2. Win/Loss record and winning % of $COUNTRY when they play in $CITY.\nPlease select an option."
				Select 2
				case $SELECT in
					# GOALS SCORED AND GOAL DIFFERENTIAL IN A CHOSEN CITY
					1)
					echo -e "Scanning data...\n"
					HOMEGOALS=$(awk -F, '{print $2","$4","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -F, '{sum+=$2} {print sum}' | tail -n1)
					HOMEGOALSAGAINST=$(awk -F, '{print $2","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -F, '{sum+=$2} {print sum}' | tail -n1)
					AWAYGOALS=$(awk -F, '{print $3","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -F, '{sum+=$2} {print sum}' | tail -n1)
					AWAYGOALSAGAINST=$(awk -F, '{print $3","$4","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -F, '{sum+=$2} {print sum}' | tail -n1)
					TotalGoalsAndGoalDiff
					echo -e "Total goals by $COUNTRY when playing in $CITY: $TOTALGOALSBYX\n"
					echo -e "$COUNTRY's goal differential when playing in $CITY: $GOALDIFFERENTIAL\n"
					Pause
					;;
					# wIN/LOSS RECORD AND WINNING PCT IN A CERTAIN CITY
					2)
					echo -e "Scanning data...\n"
					HOMEWINS=$(awk -F, '{print $2","$4","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -v sum=0 -F, '{if ($2 > $3)  sum++; } {print sum}' | tail -n1)
					AWAYWINS=$(awk -F, '{print $3","$4","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -v sum=0 -F, '{if ($2 < $3)  sum++; } {print sum}' | tail -n1)
					HOMELOSSES=$(awk -F, '{print $2","$4","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -v sum=0 -F, '{if ($2 < $3)  sum++; } {print sum}' | tail -n1)
					AWAYLOSSES=$(awk -F, '{print $3","$4","$5","$7}' results.csv | grep "^$COUNTRY," | grep ",$CITY" | awk -v sum=0 -F, '{if ($2 > $3)  sum++; } {print sum}' | tail -n1)
					TOTALDRAWSBYX=$(awk -F, '{print $2","$3","$4","$5","$7}' results.csv | grep "$COUNTRY," | grep ",$CITY" | awk -v sum=0 -F, '{if ($3 == $4)  sum++; } {print sum}' | tail -n1)
					RecordAndWinPct
					Pause
					;;
				esac
			;;
			5)
				echo -e "Scanning data...\n"
				PKWINS=$(awk -F, '{print $4}' shootouts.csv | grep "$COUNTRY" | wc -l)
				PKLOSS=$(awk -F, '{print $2","3","$4}' shootouts.csv | grep "$COUNTRY," | awk -v country="$COUNTRY" -v sum=0 -F, '{if ($3 != country) sum++; } {print sum}' | tail -n1)
				echo "W - L"
				echo "$PKWINS - $PKLOSS"
				Pause
			;;
			6)
				exit 0
			;;
		esac
	done
done
