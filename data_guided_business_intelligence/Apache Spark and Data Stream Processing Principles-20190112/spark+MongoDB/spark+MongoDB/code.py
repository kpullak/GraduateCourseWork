
# Import libraries
from pyspark import SparkContext, SparkConf
import json
from pyspark.sql.types import *
from pyspark.sql import SparkSession

# Create SparkSession
spark = SparkSession \
    .builder \
    .appName("Streamer") \
    .getOrCreate()

# Create SparkContext
sc = spark.sparkContext

# Import textfile and do word count
text_file = sc.textFile("./install-check/spark/textFile")
counts = text_file.flatMap(lambda line: line.split(" ")) \
             .map(lambda word: (word, 1)) \
             .reduceByKey(lambda a, b: a + b)

# Save result to output
counts.saveAsTextFile("./install-check/spark/output")

# Write to MongoDB
data = spark.read.json(counts)
data.write.format("com.mongodb.spark.sql.DefaultSource").mode("append").save()
data.show()
