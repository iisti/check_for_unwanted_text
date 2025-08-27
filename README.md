# Check for unwanted text

A script for checking if there's unwanted text in a directory's subdirectories/files.

Check usage with:

~~~sh
./check_for_unwanted.sh -h
~~~

## Example usage: copy/publish a private GitHub repository without history

1. Clone fresh copy of private repository and check for unwanted text

    ~~~sh
    tmp=$(mktemp -d)
    cd $tmp
    git clone git@github.com:iisti/it_admin_tricks_private.git
    ~~~

1. Check for unwanted text

    ~~~sh
    cd check_for_unwanted_text
    ./check_for_unwanted.sh -p /tmp/tmp.h5I1nfiPy6/it_admin_tricks_private -u unwanted.txt
    ~~~

1. Fix issues
1. Clone public repository and remove everything else than .git

    ~~~sh
    cd $tmp
    git clone git@github.com:iisti/it_admin_tricks.git
    cd it_admin_tricks
    # Remove everything else except .git folder
    find . -maxdepth 1 ! -name .git -type d -not -path '.' -exec rm -rf {} +
    ~~~

1. Copy files and folders from private to public

    ~~~ssh
    cd ../it_admin_tricks_private
    find . -maxdepth 1 ! -name .git -type d -not -path '.' -exec cp -r {} ../it_admin_tricks/ \;
    ~~~

1. Add changes, make commit and push

    ~~~sh
    cd ../it_admin_tricks
    git add . && git commit -m "update from private repo" && git push
    ~~~

## GitHub remove history

* One file <https://github.com/iisti/it_admin_tricks/blob/main/git/github_admin_tricks.md#remove-a-file-and-its-commit-history-from-a-repository>
* All history of repository <https://github.com/iisti/it_admin_tricks/blob/main/git/github_admin_tricks.md#remove-all-history-from-repository>
