flight start
flight set always on

flight env create spack@bigdata
flight env activate spack@bigdata

spack install hadoop
spack load hadoop

# Configure hadoop
sed -i "s,.*export JAVA_HOME=.*,export JAVA_HOME=$JAVA_HOME,g" $(find ~/.local -iname "hadoop-env.sh")

cat << EOF > $(find ~/.local -iname "core-site.xml")
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

# Start hadoop services
$(find ~/.local -name 'start-dfs.sh')
$(find ~/.local -name 'start-yarn.sh')

# Job
mkdir bigdata-sales-demo
cd bigdata-sales-demo
mkdir inputMapReduce mapreduce_output_sales

wget -O /tmp/hdfiles.zip 'https://drive.google.com/uc?export=download&id=0B_vqvT0ovzHcekp1WkVfUVNEdVE'
unzip -j /tmp/hdfiles.zip

HADOOP_HOME=$(find ~/.local -iname "hadoop-env.sh" |sed 's,/etc/hadoop.*,,g')
cat << EOF > ~/hadoopenv
export CLASSPATH="$(find ~/.local -iname "hadoop-mapreduce-client-core-3.3.0.jar"):$(find ~/.local -iname "hadoop-mapreduce-client-common-3.3.0.jar"):$(find ~/.local -iname "hadoop-common-3.3.0.jar"):~/bigdata-sales-demo/SalesCountry/*:$HADOOP_HOME/lib/*"
EOF

cat << EOF > prepare-data.sh
flight env activate spack
spack load hadoop
source ~/hadoopenv

javac -d . SalesMapper.java SalesCountryReducer.java SalesCountryDriver.java
echo "Main-Class: SalesCountry.SalesCountryDriver" > Manifest.txt
jar cfm ProductSalePerCountry.jar Manifest.txt SalesCountry/*.class

cp SalesJan2009.csv ~/bigdata-sales-demo/inputMapReduce
hdfs dfs -copyFromLocal ~/bigdata-sales-demo/inputMapReduce /
EOF

cat << EOF > run-mapreduce.sh
flight env activate spack
spack load hadoop
source ~/hadoopenv

hadoop jar ProductSalePerCountry.jar /inputMapReduce /mapreduce_output_sales
EOF

cat << EOF > view-data.sh
flight env activate spack
spack load hadoop
source ~/hadoopenv

hdfs dfs -cat /mapreduce_output_sales/part-00000 | more
EOF
