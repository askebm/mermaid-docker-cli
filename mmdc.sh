#!/bin/bash
CONTAINER="minlag/mermaid-cli"
shopt -s extglob
# Excempt switches are usually output switches that point to a currrently non existent file
declare -a EXCEMPT_SWITCHES=('-o' '--output')
EXCEMPT_FLAG=0
COMMAND="mmdc"
VOLUMES=""

update_command() {
	local VOL
	local ITEM=$1
	if [[ -e $ITEM ]] || [[ $EXCEMPT_FLAG -eq 1 ]] ; then
		ITEM=$(readlink -m  ${ITEM})
		[[ -e ${ITEM} ]] && VOL=${ITEM} || VOL=$(dirname $ITEM)
		VOLUMES="${VOLUMES} -v ${VOL}:${VOL}"
	fi 
	COMMAND="$COMMAND ${ITEM}"
	EXCEMPT_FLAG=0
}

is_excempt(){
	for i in "${EXCEMPT_SWITCHES[@]}"; do
		[[ "$i" = "$1" ]] && echo 1 && return 1
	done
	echo 0
	return 0
}

while true; do
	case "$1" in
		'--'*)
			EXCEMPT_FLAG=$(is_excempt "$1")
			COMMAND="$COMMAND ${1}"
			shift
			;;
		'-'@([A-Za-z]))
			EXCEMPT_FLAG=$(is_excempt "$1")
			COMMAND="$COMMAND ${1}"
			shift
			;;
		'-'*)
			SWITCH=$(echo "$1" | grep -Eo "^-[A-Za-z]")
			COMMAND="$COMMAND $SWITCH"
			EXCEMPT_FLAG=$(is_excempt "$SWITCH")
			update_command $(echo "${1}" | sed -e 's/^-[A-Za-z]//')
			shift
			;;
		!(-| |))
			update_command "$1"
			shift
			;;
		*)
			break
	esac
done


#echo "$VOLUMES"
#echo "$COMMAND"
docker run -it --rm ${VOLUMES} ${CONTAINER} ${COMMAND}

