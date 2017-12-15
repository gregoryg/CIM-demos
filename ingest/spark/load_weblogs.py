from apache import parse_apache_log_line
myfile = (sc.textFile("s3a://gregoryg/datasets/apache2").map(parse_apache_log_line))

mydf = sqlContext.createDataFrame(myfile)

# myfile.count()
mydf.createOrReplaceTempView('weblogs')

spark.sql(
    """select ip, 
              CAST(from_unixtime(unix_timestamp(datetime, 'dd/MMM/yyyy:HH:mm:ss Z')) AS timestamp) AS utc_datetime,
              responsecode,
              clientIdentd AS identd,
              contentsize,
              userid,
              httpinfo,
             useragent
       FROM weblogs
"""
).write.saveAsTable("apache2.weblogs")
