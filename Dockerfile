FROM centos:7.6.1810

LABEL description="python development environment for CERN ROOT framework"

ARG ROOT_TAR="root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz"
ARG ANACONDA2_INSTALLER="Anaconda2-2018.12-Linux-x86_64.sh"
ARG ROOT_PASSWORD="pass"
ARG GDB_VERSION="8.1"

RUN yum -y update
# install anaconda (jupyter and other useful python packages)
RUN curl -o anaconda_installer.sh https://repo.anaconda.com/archive/${ANACONDA2_INSTALLER}
# install without user intervention (-b) and remove script
# we need to install bzip2 to run the install script
RUN yum -y install bzip2
RUN bash anaconda_installer.sh -b && rm anaconda_installer.sh
ENV PATH="/root/anaconda2/bin/:${PATH}"
# install metakernel package for ROOT C++ kernel
RUN pip install metakernel

# install root prerequisites (https://root.cern.ch/build-prerequisites#fedora)
RUN yum -y install git cmake gcc-c++ gcc binutils \
libX11-devel libXpm-devel libXft-devel libXext-devel
# install optional prerequisites
RUN yum -y install gcc-gfortran openssl-devel pcre-devel \
mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
fftw-devel cfitsio-devel graphviz-devel \
avahi-compat-libdns_sd-devel libldap-dev python-devel \
libxml2-devel gsl-static
# in order to display images in notebook mode we discovered we needed to install 'giflib'
# "yum whatprovides '*/libgif.so.4'" where libgif keyword was found in an error in the jupyter notebook prompt
RUN yum -y install giflib

RUN curl -o /tmp/root.tar.gz https://root.cern/download/${ROOT_TAR}
RUN tar xzf /tmp/root.tar.gz -C /opt && rm -rf /tmp/root.tar.gz
# (optional) put thisroot.sh initaition script in bashrc
RUN echo 'source /opt/root/bin/thisroot.sh' >> ~/.bashrc
# declare root enviroment variables from '/opt/root/bin/thisroot.sh'
ENV ROOTSYS "/opt/root"
ENV PATH "${ROOTSYS}/bin:${PATH}"
ENV LD_LIBRARY_PATH "${ROOTSYS}/lib:${LD_LIBRARY_PATH}"
ENV PYTHONPATH "${ROOTSYS}/lib:${PYTHONPATH}"
# root will be installed to /opt/root (ROOTSYS)

# enable ssh and set root password to "pass"
RUN yum install -y sudo openssh-server openssh-clients
RUN echo root:${ROOT_PASSWORD} | chpasswd
# enable x11 forwarding
RUN yum install -y xauth
RUN echo "X11Forwarding yes" >> /etc/ssh/sshd_config
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
# generate empty keys (needed)
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

# configuration to use as remote IDE build tool
RUN yum install -y epel-release
RUN yum groupinstall -y "Development Tools"
RUN yum install -y cmake3
# remove cmake if installed
RUN yum remove -y cmake
RUN ln -s /usr/bin/cmake3 /usr/bin/cmake
# install gdb 8.1 > 7.8
RUN yum remove -y gdb
RUN curl -o gdb.tar.xz http://ftp.gnu.org/gnu/gdb/gdb-${GDB_VERSION}.tar.xz
RUN tar xf gdb.tar.xz -C /opt && rm -f gdb.tar.xz
RUN ./opt/gdb-${GDB_VERSION}/configure --with-python
RUN make
RUN yum install -y texi2html texinfo 
RUN make install

# clear yum cache
RUN yum -y clean all

# create startup script
RUN mkdir ~/bin
RUN echo -e "source /opt/root/bin/thisroot.sh\njupyter notebook --port=8888 --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''" > ~/bin/startup_script.sh
RUN chmod +x ~/bin/startup_script.sh

WORKDIR /home/notebooks

EXPOSE 8888 22

CMD . ~/bin/startup_script.sh
