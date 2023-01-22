FROM apache/hadoop:3

USER root

# Install requirements libraries
RUN yum update -y \
  && yum install -y \
  gcc \
  make \
  zlib-devel \
  bzip2 \
  bzip2-devel \
  readline-devel \
  sqlite \
  sqlite-devel \
  openssl11 \
  openssl11-devel \
  tk-devel \
  libffi-devel \
  perl-core \
  xz-devel \
  git \
  && exec $SHELL -l

ENV OPENSSLDIR=/usr/local/openssl11
WORKDIR ${OPENSSLDIR}
RUN ln -s /usr/lib64/openssl11 lib \
  && ln -s /usr/include/openssl11 include

# Setup python and pip install requirements libraries
ARG PYTHON_VERSION=3.10.9
ENV HOME=/opt/hadoop
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/bin/:$PATH
ENV JUPYTERLAB_NOTEBOOK_DIR=$HOME/notebook

USER hadoop
WORKDIR $HOME

COPY ./requirements.txt .
RUN curl https://pyenv.run | bash \
  && eval "$(pyenv init -)" \
  && export CONFIGURE_OPTS="-with-openssl=$OPENSSLDIR" \
  && pyenv install $PYTHON_VERSION \
  && pyenv global $PYTHON_VERSION \
  && pyenv rehash \
  && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $HOME/.profile \
  && echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.profile \
  && echo 'eval "$(pyenv init -)"' >> $HOME/.profile \
  && echo 'if [ ! -d $JUPYTERLAB_NOTEBOOK_DIR ]; then mkdir -p $JUPYTERLAB_NOTEBOOK_DIR; fi' >> $HOME/.profile \
  && source $HOME/.profile \
  && python -m pip -V && python -m pip install --upgrade pip \
  && python -m pip install -r requirements.txt

COPY ./exec-jupyter-lab.sh .
RUN sudo chmod +x exec-jupyter-lab.sh

ENTRYPOINT [ "bash", "-c", "./exec-jupyter-lab.sh" ]
