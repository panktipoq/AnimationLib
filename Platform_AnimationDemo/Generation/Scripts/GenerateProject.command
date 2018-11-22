#!/bin/bash

script_name=$(basename "$0")

# Just print common information.
echo ""
echo "This script should run in folder with gyp file"
echo "Gyp file should containt all targets or gypi includes"
echo "For more information/option call \$ ${script_name} --help"
echo ""

# Help block for parameters.
usage() {
cat << EOF
usage: $0 options

This script generate progect

PARAMETERS:
    --prov_postfix       Should be used to modify provisioning profile postfix. 
                         By dafule, it is ' InHouse'. This will affect on name of provisioning
                         Be defaul it is '<bundle_id> InHouse'. But Jenkins need its oun provisionings

                         $ generateProject.command --prov_postfix <new_postfix>

    --gyp_folder         For project generation we need tool 'gyp'
                         Here should be absolut path or relative to working directory path
                         By default we use ./gyp
                         If no gyp on this path: we will download it

                         $ generateProject.command --gyp_path ../gyp
                         
EOF
}

provisionin_postfix=" InHouse" 
gyp_path="./gyp"

# Parse input parameters.
while test $# -gt 0; do
    echo "param $1"
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;

        --prov_postfix)
            shift
            provisionin_postfix=$1
            shift;;
        --gyp_folder)
            shift
            gyp_path=$1
            shift;;

        *)
            echo "Found unknown param $1"
            break
            ;;
    esac
done

# Check to see if we have GYP; if not we will download it.
if [ -d "${gyp_path}" ]; then
    echo "GYP found. No need to download it"
else
    echo "GYP not found. We will download it..."
    git clone -b poq.ios https://github.com/poqcommerce/Poq.iOS.gyp.git "${gyp_path}"
fi

# Search for GYP Project definition file.
gyp_project_file_path=$(find . -maxdepth 1 -name *.gyp )
gyp_project_file_name=$(basename "$gyp_project_file_path")
project_name="${gyp_project_file_name%.*}"
xcode_actual_version="0821"

echo "Found GYP file: '${gyp_project_file_name}' for project: '${project_name}''"

# First we will remove the existing project.
echo "Remove existing project"
rm -rf "${project_name}.xcodeproj" 2>/dev/null

# Now we will call GYP to generate the specified project.
echo "Start project generation"
echo "Provisioning name postfix: '$provisionin_postfix'"
echo "xcode_actual_version = $xcode_actual_version"

# If there is any output it's likely an error and will be on its own line in red.
echo "------------------------------------------------------------------"
gyp_output=$("${gyp_path}"/gyp ${gyp_project_file_path} --depth=. \
-Gxcode_upgrade_check_project_version=$xcode_actual_version \
-Dprovisioning_name_postfix="$provisionin_postfix"  -Dteam_id="DK34MVSU63"
2>&1);

if [ -d "${project_name}.xcodeproj" ] ; then
    echo "✅  PROJECT GENERATION COMPLETED FOR '${project_name}'"
else
    echo "------------------------------------------------------------------"
    echo "❌  GYP FAILED TO GENERATE PROJECT '${project_name}'"
    echo "## SEE ERROR DIRECTLY ABOVE THIS BLOCK ↑↑↑"
fi

if [ -n "${gyp_output}" ] ; then
    echo "## With output:"
    echo "${gyp_output}"
fi

echo "------------------------------------------------------------------"