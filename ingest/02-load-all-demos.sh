#!/bin/bash
USERDIR='/user/gregj/'
## This script does the following:
##  1. Set up external raw S3 and optimized local Hive tables for Hive Benchmark dataset
##  2. Do the same for the Utility data set
##  3. Set up Data Journey demo (retail dataset)
echo Setting up Bay Area Bikeshare
impala-shell --var=USERDIR=${USERDIR} -f 99-setup-bay-area-bicycle-share.sql

echo Setting up Hive Benchmark data sets
impala-shell --var=USERDIR=${USERDIR} -f 99-setup-hive-benchmark.sql

echo Setting up the Utility data sets
impala-shell --var=USERDIR=${USERDIR} -f 99-setup-utility.sql

echo Setting up the Data Journey data sets

echo "CREATE DATABASE IF NOT EXISTS retailer LOCATION 's3a://gregoryg/database/retailer/';" | tee impala/99-setup-data-journey.sql
for i in `hdfs dfs -ls -R s3a://gregoryg/database/retailer/|grep parq|tr -s ' '|cut -d' ' -f8`
do
    dirpath=`echo $i | sed 's,[^/]\+parq$,,'`
    tablename=`basename $dirpath`
    echo "CREATE EXTERNAL TABLE IF NOT EXISTS retailer.$tablename LIKE PARQUET '"$i"' STORED AS PARQUET LOCATION '"$dirpath"';" | tee -a impala/99-setup-data-journey.sql
done
impala-shell -f impala/99-setup-data-journey.sql
# echo Setting up Observations and Permutations data sets
# impala-shell --var=USERDIR=${USERDIR} -f 99-setup-impala-problem.sql
