FROM ubuntu:16.04

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    language-pack-ja-base \
    language-pack-ja \
    build-essential \
    git \
    libsqlite3-dev \
    libbz2-dev \
    libncurses5-dev \
    libgdbm-dev \
    liblzma-dev \
    libssl-dev \
    tcl-dev \
    tk-dev \
    libreadline-dev \
    libmecab2 \
    libmecab-dev \
    mecab \
    mecab-ipadic \
    mecab-ipadic-utf8 \
    mecab-utils \
    pkg-config \
    libprotobuf9v5 \
    protobuf-compiler \
    libprotobuf-dev \
    libgoogle-perftools-dev \
    autotools-dev \
    automake \
    swig \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    # locale-gen
#RUN update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja

# init

# pyenv
# RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
# ENV HOME /root
# ENV PYENV_ROOT $HOME/.pyenv
# ENV PATH $PYENV_ROOT/bin:$PATH
# RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc && \
    # eval "$(pyenv init -)"
# RUN apt install -y zlib1g-dev libssl-dev libbz2-dev
# RUN pyenv install 3.6.4 && pyenv global 3.6.4 

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

ADD fix-permissions /usr/local/bin/fix-permissions
# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

# Install conda as jovyan and check the md5 sum provided on the download site
ENV MINICONDA_VERSION 4.5.4
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "a946ea1d0c4a642ddf0c3a26a18bb16d *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN conda install --quiet --yes \
    'notebook=5.6.*' \
    'jupyterhub=0.9.*' \
    'jupyterlab=0.34.*' && \
    conda clean -tipsy && \
    jupyter labextension install @jupyterlab/hub-extension@^0.11.0 && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


USER root
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

# mecab
#RUN git clone https://github.com/buruzaemon/natto-py /home/packages/natto-py
#WORKDIR /home/packages/natto-py
#RUN echo "" > README.rst
#RUN /home/.pyenv/shims/python setup.py install
# RUN cat /etc/os-release
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
# RUN ~/.pyenv/shims/python setup.py build_ext && ~/.pyenv/shims/python setup.py install
RUN python setup.py build_ext && python setup.py install


USER $NB_UID

# vim
RUN git clone https://github.com/Arten013/dotfiles $HOME/dotfiles
USER root
WORKDIR $HOME/dotfiles
RUN make
USER $NB_UID
RUN echo "alias vi=nvim" >>  ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc
# pip installs
# RUN ~/.pyenv/shims/python -m pip install -U pip
# RUN ~/.pyenv/shims/python -m pip install gensim editdistance msgpack neo4jrestclient
# RUN ~/.pyenv/shims/python -m pip install mecab-python3 plyvel sklearn neo4j sentencepiece
#--ignore-installed
RUN pip install -U pip
RUN pip install gensim editdistance msgpack neo4jrestclient
RUN pip install mecab-python3 plyvel sklearn neo4j sentencepiece

# jstatutree
RUN git clone https://github.com/Arten013/jstatutree.git $HOME/jstatutree
WORKDIR $HOME/jstatutree
RUN git checkout no_rest
# RUN ~/.pyenv/shims/python setup.py install
RUN python setup.py install

# hjstmodel
RUN git clone https://github.com/Arten013/hjst_model.git $HOME/hjst_model
RUN mkdir -p $HOME/results
WORKDIR $HOME/hjst_model
RUN git checkout develop
RUN ln -s $HOME/results $HOME/hjst_model/results

# abconfig
RUN git clone https://github.com/Arten013/abconfig.git $HOME/abconfig
WORKDIR $HOME/abconfig
RUN git checkout develop
# RUN ~/.pyenv/shims/python setup.py install
RUN python setup.py install
# RUN nvim -c :q

USER root

EXPOSE 8888
WORKDIR $HOME

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
