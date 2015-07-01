#!/bin/bash

JAR_CMD="$JAVA_HOME/bin/jar"


# Extract contents of a JAR file to a directory
# $1 - JAR file
# $2 - Directory
extract_jar() {
	local jar_file="$1"
	local jar_file_basename=$(basename "$jar_file")
	local jar_dir="$2"

	echo "Extracting contents of file \"$jar_file\" to directory \"$jar_dir\""

	rm -rf "$jar_dir"
	mkdir "$jar_dir"

	cp "$jar_file" "$jar_dir"
	pushd "$jar_dir" > /dev/null
	"$JAR_CMD" xf "$jar_file_basename"
	rm "$jar_file_basename"
	popd > /dev/null
}

# Extract contents of a JAR file in-place,
# i.e. the contents will be extracted to a directory with the same name, replacing the original file
# $1 - JAR file
extract_and_rm_jar() {
	local jar_file="$1"

	echo "Renaming file \"$jar_file\" to \"$jar_file.tmp\""
	mv "$jar_file" "$jar_file.tmp"

	extract_jar "$jar_file.tmp" "$jar_file"

	echo "Deleting file \"$jar_file.tmp\""
	rm "$jar_file.tmp"
}


if [ -z "$2" ]; then
	echo "Usage: $0 <EAR file> <directory>"
	exit 1;
fi

ear_file="$1"
ear_dir="${2%/}"

if [ ! -f "$ear_file" ]; then
	echo "Not a file: $ear_file"
	exit 2
fi

# Extract contents of the EAR file
extract_jar "$ear_file" "$ear_dir"

# Extract contents of the WAR files
find "$ear_dir" -maxdepth 1 -type f -name '*.war' -print0 | while read -d $'\0' war_file
do
	extract_and_rm_jar "$war_file"
done
