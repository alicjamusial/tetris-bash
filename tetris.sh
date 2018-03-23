#!/bin/bash
trap ctrl_c INT

function ctrl_c() {
	stty sane
	exit
}

ROWS=10
COLUMNS=12

SCORE=0

declare -A BOARD

TIMESTART=0
TIMEEND=0
TIMEPASSED=0

ACTUAL_LINE=0

ACCUMULATOR=0
FRAMELENGTH=100

ON_BOTTOM=1
BLOCK_NUMBER=0

PLACE=0
FIRST_APPEARANCE=1

LEFT=0
RIGHT=0

GAME=1

RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[36m'
GREEN='\033[32m'

BOARD_SYMBOL="o"
BLOCK_SYMBOL=$(echo -e "${RED}x${NC}")

function CreateBoard() {
	for((i=-1; i<ROWS; i++));
	do {
		for((j=0; j<COLUMNS; j++));
		do {
			BOARD[$i,$j]=$BOARD_SYMBOL
		} done
		echo
	} done
}

function GenerateBoard() {
	for((i=0; i<ROWS; i++));
	do {
		for((j=0; j<COLUMNS; j++));
		do {
			printf ${BOARD[$i,$j]}
		} done
		echo
	} done
}

function ClearLine() {
    for((j=0; j<COLUMNS; j++));
    do {
        BOARD[$1,$j]=$BOARD_SYMBOL
    } done
}

function CheckIfLoser() {
	if [ $1 -eq 0 ]; then
	{
		GAME=0
	}
	fi
}

function CheckIfFullLine() {
	for((i=0; i<ROWS; i++));
	do {
		IS_FULL=1
		for((j=0; j<COLUMNS; j++));
		do {
			if [ ${BOARD[$i,$j]} = $BOARD_SYMBOL ]; then
				{
					IS_FULL=0
				}
			fi
		} done
		if [ $IS_FULL -eq 1 ]; then
			{
				SCORE=$((SCORE + 50))
				ClearLine "$i"
				for((m=$i; m>-1; m--));
				do {
					for((n=0; n<COLUMNS; n++));
					do {
						BOARD[$m,$n]=${BOARD[$(($m-1)),$n]}
					} done
				} done
			}
		fi
	} done
}

function DrawBlocks() {
  if [ $ON_BOTTOM -eq 1 ]; then
  {
		BLOCK_NUMBER=$(( ( RANDOM % 5 )  + 1 ))
		ON_BOTTOM=0
	}
	fi
	case "$BLOCK_NUMBER" in
	  "1") DrawBlock1 "$1" ;;
	  "2") DrawBlock2 "$1" ;;
	  "3") DrawBlock3 "$1" ;;
	  "4") DrawBlock4 "$1" ;;
	  "5") DrawBlock5 "$1" ;;
	esac

}

function MoveBlock() {
	BLOCK_LENGTH=$1

	if [ $LEFT -eq 1 ] && [ $PLACE -gt 0 ]; then
		{
			PLACE=$((PLACE-1))
		}
	fi
	if [ $RIGHT -eq 1 ] && [ $PLACE -lt $((COLUMNS-BLOCK_LENGTH)) ]; then
		{
			PLACE=$((PLACE+1))
		}
	fi
}

function checkIfFirstAppearance() {
	BLOCK_LENGTH=$1
	if [ $FIRST_APPEARANCE -eq 1 ]; then
	{
		PLACE=$(( RANDOM % ($COLUMNS-$BLOCK_LENGTH) ))
		FIRST_APPEARANCE=0
	}
	fi
}

function DrawBlock1() {
	checkIfFirstAppearance "3"

	OLD_PLACE=$PLACE
	MoveBlock "4"

	PREVIOUS_LINE=$(($1 - 1))

	if
	[ ${BOARD[$1,$PLACE]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+1))]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+2))]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+3))]} = $BLOCK_SYMBOL ]; then
	{
		ON_BOTTOM=1
		CheckIfLoser "$1"
	}
	fi

	if [ $ON_BOTTOM -eq 0 ]; then
	{
		# Clear
		BOARD[$PREVIOUS_LINE,$OLD_PLACE]=$BOARD_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BOARD_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+2))]=$BOARD_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+3))]=$BOARD_SYMBOL

		# Draw
		BOARD[$1,$PLACE]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+1))]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+2))]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+3))]=$BLOCK_SYMBOL
	}
	fi
}

function DrawBlock2() {
	checkIfFirstAppearance "1"

	OLD_PLACE=$PLACE
	MoveBlock "2"

	PREVIOUS_LINE=$(($1 - 1))

	if
	[ ${BOARD[$1,$PLACE]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+1))]} = $BLOCK_SYMBOL ]; then
	{
		ON_BOTTOM=1
		CheckIfLoser "$1"
	}
	fi

	if [ $ON_BOTTOM -eq 0 ]; then
	{
		# Clear
		BOARD[$PREVIOUS_LINE,$OLD_PLACE]=$BOARD_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BOARD_SYMBOL

		# Draw
		BOARD[$1,$PLACE]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+1))]=$BLOCK_SYMBOL
	}
	fi
}

