#!/bin/bash
export PROJECT_GIT_DIR=$(pwd)
echo  "PROJECT_GIT_DIR=$PROJECT_GIT_DIR"
export BASE_DIR=$(dirname $PROJECT_GIT_DIR)
echo  "BASE_DIR=$BASE_DIR"
export JARS_DIR="${PROJECT_GIT_DIR}/jars"
echo  "JARS_DIR=$JARS_DIR"

is_a_git_repo(){
    return "$(git status &> /dev/null && echo 1 || echo 0)"
}

git_remote_url(){
    echo $(git remote -v | head -1 | grep -Po 'git://.+.git')
}

clone_git_repo(){
    local GITHUB_URL=$1    
    local GIT_DIR=$2
    time git clone $GITHUB_URL $GIT_DIR
}

backup_dir(){
    local DIR=$1
    mv $DIR "${DIR}_$(date +'%Y%m%d_%H%M%S')"
}

cd $BASE_DIR

# getting spark from git repo
echo "##### SPARK phase"
export SPARK_GIT_DIR="$BASE_DIR/spark.git"
export SPARK_GITHUB_URL='git://github.com/apache/spark.git'

build_spark_instance(){
    echo "##### Building SPARK instance"
    cd $SPARK_GIT_DIR
    time build/mvn -DskipTests clean package
    echo
}

clone_spark(){
    echo "##### Cloning SPARK"
    clone_git_repo $SPARK_GITHUB_URL $SPARK_GIT_DIR
    build_spark_instance
}

move_curr_dir_and_clone_spark(){
    backup_dir $SPARK_GIT_DIR
    clone_spark
}

if [ ! -d $SPARK_GIT_DIR ] ; then
    # time git clone $SPARK_GITHUB_URL $SPARK_GIT_DIR
    clone_spark
else
    cd $SPARK_GIT_DIR
    if [ ! git status &> /dev/null ]; then
        # mv $SPARK_GIT_DIR "${SPARK_GIT_DIR}_$(date +'%Y%m%d_%H%M%S')"
        # time git clone $SPARK_GITHUB_URL $SPARK_GIT_DIR
        build_spark_instance
    else
        if [ $SPARK_GITHUB_URL != $(git_remote_url) ]; then
            move_curr_dir_and_clone_spark
        else
            git checkout master
            git pull origin master
        fi
    fi
fi


#getting mongodb-hadoop from
echo "######## MongoDB Hadoop Connector phase"
export HADOOPCONN_GIT_DIR=$BASE_DIR/mongodb-hadoop.git
export HADOOPCONN_GITHUB_URL=git://github.com/mongodb/mongo-hadoop.git

build_hadoop_conn_instance(){
    echo "##### Building MongoDB Hadoop Connector JARS"
    cd $HADOOPCONN_GIT_DIR
    time ./gradlew clean jar
    echo
}

patch_hadoop_conn(){
    echo "##### Patching MongoDB Hadoop Connector Project due to a bug"
    patch $HADOOPCONN_GIT_DIR/core/src/main/java/com/mongodb/hadoop/util/MongoConfigUtil.java \
          $PROJECT_GIT_DIR/com_mongodb_hadoop_util_MongoConfigUtil.java.patch
    echo
}

clone_hadoop_conn(){
    echo "##### Cloning MongoDB Hadoop Connector Project"
    clone_git_repo $HADOOPCONN_GITHUB_URL $HADOOPCONN_GIT_DIR
    build_hadoop_conn_instance
}

move_curr_dir_and_clone_hadoop_conn(){
    backup_dir $HADOOPCONN_GIT_DIR
    clone_hadoop_conn
}

if [ ! -d $HADOOPCONN_GIT_DIR ] ; then
    # time git clone $HADOOPCONN_GITHUB_URL $HADOOPCONN_GIT_DIR
    clone_hadoop_conn
else
    cd $HADOOPCONN_GIT_DIR
    if [ ! git status &> /dev/null ]; then
        # mv $HADOOPCONN_GIT_DIR "${HADOOPCONN_GIT_DIR}_$(date +'%Y%m%d_%H%M%S')"
        # time git clone $HADOOPCONN_GITHUB_URL $HADOOPCONN_GIT_DIR
        build_hadoop_conn_instance
    else
        if [ $HADOOPCONN_GITHUB_URL != $(git_remote_url) ]; then
            move_curr_dir_and_clone_hadoop_conn
        else
            git checkout master
            git pull origin master
        fi
    fi
fi

# getting spark from git repo
echo "##### JAVA_DRIVER phase"
export JAVA_DRIVER_GIT_DIR="$BASE_DIR/mongo-java-driver.git"
export JAVA_DRIVER_GITHUB_URL='git://github.com/mongodb/mongo-java-driver.git'

build_java_driver_instance(){
    echo "##### Building JAVA_DRIVER jars"
    cd $JAVA_DRIVER_GIT_DIR
    time ./gradlew clean jar
    echo
}

clone_java_driver(){
    echo "##### Cloning JAVA_DRIVER"
    clone_git_repo $JAVA_DRIVER_GITHUB_URL $JAVA_DRIVER_GIT_DIR
    build_java_driver_instance
}

move_curr_dir_and_clone_java_driver(){
    backup_dir $JAVA_DRIVER_GIT_DIR
    clone_java_driver
}

if [ ! -d $JAVA_DRIVER_GIT_DIR ] ; then
    # time git clone $JAVA_DRIVER_GITHUB_URL $JAVA_DRIVER_GIT_DIR
    clone_java_driver
else
    cd $JAVA_DRIVER_GIT_DIR
    if [ ! git status &> /dev/null ]; then
        # mv $JAVA_DRIVER_GIT_DIR "${JAVA_DRIVER_GIT_DIR}_$(date +'%Y%m%d_%H%M%S')"
        # time git clone $JAVA_DRIVER_GITHUB_URL $JAVA_DRIVER_GIT_DIR
        build_java_driver_instance
    else
        if [ $JAVA_DRIVER_GITHUB_URL != $(git_remote_url) ]; then
            move_curr_dir_and_clone_java_driver
        else
            git checkout master
            git pull origin master
        fi
    fi
fi


# Dependency jars
echo "##### Copying the requred JAR files to the jars directory"
test -d "$JARS_DIR" || mkdir $JARS_DIR

cp -a --no-clobber $(find $HADOOPCONN_GIT_DIR -name mongo-hadoop-core\*.jar ) $JARS_DIR
cp -a --no-clobber $(find $HADOOPCONN_GIT_DIR -name mongo-hadoop-spark\*.jar) $JARS_DIR
cp -a --no-clobber $(find $JAVA_DRIVER_GIT_DIR -name mongo-java-driver\*.jar) $JARS_DIR
# time curl https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongodb-driver/3.1.1/mongodb-driver-3.1.1.jar > jars/mongodb-driver-3.1.1.jar
echo


echo "##### Installing some python Dependency"
time sudo easy_install pytz
echo

echo "##### Done!"
