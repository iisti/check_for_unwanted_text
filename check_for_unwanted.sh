#!/bin/bash

# Publish private to public

#####################################
##### SCRIPT INIT AND CHECKS
#####################################

path_to_check="$1"

if [ -z "$1" ]
then
    echo "ERROR: No path to check was given!"
    echo "Script usage:"
    echo "./check_for_unwanted.sh <path>"
    exit 1
fi

#####################################
##### FUNCTIONS
#####################################

func_print_arr () {
    # Reference the array correctly (not tmp_array="$1" )
    tmp_array=("$@")
    
    for (( i=0; i<${#tmp_array[@]}; i++ ))
    do
        echo "${tmp_array[$i]}"
    done
}

#####################################
##### SCRIPT MAIN
#####################################

readarray -t arr_unwanted < ./unwanted.txt

# Chech for the unwated patterns and create an arr_all_grep array of the
# results.
readarray -t arr_all_grep <<<"$(
    for (( i=0; i<${#arr_unwanted[@]}; i++ ))
    do
        grep -irI \
            --exclude="check_for_unwanted.sh" \
            --exclude-dir=".git" \
            "${arr_unwanted[$i]}" \
            "$path_to_check"
    done
)"

# If nothing is relevant, one can create exclude_grep.txt file, which errors of lines that are not interesting.
#func_print_arr "${arr_all_grep[@]}" > exclude_grep.txt

# Create an array of the patterns that should be excluded from the comparison.
readarray -t arr_exclude < ./exclude_grep.txt

# Compare if the arr_all_grep has new findings which are not excluded in
# exclude_grep.txt 
arr_diff=()
for i in "${arr_all_grep[@]}"; do
    skip=
    for j in "${arr_exclude[@]}"; do
        [[ $i == "$j" ]] && { skip=1; break; }
    done
    [[ -n $skip ]] || arr_diff+=("$i")
done
#declare -p arr_diff

# Print the differnces
func_print_arr "${arr_diff[@]}" 
