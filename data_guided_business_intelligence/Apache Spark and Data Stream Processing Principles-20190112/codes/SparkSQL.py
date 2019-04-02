#---------------Setup SparkSQL-----------------------

#./bin/pyspark creates a sparkContext named as sc.

#SQLContext wraps around a sparkContext.
from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)


#---------------Reading Input Data-----------------------


# Create the DataFrame  -- Note: the schema is automatically inferred from the data !!!
df = sqlContext.read.json("examples/src/main/resources/people.json")

# Show the content of the DataFrame
df.show()

# Print the schema in a tree format
df.printSchema()


#---------------Dataframes - Select, Filter, Aggregate Operations-----------------------


# Select only the "name" column
df.select("name").show()

# Select everybody, but increment the age by 1
df.select(df['name'], df['age'] + 1).show()

# Select people older than 21
df.filter(df['age'] > 21).show()

# Count people by age
df.groupBy("age").count().show()


#---------------Inferring Schema using Reflection-----------------------


#sc is an existing SparkContext.
from pyspark.sql import SQLContext, Row   
sqlContext = SQLContext(sc)

# Load a text file 
lines = sc.textFile("examples/src/main/resources/people.txt")

#Split each line by comma and convert it to a Row.
parts = lines.map(lambda l: l.split(","))
people = parts.map(lambda p: Row(name=p[0], age=int(p[1])))  #<-- Schema was already known

# Infer the schema, and register the DataFrame as a table.
schemaPeople = sqlContext.createDataFrame(people)
schemaPeople.registerTempTable("people")

# SQL can be run over DataFrames that have been registered as a table.
teenagers = sqlContext.sql("SELECT name FROM people WHERE age >= 13 AND age <= 19")

# The results of SQL queries are RDDs and support all the normal RDD operations.
teenNames = teenagers.map(lambda p: "Name: " + p.name)
for teenName in teenNames.collect():
  print(teenName)


#---------------Programmatically Specifying Schema-----------------------


# Import SQLContext and data types
from pyspark.sql import SQLContext
from pyspark.sql.types import *
sqlContext = SQLContext(sc)

# Load a text file and convert each line to a tuple.
lines = sc.textFile("examples/src/main/resources/people.txt")
parts = lines.map(lambda l: l.split(","))
people = parts.map(lambda p: (p[0], p[1].strip()))

# The schema is encoded in a string.
schemaString = "name age"

#Schema: Name(string), Age(string)           # Age is of type string as the type could not be known before
fields = [StructField(field_name, StringType(), True) for field_name in schemaString.split()]
schema = StructType(fields)

# Apply the schema to the RDD.
schemaPeople = sqlContext.createDataFrame(people, schema)

# Register the DataFrame as a table.
schemaPeople.registerTempTable("people")

# SQL can be run over DataFrames that have been registered as a table.
results = sqlContext.sql("SELECT name FROM people")

# The results of SQL queries are RDDs and support all the normal RDD operations.
names = results.map(lambda p: "Name: " + p.name)
for name in names.collect():
  print(name)


#---------------Support for multiple data formats-----------------------


#Reading from a file in json format
df = sqlContext.read.load("examples/src/main/resources/people.json", format="json")

#Writing to a file in parquet format
df.select("name", "age").write.save("namesAndAges.parquet", format="parquet", mode= "overwrite")




