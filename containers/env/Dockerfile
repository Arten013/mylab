FROM mylab_core

# add command scripts
ADD fix-permissions /usr/local/bin/fix-permissions

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
ARG LAB_USER="jovyan" 
ARG LAB_UID=1000
ARG LAB_GROUP='lab_member'
ARG LAB_GID=111

RUN groupadd $LAB_GROUP -g $LAB_GID

ENV NB_USER=$LAB_USER \
    NB_UID=$LAB_UID \
    NB_GROUP=$LAB_GROUP \
    NB_GID=$LAB_GID

RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -g $LAB_GROUP -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd

RUN id $LAB_USER

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash 
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

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

# fix permissions
USER root
RUN mkdir -p /home/.local/lib
RUN fix-permissions /home/.local/lib
RUN chmod 777 -R /home/nmslib/
USER $NB_UID

# pip install nmslib
WORKDIR /home/nmslib/python_bindings
RUN pip install -r requirements.txt
RUN python setup.py install

# pip install
ADD requirements.txt $HOME/requirements.txt
RUN pip install -U pip
RUN grep -v '^#' $HOME/requirements.txt | xargs -n 1 -L 1 pip install
RUN pip install /home/packages/fasttext


# pip install simstring
RUN python setup.py build_ext && python setup.py install

# setup vim
USER root
RUN mkdir -p $HOME/.local/share
RUN fix-permissions $HOME/.local/share
USER $NB_UID
RUN id
RUN env
RUN nvim -c :q 1>/dev/null

# set password for users
USER root
ADD passwords /
RUN chpasswd < /passwords
RUN rm /passwords

RUN adduser $LAB_USER sudo
