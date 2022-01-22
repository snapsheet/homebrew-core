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

RUN sudo chown -R ${USER_NAME} /home/linuxbrew/.linuxbrew

# install RVM gpg key
RUN sudo apt-get update \
  && sudo apt-get install -y \
    dirmngr \
    build-essential \
    cmake \
  && curl -sSL https://rvm.io/mpapis.asc | gpg --import -

USER dev.user

# Install RVM in user space, as most would.
RUN bash --login -c "curl -sSL https://get.rvm.io | bash \
                    && source $HOME/.rvm/scripts/rvm \
                    && rvm install 3.0.0 --default \
                    && rvm install 2.6.6"
