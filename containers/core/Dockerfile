FROM ubuntu:16.04

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    automake \
    autotools-dev \
    build-essential \
    bzip2 \
    ca-certificates \
    fonts-liberation \
    git \
    graphviz \
    language-pack-ja-base \
    language-pack-ja \
    libboost-all-dev \
    libbz2-dev \
    libeigen3-dev \
    libgdbm-dev \ 
    libgoogle-perftools-dev \
    libgsl0-dev \
    libncurses5-dev \
    liblzma-dev \
    libmecab2 \
    libmecab-dev \
    libprotobuf9v5 \
    libprotobuf-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    locales \
    mecab \
    mecab-ipadic \
    mecab-ipadic-utf8 \
    mecab-utils \
    openssh-server \
    protobuf-compiler \
    python3-dev \
    pkg-config \
    sudo \
    swig \
    tcl-dev \
    tk-dev \
    tmux \
    unzip \
    wget \
    openjdk-8-jdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# locale setting
RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL=ja_JP.UTF-8 \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP.UTF-8

# install some basic libraries
RUN mkdir -p /home/packages

# cmake
WORKDIR /home/packages
RUN wget https://cmake.org/files/v3.12/cmake-3.12.0-rc1.tar.gz
RUN tar xvf cmake-3.12.0-rc1.tar.gz
WORKDIR /home/packages/cmake-3.12.0-rc1
RUN ./bootstrap && make && make install

# leveldb
RUN git clone https://github.com/google/leveldb.git /home/packages/leveldb
WORKDIR /home/packages/leveldb
RUN mkdir -p build
WORKDIR /home/packages/leveldb/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build .

#sentencepiece
RUN git clone https://github.com/google/sentencepiece /home/packages/sentencepiece
WORKDIR /home/packages/sentencepiece
RUN mkdir build
WORKDIR /home/packages/sentencepiece/build
RUN cmake ..
RUN make -j $(nproc)
RUN make install
RUN ldconfig -v

# simstring
RUN git clone https://github.com/chokkan/simstring /home/packages/simstring
WORKDIR /home/packages/simstring
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /home/packages/simstring/swig/python
RUN ./prepare.sh --swig

# fasttext
RUN git clone https://github.com/facebookresearch/fastText.git /home/packages/fasttext
RUN mkdir -p /home/packages/fasttext/build
WORKDIR /home/packages/fasttext/build
RUN cmake ..
RUN make && make install

# vim
RUN git clone https://github.com/Arten013/dotfiles /home/dotfiles
WORKDIR /home/dotfiles
RUN pwd
RUN git checkout tmux
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends apt-utils
RUN make
RUN echo "alias vi=nvim" >>  ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc

#nmslib
RUN git clone https://github.com/nmslib/nmslib /home/nmslib
WORKDIR /home/nmslib/similarity_search
RUN cmake . -DWITH_EXTRAS=1 && make
RUN mkdir -p /home/.local/lib

ENV DEBIAN_FRONTEND noninteractive

# HADOOP
ENV HADOOP_VERSION 2.7.3
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HADOOP_HOME/lib/native
RUN wget -q -O- --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | tar -xz -C /opt/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R $LAB_USER:$LAB_GROUP $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.4.2
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /home/spark
RUN mkdir -p /home/spark
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN wget -q -O- --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 \
  "http://mirrors.advancedhosters.com/apache/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | tar xz --strip 1 -C $SPARK_HOME/ \
 && chown -R $LAB_USER:$LAB_UID $SPARK_HOME
