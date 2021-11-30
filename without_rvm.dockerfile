FROM homebrew/brew

ENV USER_NAME dev.user
ENV USER_HOME /home/${USER_NAME}
ENV APP_HOME ${USER_HOME}/homebrew-core

# Create groups and a dev user to test with.
RUN sudo useradd -ms /bin/bash ${USER_NAME} \
  && sudo usermod -aG sudo ${USER_NAME} \
  && sudo usermod -aG linuxbrew ${USER_NAME} \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL'  | sudo EDITOR='tee -a' visudo

# set up user space
USER ${USER_NAME}
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}