function DrawBlock3() {
	checkIfFirstAppearance "2"

	OLD_PLACE=$PLACE
	MoveBlock "3"

	PREVIOUS_LINE=$(($1 - 1))
	PREVIOUS_LINE_2=$(($1 - 2))

	# Clear beacause conflicts with current position are possible
	BOARD[$PREVIOUS_LINE_2,$OLD_PLACE]=$BOARD_SYMBOL
	BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+1))]=$BOARD_SYMBOL
	BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+2))]=$BOARD_SYMBOL
	BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BOARD_SYMBOL

	if
	[ ${BOARD[$(($1 - 1)),$PLACE]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+1))]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$(($1 - 1)),$((PLACE+2))]} = $BLOCK_SYMBOL ]; then
	{
		ON_BOTTOM=1
		CheckIfLoser "$1"

		# Draw again
		BOARD[$PREVIOUS_LINE_2,$OLD_PLACE]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+1))]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+2))]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BLOCK_SYMBOL

	}
	fi
	if [ $ON_BOTTOM -eq 0 ]; then
	{
		BOARD[$PREVIOUS_LINE,$PLACE]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE,$((PLACE+1))]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE,$((PLACE+2))]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+1))]=$BLOCK_SYMBOL
	}
	fi
}

function DrawBlock4() {
	checkIfFirstAppearance "1"

	OLD_PLACE=$PLACE
	MoveBlock "2"

	PREVIOUS_LINE=$(($1 - 1))
	PREVIOUS_LINE_2=$(($1 - 2))

	# Clear beacause conflicts with current position are possible
	BOARD[$PREVIOUS_LINE,$OLD_PLACE]=$BOARD_SYMBOL
	BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BOARD_SYMBOL
	BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+1))]=$BOARD_SYMBOL

	if
	[ ${BOARD[$1,$PLACE]} = $BLOCK_SYMBOL ] ||
	[ ${BOARD[$1,$((PLACE+1))]} = $BLOCK_SYMBOL ]; then
	{
		ON_BOTTOM=1
		CheckIfLoser "$1"
		# Draw again
		BOARD[$PREVIOUS_LINE,$OLD_PLACE]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE,$((OLD_PLACE+1))]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE_2,$((OLD_PLACE+1))]=$BLOCK_SYMBOL
	}
	fi

	if [ $ON_BOTTOM -eq 0 ]; then
	{
		BOARD[$1,$PLACE]=$BLOCK_SYMBOL
		BOARD[$1,$((PLACE+1))]=$BLOCK_SYMBOL
		BOARD[$PREVIOUS_LINE,$((PLACE+1))]=$BLOCK_SYMBOL
	}
	fi
}

function DrawBlock5() {
	checkIfFirstAppearance "0"

	OLD_PLACE=$PLACE
	MoveBlock "1"

	PREVIOUS_LINE=$(($1 - 1))

	if
	[ ${BOARD[$1,$PLACE]} = $BLOCK_SYMBOL ]; then
	{
		ON_BOTTOM=1
		CheckIfLoser "$1"
	}
	fi

	if [ $ON_BOTTOM -eq 0 ]; then
	{
		# Clear
		BOARD[$PREVIOUS_LINE,$OLD_PLACE]=$BOARD_SYMBOL

		# Draw
		BOARD[$1,$PLACE]=$BLOCK_SYMBOL
	}
	fi
}

function DrawScore() {
	echo -e "${RED}----------------------------${NC}"
	echo -e "${RED}TETRIS GAME${NC}"
	echo -e "${RED}----------------------------${NC}"
	echo -e "${CYAN}SCORE:  ${GREEN}$SCORE${NC}"
	echo -e "${RED}----------------------------${NC}"
}

CreateBoard

while true; do
{

	if [ $GAME -eq 1 ]; then
	{

		LEFT=0
		RIGHT=0

		# Non blocking readings of key presses
		stty -icanon -echo time 0 min 0
	  KEY=$(dd bs=1 count=1 2>/dev/null)
		TMP=$(dd 2>/dev/null)

		if [ "$KEY" = "a" ]; then
		{
			LEFT=1
		}
		fi

		if [ "$KEY" = "d" ]; then
		{
			RIGHT=1
		}
		fi

		TIMESTART=`echo $(($(date +%s%N)/1000000))`

		if [ $ACCUMULATOR -gt $FRAMELENGTH ]; then
		{
			clear
			DrawScore
			DrawBlocks "$ACTUAL_LINE"
			GenerateBoard
			ACCUMULATOR=0
			ACTUAL_LINE=$((ACTUAL_LINE + 1))

			if [ $ON_BOTTOM -eq 1 ] || [ $ACTUAL_LINE -gt $((ROWS - 1)) ]; then
			{
				CheckIfFullLine
				ACTUAL_LINE=0
				FIRST_APPEARANCE=1
				ON_BOTTOM=1
				SCORE=$((SCORE + 10))
			}
			fi
		}
		fi
		TIMEEND=`echo $(($(date +%s%N)/1000000))`
		TIMEPASSED=$(($TIMEEND - $TIMESTART))
		ACCUMULATOR=$((ACCUMULATOR + TIMEPASSED))
	} else
	{
		break
	}
	fi
}
done

clear
stty sane
echo -e "${RED}GAME OVER${NC}"
echo -e "${RED}Your score: $SCORE ${NC}"
