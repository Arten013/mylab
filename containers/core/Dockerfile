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
#RUN wget --directory-prefix=/home/packages/ https://github.com/facebookresearch/fastText/archive/v0.1.0.zip
#RUN unzip -d /home/packages /home/packages/v0.1.0.zip
#RUN rm /home/packages/v0.1.0.zip
#WORKDIR /home/packages/fastText-0.1.0
#RUN make
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
