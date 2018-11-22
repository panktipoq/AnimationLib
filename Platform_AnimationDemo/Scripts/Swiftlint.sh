#!/bin/bash

#Path to swiftlint
SWIFT_LINT=${PODS_ROOT}/SwiftLint/swiftlint

#if $SWIFT_LINT >/dev/null 2>&1; then
if [[ -e "${SWIFT_LINT}" ]]; then
    count=0
    for file_path in $(git ls-files -m --exclude-from=.gitignore | grep ".swift$"); do
		if [ -f $file_path ]; then
            export SCRIPT_INPUT_FILE_$count=$file_path
            count=$((count + 1))
		fi
    done

##### Check for modified files in unstaged/Staged area #####
    for file_path in $(git diff --name-only --cached | grep ".swift$"); do
		if [ -f $file_path ]; then
            export SCRIPT_INPUT_FILE_$count=$file_path
            count=$((count + 1))
		fi
    done

##### Make the count avilable as global variable #####
    export SCRIPT_INPUT_FILE_COUNT=$count

    echo "${SCRIPT_INPUT_FILE_COUNT} Lintable files found"

##### Lint files or exit if no files found for lintint #####
    if [ "$count" -ne 0 ]; then
        echo "Autcorrecting..."
        $SWIFT_LINT autocorrect --config $1 --use-script-input-files
        echo "Linting..."
        $SWIFT_LINT lint --config $1 --use-script-input-files
    else
        echo "No files to lint!"
        exit 0
    fi

    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        echo ""
        echo "Swiftlint warnings found. Consider fixing before commit!"
    else
        echo ""
        echo "Swiftlint errors found. Build failed!"
    fi
    exit $RESULT

else
    echo "Swiftlint not installed! Please install Swiftlint"
fi
