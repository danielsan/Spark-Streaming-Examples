SPARK_SUBMIT=../spark.git/bin/spark-submit
JARS_DIR=jars

MONGO_DRIVER_JAR=$(ls $JARS_DIR/mongo-java-driver*jar)
HADOOP_JAR=$(ls $JARS_DIR/mongo-hadoop-core*.jar)
SPARK_JAR=$(ls $JARS_DIR/mongo-hadoop-spark*jar)

JARS=$MONGO_DRIVER_JAR,$HADOOP_JAR,$SPARK_JAR

PYFILE=$(ls "$1" 2>/dev/null || echo $0 | sed 's/submit.sh/py/')

$SPARK_SUBMIT \
  --driver-class-path $SPARK_JAR \
  --jars $JARS \
  $PYFILE
