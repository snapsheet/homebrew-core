FROM homebrew/brew

ENV USER_NAME dev.user
ENV USER_HOME /home/${USER_NAME}

USER root

# Create groups and a user to test with.
RUN useradd -ms /bin/bash ${USER_NAME} \
  && usermod -aG sudo ${USER_NAME} \
  && usermod -aG linuxbrew ${USER_NAME} \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL'  | EDITOR='tee -a' visudo

RUN chown -R ${USER_NAME} /home/linuxbrew/.linuxbrew

# Install RVM gpg key.
RUN apt-get update \
  && apt-get install -y \
    dirmngr \
    build-essential \
    cmake \
  && curl -sSL https://rvm.io/mpapis.asc | gpg --import -

# Set up working directory.
ENV APP_HOME ${USER_HOME}/homebrew-core
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}

# Run following commands as user.
USER ${USER_NAME}

RUN brew update && brew upgrade

# Install RVM in user space, as most would.
RUN bash --login -c "curl -sSL https://get.rvm.io | bash \
                    && source $HOME/.rvm/scripts/rvm \
                    && rvm install 3.0.0 --default \
                    && rvm install 2.6.6"
