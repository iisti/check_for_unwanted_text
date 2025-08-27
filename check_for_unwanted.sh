#!/bin/bash

# Check for unwanted text (sensitive data, passwords, etc) from directory that contains text files.

#####################################
##### SCRIPT INIT AND CHECKS
#####################################

datefile=$(date +"%Y-%m-%d_%H-%M-%S")

#####################################
##### FUNCTIONS
#####################################

func_show_help () {
    cmd=$(basename $0)
    echo "Usage: ${cmd} -p <path_to_dir> -u <path_to_file> [-e exclude_list]"
    echo " -h               Show this message"
    echo " -p               <Required> A path to files that should be checked."
    echo " -u unwanted.txt  <Required> A text file which contains lines of unwanted text."
    echo " -e exclude.txt   [Optional] A text file which contains lines that should be excluded from the check."
    echo
    echo "Examples: "
    echo
    echo "# 1st run"
    echo "./${cmd} -p /path/to/dir -u unwanted.txt"
    echo
    echo "# Create exclude list"
    echo "./${cmd} -p /path/to/dir > exclude_your_file.txt"
    echo
    echo "# Run script with exclude list, so that already checked lines don't show up."
    echo "./${cmd} -p /path/to/dir -e exclude_list.txt"
}

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

# Parse options
# Colon : means that the option expects an argument.
while getopts "h?p:u:e:" opt; do
    case "$opt" in
    h|\?)
        func_show_help
        exit 0
        ;;
    p)  path_to_check=$OPTARG
        ;;
    u)  unwanted=$OPTARG
        ;;
    e)  exclude=$OPTARG
        ;;
    esac
done

shift "$((OPTIND-1))"
[[ "${1:-}" = "--" ]] && shift


### START Check that required options
if [[ -z "${path_to_check}" ]]; then
    echo "ERROR: No path to check was provided!"
    echo
    func_show_help
    exit 1;
fi

if [[ -z "${unwanted}" ]]; then
    echo "ERROR: No unwanted text file was provided!"
    echo
    func_show_help
    exit 1;
fi
### END Check required options

readarray -t arr_unwanted < "$unwanted"
#declare -p arr_unwanted

# Extracts repo name from "/tmp/tmp.VeOz9LjtRc/it_admin_tricks_private"
# to "it_admin_tricks_private"
repo_name=$(echo "$path_to_check" | rev | cut -d'/' -f 1 | rev)
path_without_repo=$(echo "$path_to_check" | sed "s|$repo_name||g")

# Chech for the unwated patterns and create an arr_all_grep array of the
# results.
# The sed command remove path to the repository
readarray -t arr_all_grep <<<"$(
    for (( i=0; i<${#arr_unwanted[@]}; i++ ))
    do
        grep -irI \
            --exclude="check_for_unwanted.sh" \
            --exclude-dir=".git" \
            "${arr_unwanted[$i]}" \
            "$path_to_check" \
            | sed "s|^.*$repo_name|$repo_name|g"
    done
)"

if [[ ! -z "${exclude}" ]]; then
    # Create an array of the patterns that should be excluded from the comparison.
    readarray -t arr_exclude < "$exclude"
else
    arr_exclude=()
fi
#declare -p arr_exclude

# Compare if the arr_all_grep has new findings which are not excluded in
# exclude file. 
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
#func_print_arr "${arr_diff[@]}"

# Print and highlight found unwanted text
for (( j=0; j<${#arr_diff[@]}; j++ ))
do
    for (( i=0; i<${#arr_unwanted[@]}; i++ ))
    do
        echo "${arr_diff[$j]}" | grep -i --color \
            --exclude="check_for_unwanted.sh" \
            --exclude-dir=".git" \
            "${arr_unwanted[$i]}"
    done
done