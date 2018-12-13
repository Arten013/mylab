FROM mylab_env

USER root

RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Switch back to jovyan to avoid accidental container runs as root
EXPOSE 22

ADD ./entrypoint.sh /home/entrypoint.sh
run fix-permissions /home/entrypoint.sh
run chmod 750 /home/entrypoint.sh

USER $NB_UID
WORKDIR $HOME
CMD ["/home/entrypoint.sh"]
USER $NB_UID
