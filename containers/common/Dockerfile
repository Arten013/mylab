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

# add command scripts
ADD fix-permissions /usr/local/bin/fix-permissions

# locale setting
RUN echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL=ja_JP.UTF-8 \
    LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP.UTF-8

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
ENV NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 

RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd

# set password for jovyan
ADD .jovyan_passwd /
RUN chpasswd < /.jovyan_passwd
RUN rm /.jovyan_passwd

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash 
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER
#RUN env
#RUN conda update

RUN mkdir -p $CONDA_DIR && \
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
RUN conda install -y faiss-cpu -c pytorch
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
RUN python setup.py build_ext && python setup.py install

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
RUN git clone https://github.com/Arten013/dotfiles $HOME/dotfiles
WORKDIR $HOME/dotfiles
RUN git checkout tmux
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends apt-utils
RUN make
RUN echo "alias vi=nvim" >>  ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc

#nmslib
USER $NB_UID
RUN git clone https://github.com/nmslib/nmslib $HOME/nmslib
WORKDIR $HOME/nmslib/similarity_search
RUN cmake . -DWITH_EXTRAS=1 && make
WORKDIR $HOME/nmslib/python_bindings
RUN pip install -r requirements.txt
USER root
RUN mkdir -p $HOME/.local/lib
RUN fix-permissions $HOME/.local/lib
USER $NB_UID
RUN python setup.py install

USER $NB_UID

# pip install
ADD requirements.txt $HOME/requirements.txt
RUN pip install -U pip
RUN grep -v '^#' $HOME/requirements.txt | xargs -n 1 -L 1 pip install
RUN pip install /home/packages/fasttext

# setup vim
USER root
RUN mkdir -p $HOME/.local/share
RUN fix-permissions $HOME/.local/share
USER $NB_UID
RUN nvim -c :q 1>/dev/null

CMD /bin/bash
USER $NB_UID
