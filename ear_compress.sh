#!/bin/bash

JAR_CMD="$JAVA_HOME/bin/jar"


# Archive contents of a directory to a JAR file
# $1 - Direcory
# $2 - JAR file
compress_jar() {
	local jar_dir="$1"
	local jar_file="$2"

	echo "Compressing contents of directory \"$jar_dir\" to file \"$jar_file\""

	rm -f "$jar_file"

	"$JAR_CMD" cMf "$jar_file" -C "$jar_dir" .
}

# Archive contents of a directory in-place,
# i.e. the contents will be archived to a JAR file with the same name, replacing the original directory
# $1 - Direcory
compress_and_rm_jar() {
	local jar_dir="$1"

	echo "Renaming directory \"$jar_dir\" to \"$jar_dir.tmp\""
	mv "$jar_dir" "$jar_dir.tmp"

	compress_jar "$jar_dir.tmp" "$jar_dir"

	echo "Deleting directory \"$jar_dir.tmp\""
	rm -rf "$jar_dir.tmp"
}


if [ -z "$2" ]; then
	echo "Usage: $0 <directory> <EAR file>"
	exit 1;
fi

ear_dir="${1%/}"
ear_file="$2"

if [ ! -d "$ear_dir" ]; then
	echo "Not a directory: $ear_dir"
	exit 2
fi

# Make a copy of the EAR directory because we will modify its contents
echo "Copying contents of directory \"$ear_dir\" to directory \"$ear_file\""
rm -rf "$ear_file"
cp -pr "$ear_dir" "$ear_file"

# Compress contents of the WAR subdirectories
find "$ear_file" -maxdepth 1 -type d -name '*.war' -print0 | while read -d $'\0' war_dir
do
	compress_and_rm_jar "$war_dir"
done

# Compress contents of the EAR directory
compress_and_rm_jar "$ear_file"
