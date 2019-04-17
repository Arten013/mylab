## NLP実験用のコンテナ (by Kazuya Fujioka)

## SimStringやsentencepieceなど，
## 汚い環境でのインストールが難しいものを入れたもの．
## jupyter notebookのサーバを立てることもできるようになっている．
## jupyter公式のDockerfile (https://github.com/jupyter/docker-stacks)
## をパクって作成しているので，細かい部分は分からないまま使ってる．

# ベースのコンテナ
FROM atbell013/mylab_core

# 権限修正用のスクリプトを追加
ADD fix-permissions /usr/local/bin/fix-permissions

# ユーザの情報を設定ファイルから読み込み
# 基本的に，ホスト側と整合するようにしておけばOK
ARG LAB_USER="jovyan"
ARG LAB_UID=1000
ENV LAB_GROUP="lab_member"
ENV LAB_GID=111

# ユーザ情報の設定
RUN groupadd $LAB_GROUP -g $LAB_GID
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -g $LAB_GROUP -N -u $LAB_UID $LAB_USER && \
    chmod g+w /etc/passwd

# ホームディレクトリ/condaディレクトリの設定
# 環境変数の設定
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$LAB_USER
ENV DOT_LOCAL=/home/.local/

# ディレクトリ作成/権限の修正
RUN mkdir -p $CONDA_DIR && \
    mkdir -p $DOT_LOCAL/share && \
    mkdir -p $DOT_LOCAL/lib
RUN chown $LAB_USER:$LAB_GID $CONDA_DIR  && \
    chown $LAB_USER:$LAB_GID $DOT_LOCAL/share  && \
    chown $LAB_USER:$LAB_GID $DOT_LOCAL/lib
RUN chmod g+w /etc/passwd
RUN fix-permissions $HOME
RUN fix-permissions $CONDA_DIR && \
    fix-permissions $DOT_LOCAL/share && \
    fix-permissions $DOT_LOCAL/lib && \
    fix-permissions /home/nmslib/python_bindings

USER $LAB_UID

# おまじない(todo: 無くても動くかどうかを確認)
# RUN mkdir /home/$LAB_USER/work && \
    # fix-permissions /home/$LAB_USER

# minicondaのインストール
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
    rm -rf /home/$LAB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$LAB_USER

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$LAB_USER

# faissのインストール（なぜこの位置にあるのかは忘れた）
# faissはANNツール by FB
# 高次元でのk-NNを高速に実行したいときに便利
RUN conda install -y faiss-cpu -c pytorch

# Jupyter Notebook, Lab, and Hubのインストール
# notebook server config の生成
# 一括でやっているのは，権限修正が重複して走ってしまうのを防ぐため（らしい）
# 原文: Do all this in a single RUN command to avoid duplicating all of the
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
    rm -rf /home/$LAB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$LAB_USER

# nmslibのPython bindingをインストール
WORKDIR /home/nmslib/python_bindings
RUN pip install -r requirements.txt
RUN python setup.py install

# pip install
ADD requirements.txt $HOME/requirements.txt
RUN pip install -U pip
RUN grep -v '^#' $HOME/requirements.txt | xargs -n 1 -L 1 pip install
RUN pip install /home/packages/fasttext

# SimStringのPython bindingをインストール
User root
RUN fix-permissions /home/packages/simstring
USER $LAB_UID
WORKDIR /home/packages/simstring/swig/python
RUN python setup.py build_ext && python setup.py install

# nvimのプラグイン読み込み
RUN nvim -c :q
#RUN nvim -c :q 1>/dev/null

# ユーザのパスワード設定
ARG ROOT_PASSWORD='password'
ARG LAB_USER_PASSWORD='password'
USER root
RUN echo "root:${ROOT_PASSWORD}\n${LAB_USER}:${LAB_USER_PASSWORD}" | chpasswd

# ユーザをsudoerに
RUN adduser $LAB_USER sudo
WORKDIR /home/$LAB_USER
