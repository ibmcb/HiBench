#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$bin/$script"

if [ -z "$HIBENCH_HOME" ]; then
export HIBENCH_HOME=`dirname "$this"`/..
fi

if [ -z "$HIBENCH_CONF" ]; then
export HIBENCH_CONF=${HIBENCH_HOME}/conf
fi

if [ -f "${HIBENCH_CONF}/funcs.sh" ]; then
    . "${HIBENCH_CONF}/funcs.sh"
fi

export HIBENCH_VERSION=$(setvardef DATA_HDFS "2.2")

###################### Global Paths ##################

HADOOP_EXECUTABLE=$(setvardef HADOOP_EXECUTABLE ${HADOOP_HOME}/bin/hadoop)
HADOOP_CONF_DIR=$(setvardef HADOOP_CONF_DIR ${HADOOP_HOME}/conf)
HADOOP_EXAMPLES_JAR=$(setvardef HADOOP_EXAMPLES_JAR ${HADOOP_HOME}/hadoop-examples*.jar)

if [ -z $HADOOP_EXECUTABLE ]; then
HADOOP_EXECUTABLE=`which hadoop`
fi
IFS=':'
for d in `$HADOOP_EXECUTABLE classpath`; do
if [ -z $HADOOP_CONF_DIR ] && [[ $d = */conf ]]; then
HADOOP_CONF_DIR=$d
fi
if [ -z $HADOOP_EXAMPLES_JAR ] && [[ $d = *hadoop-examples*.jar ]]; then
HADOOP_EXAMPLES_JAR=$d
fi
done
unset IFS
#fi

echo HADOOP_EXECUTABLE=${HADOOP_EXECUTABLE:? "ERROR: Please set paths in $this before using HiBench."}
echo HADOOP_CONF_DIR=${HADOOP_CONF_DIR:? "ERROR: Please set paths in $this before using HiBench."}
echo HADOOP_EXAMPLES_JAR=${HADOOP_EXAMPLES_JAR:? "ERROR: Please set paths in $this before using HiBench."}

if $HADOOP_EXECUTABLE version|grep -i -q cdh4; then
HADOOP_VERSION=cdh4
else
HADOOP_VERSION=hadoop1
fi

export HIVE_HOME=$(setvardef HIVE_HOME ${HIBENCH_HOME}/common/hive-0.9.0-bin)

export MAHOUT_HOME=$(setvardef MAHOUT_HOME ${HIBENCH_HOME}/common/mahout-distribution-0.7-$HADOOP_VERSION)

export NUTCH_HOME=$(setvardef NUTCH_HOME ${HIBENCH_HOME}/nutchindexing/nutch-1.2-$HADOOP_VERSION)

export DATATOOLS=$(setvardef DATATOOLS ${HIBENCH_HOME}/common/autogen/dist/datatools.jar)

if [ $# -gt 1 ]
then
if [ "--hadoop_config" = "$1" ]
          then
shift
confdir=$1
              shift
HADOOP_CONF_DIR=$confdir
    fi
fi
HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-$HADOOP_HOME/conf}"

# base dir HDFS
export DATA_HDFS=$(setvardef DATA_HDFS /HiBench)

# local report
export HIBENCH_REPORT=${HIBENCH_HOME}/hibench.report

################# Compress Options #################
# swith on/off compression: 0-off, 1-on
export COMPRESS_GLOBAL=$(setvardef COMPRESS_GLOBAL 1)
export COMPRESS_CODEC_GLOBAL=$(setvardef COMPRESS_CODEC_GLOBAL org.apache.hadoop.io.compress.DefaultCodec)
#export COMPRESS_CODEC_GLOBAL=$(setvardef COMPRESS_CODEC_GLOBAL com.hadoop.compression.lzo.LzoCodec)
#export COMPRESS_CODEC_GLOBAL=$(setvardef COMPRESS_CODEC_GLOBAL org.apache.hadoop.io.compress.SnappyCodec)
