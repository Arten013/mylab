FROM floydhub/dl-docker:cpu

# init
RUN apt -y update && apt -y upgrade
RUN mkdir -p /root/packages
RUN mkdir -p /root/home
RUN apt -y install language-pack-ja-base language-pack-ja
#RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja

# cmake
WORKDIR /root/packages
RUN wget https://cmake.org/files/v3.12/cmake-3.12.0-rc1.tar.gz
RUN tar xvf cmake-3.12.0-rc1.tar.gz
WORKDIR /root/packages/cmake-3.12.0-rc1
RUN ./bootstrap && make && make install

# leveldb
RUN git clone https://github.com/google/leveldb.git /root/packages/leveldb
WORKDIR /root/packages/leveldb
RUN mkdir -p build
WORKDIR /root/packages/leveldb/build
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build .

# pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    eval "$(pyenv init -)"
RUN pyenv install anaconda3-5.2.0 && pyenv global anaconda3-5.2.0

# mecab
RUN apt install -y libmecab2 libmecab-dev mecab mecab-ipadic mecab-ipadic-utf8 mecab-utils
RUN git clone https://github.com/buruzaemon/natto-py /root/packages/natto-py
WORKDIR /root/packages/natto-py
RUN echo "" > README.rst
RUN /root/.pyenv/shims/python setup.py install

# simstring
RUN apt install -y autotools-dev automake swig
RUN git clone https://github.com/chokkan/simstring /root/packages/simstring
WORKDIR /root/packages/simstring
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/packages/simstring/swig/python
RUN ./prepare.sh --swig
RUN ~/.pyenv/shims/python setup.py build_ext && ~/.pyenv/shims/python setup.py install

# jstatutree
RUN ls
RUN git clone https://github.com/Arten013/jstatutree.git /root/packages/jstatutree
WORKDIR /root/packages/jstatutree
RUN ls
RUN ~/.pyenv/shims/python setup.py install

# hjstmodel
WORKDIR /root/home
RUN git clone https://github.com/Arten013/jstatutree.git /root/home/hjst_model

# pip installs
RUN ~/.pyenv/shims/python -m pip install -U pip
RUN ~/.pyenv/shims/python -m pip install gensim editdistance msgpack neo4jrestclient
#--ignore-installed

# vim
RUN git clone https://github.com/Arten013/dotfiles /root/dotfiles
WORKDIR /root/dotfiles
RUN make
RUN nvim -c :q
RUN echo "alias vi=nvim" >>  ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc

WORKDIR /root/home
