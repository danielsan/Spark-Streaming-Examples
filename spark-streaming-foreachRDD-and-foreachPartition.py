"""
To run
  ./pyspark.submit.sh spark-streaming-foreachRDD-and-foreachPartition.py
"""

from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext

from pymongo import MongoClient

from quiet_logs import quiet_logs

# Documentation
# http://spark.apache.org/docs/latest/streaming-programming-guide.html#design-patterns-for-using-foreachrdd
def sendPartition(partition):
    connection     = MongoClient()
    test_db        = connection.get_database('test')
    wordcount_coll = test_db.get_collection('wordcount_coll')

    for tup in partition:
        word   = tup[0]
        amount = tup[1]
        wordcount_coll.update({"_id": word}, {"$inc": {"count": amount} }, upsert=True)

    connection.close()

if __name__ == "__main__":
    conf = SparkConf().setAppName("using foreachRDD and foreachPartition on RDD")
    sc   = SparkContext(conf=conf)
    ssc  = StreamingContext(sc, 2)
    ssc.checkpoint("checkpoint")

    quiet_logs(sc)

    # Create a DStream that will connect to hostname:port, like localhost:9999
    lines = ssc.socketTextStream('localhost', 9998)
    # lines = ssc.textFileStream('./streamingData')

    # Split each line into words
    words = lines.flatMap(lambda line: line.split(" "))

    # Count each word in each batch
    pairs = words.map(lambda word: (word, 1))

    wordCounts = pairs.reduceByKey(lambda x, y: x + y)

    # http://spark.apache.org/docs/latest/streaming-programming-guide.html#design-patterns-for-using-foreachrdd
    wordCounts.foreachRDD(lambda rdd: rdd.foreachPartition(sendPartition))

    # Print the first ten elements of each RDD generated in this DStream to the console
    wordCounts.pprint()

    ssc.start()             # Start the computation
    ssc.awaitTermination()  # Wait for the computation to terminate
