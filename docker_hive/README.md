README
==
## Abstract
This document is a procedure for building an environment where you can run Hive by trial. The main OSS I've used and its version are:
 * CentOS 8
 * Open JDK 1.8
 * [Hadoop 3.2.1][1]
 * [Hive 3.1.2][2]
 * MariaDB 10.3  (for Hive metastore)
 * [MySQL Connector/J 8.0.x (JDBC)][3]

   [1]:https://hadoop.apache.org/releases.html
   [2]:https://hive.apache.org/index.html
   [3]:https://dev.mysql.com/downloads/connector/j/

## Directories and Files

```
./docker_hive
├── README.md               ... This document
│
├── Dockerfile.hive         ... Dockerfile
│
├── config                  ... Contains the configuration file to deploy.
│
├── downloaded              ... Place the downloaded OSS in this directory.
│   ├── hadoop-3.2.1.tar.gz
│   ├── apache-hive-3.1.2-bin.tar.gz
│   └── mysql-connector-java-8.0.x.jar
│
├── patch                   ... Contains bug-fixing patch files.
│
├── sqls                    ... Contains SQL files for use in setup.
│
├── init_scripts            ... Contains script files for setup.
│
├── cleanup_scripts         ... Contains script files for cleanup.
│   
└── tools                   ... Contains useful script files.
    ├── start_hadoop.sh     ... Start Hadoop services.
    ├── stop_hadoop.sh      ... Stop all Hadoop services.
    ├── start_hiveserver.sh ... Start Hive servers.
    └── stop_hiveserver.sh  ... Stop Hive servers.
```

## Users
Following the instructions to create the container will create the following users:
* root
* docker  
   - a general user
   - ssh connection available (the password is the same as user name)
   - sudo available
* hadoop  
   - the Hadoop/Hive services execution user
   - ssh connection available (the password is the same as user name)
   - sudo available
* mysql  
   - the MariaDB service execution user

## Preparation:

* Install Docker and learn how to use for yourself.
* Clone this repository on your pc.

## Step1: Download the installation package
Please download the following and copy it to docker_hive/downloaded

* hadoop-3.2.1.tar.gz  
  URL: https://hadoop.apache.org/releases.html

* apache-hive-3.1.2-bin.tar.gz  
  URL: https://hive.apache.org/index.html

* mysql-connector-java-8.0.x.jar  
  URL: https://dev.mysql.com/downloads/connector/j/  
  Remarks: You can find it in the unzipped archive file you downloaded.

## Step2: Build Docker Images

  Build the Docker Image:
```
  % pwd
    docker_hive
  % docker build --rm -t <repository name> -f Dockerfile.hive .
```

　Check the created Docker image:
```
  % docker images
```

## Step3: Run Docker Container

  Create Docker container from a docker image:
```
  % docker run -d --privileged -h <host name of container> \
    --name <container name> \
    -p <SSH Port>:22 \
    -p <Hadoop Master NameNode(HTTP) Port>:9870 \
    <repository name[:tag]>

  example:
  % docker run -d --privileged -h hivetrial \
    --name hadoop01 \
    -p 10022:22 \
    -p 9870:9870 \
    hive:latest
```
  Remarks about -p option:
  The -p option is the port forwarding setting between the host os and container.
  The format is :
```
  -p <host os port number>:<continue port number>
```

## Step4: Login to running container
　Method 1. use docker command
```
  % docker exec -it <container name or container id> bash
```

  Method 2. use ssh
```
  % ssh hadoop@localhost -p <SSH port>

  example:
  % ssh hadoop@localhost -p 2222
```

## Step5: Database initialization for metastore
```
  % whoami
    hadoop

  % cd
  % pwd
    /home/hadoop

  % cd init_scripts
  % ./01_init_metastore.sh
```

## Step6: Start Hadoop
Following Step 5, execute the following.
```
  % pwd
    /home/hadoop/init_scripts

  % ./02_init_hadoop.sh
```
Confirmation：
```
  example:

  % jps
    1059 SecondaryNameNode
    851 DataNode
    742 NameNode
    1960 Jps
    1325 ResourceManager
    1438 NodeManager
```

## Step7: Start Hive Servers
Following Step 6, execute the following.
```
  % /home/hadoop/tools/start_hiveserver.sh
```
Remarks:  
There are some error messages, but there is no problem. (Under investigation on solution)

## Step8: Check
For Hive CLI:
```
  % hive  

  (Remarks: There are some error messages, but no problem)
  hive>

  hive> show databases;
  (response...)
  OK
  default
  Time taken: 0.102 seconds, Fetched: 1 row(s)

  (ctrl+c for exit)

  ```

  For Beeline:
  ```
  % beeline
  (response...)
  Beeline version 3.1.2 by Apache Hive

  beeline> !connect jdbc:hive2://localhost:10000
  (response...)
  Connecting to jdbc:hive2://localhost:10000
  Enter username for jdbc:hive2://localhost:10000: hive  <-type "hive"
  Enter password for jdbc:hive2://localhost:10000: ****  <-type "hive"

  (response...)
  Connected to: Apache Hive (version 3.1.2)
  Driver: Hive JDBC (version 3.1.2)
  Transaction isolation: TRANSACTION_REPEATABLE_READ
  0: jdbc:hive2://localhost:10000>

  0: jdbc:hive2://localhost:10000> show databases;
  (response...)
  INFO  : Compiling command(queryId=hadoop_20200501050818_0e320d4e-98fc-4aab-9adc-a2222848d888): show databases
  INFO  : Concurrency mode is disabled, not creating a lock manager
  INFO  : Semantic Analysis Completed (retrial = false)
  INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:database_name, type:string, comment:from deserializer)], properties:null)
  INFO  : Completed compiling command(queryId=hadoop_20200501050818_0e320d4e-98fc-4aab-9adc-a2222848d888); Time taken: 0.092 seconds
  INFO  : Concurrency mode is disabled, not creating a lock manager
  INFO  : Executing command(queryId=hadoop_20200501050818_0e320d4e-98fc-4aab-9adc-a2222848d888): show databases
  INFO  : Starting task [Stage-0:DDL] in serial mode
  INFO  : Completed executing command(queryId=hadoop_20200501050818_0e320d4e-98fc-4aab-9adc-a2222848d888); Time taken: 0.021 seconds
  INFO  : OK
  INFO  : Concurrency mode is disabled, not creating a lock manager
  +----------------+
  | database_name  |
  +----------------+
  | default        |
  +----------------+
  1 row selected (0.328 seconds)
  0: jdbc:hive2://localhost:10000>

  (ctrl+c for exit)
```
