
FROM jupyter/all-spark-notebook:spark-3.5.0

ENV SCALA_VERSION=2.12

ENV HADOOP_VERSION=3.3.4

ENV NB_GID=0 

USER root

RUN wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar && \
    wget -P /usr/local/spark/jars/ https://repo.maven.apache.org/maven2/org/apache/spark/spark-hadoop-cloud_${SCALA_VERSION}/${APACHE_SPARK_VERSION}/spark-hadoop-cloud_${SCALA_VERSION}-${APACHE_SPARK_VERSION}.jar && \
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.604/aws-java-sdk-bundle-1.12.604.jar && \
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/org/wildfly/openssl/wildfly-openssl/2.2.5.Final/wildfly-openssl-2.2.5.Final.jar && \
    wget -P /usr/local/spark/jars/ https://github.com/IBM/spark-s3-shuffle/releases/download/v0.9.5/spark-s3-shuffle_2.12-3.4.0_0.9.5.jar && \
    wget -P /usr/local/spark/jars/ https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.1/mariadb-java-client-3.3.1.jar && \
    wget -O - https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -C /usr/lib --strip-components=3 -xz hadoop-${HADOOP_VERSION}/lib/native && \
    mamba install --yes poetry && \
    mamba clean --all -f -y

USER ${NB_UID}

RUN curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > /tmp/cs && \
    chmod u+x /tmp/cs && \
    /tmp/cs setup -y && \
    rm /tmp/cs && \
    ~/.local/share/coursier/bin/cs bootstrap --scala-version ${SCALA_VERSION} almond -o /home/jovyan/almond && \
    /home/jovyan/almond --install --force --log info --metabrowse --extra-classpath "/usr/local/spark/jars/*" --id scala_${SCALA_VERSION} --display-name "Scala ${SCALA_VERSION}" \
      --copy-launcher \
      --arg "java" \
      --arg "--add-opens=java.base/java.lang=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.lang.invoke=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.io=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.net=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.nio=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.util=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED" \
      --arg "--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED" \
      --arg "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED" \
      --arg "--add-opens=java.base/sun.nio.cs=ALL-UNNAMED" \
      --arg "--add-opens=java.base/sun.security.action=ALL-UNNAMED" \
      --arg "--add-opens=java.base/sun.util.calendar=ALL-UNNAMED" \
      --arg "--add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED" \
      --arg "-jar" \
      --arg "/home/jovyan/almond" \
      --arg "--log" \
      --arg "info" \
      --arg "--metabrowse" \
      --arg "--extra-classpath" \
      --arg "/usr/local/spark/jars/*" \
      --arg "--id" \
      --arg "scala_${SCALA_VERSION}" \
      --arg "--display-name" \
      --arg "Scala ${SCALA_VERSION}" && \
    rm -rf /home/jovyan/almond /home/jovyan/.ivy2

USER root

RUN fix-permissions /home/jovyan /opt/conda && chmod g+rwX /usr/local/spark && chown :0 /usr/local/spark

USER 65536

EXPOSE 7777

EXPOSE 2222

EXPOSE 4040

