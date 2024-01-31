#!/bin/sh

# Directory where Coursier will fetch the jars
CACHE_DIR="/home/hadoop/.cache/coursier/v1"
# Directory to store all jars flatly
FLAT_LIB_DIR="/home/hadoop/dependencies"

# Create the directory where all jars will be placed
mkdir -p $FLAT_LIB_DIR

# Find all jar files and move them to the flat directory
find $CACHE_DIR -name '*.jar' -exec mv {} $FLAT_LIB_DIR \;

ls $FLAT_LIB_DIR

# Clean up the cache directory
rm -rf $CACHE_DIR