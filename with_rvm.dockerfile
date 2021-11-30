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

# install RVM gpg key
RUN sudo apt-get update \
  && sudo apt-get install -y dirmngr \
  && curl -sSL https://rvm.io/mpapis.asc | gpg --import -

# install RVM's ordered dependencies and repos
RUN sudo apt-get install software-properties-common \
  && sudo apt-add-repository -y ppa:rael-gc/rvm \
  && sudo apt-get update \
  && sudo apt-get install -y libfile-fcntllock-perl

# installing RVM as the user causes the installation to behave differently than installing as root
# install rvm, set the profile, and add to the group
RUN sudo apt-get install -y rvm \
  && sudo usermod -aG rvm ${USER_NAME}  \
  && echo 'source /etc/profile.d/rvm.sh' >> ${USER_HOME}/.bashrc

# install ruby 3.0.0 as default version, and set 2.6.6 as an alternative version
RUN bash -c ". /etc/profile.d/rvm.sh && rvm install 3.0.0 --default && rvm install 2.6.6"
