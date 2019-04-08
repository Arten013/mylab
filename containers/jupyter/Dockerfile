FROM mylab_env

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
ARG JUPYTER_PASS
RUN sed -i -e "/^c.NotebookApp.token=$/s/$/'${JUPYTER_PASS}'/g" /etc/jupyter/jupyter_notebook_config.py
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $LAB_UID
