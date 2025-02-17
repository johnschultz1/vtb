# Start from the Alpine base image
FROM ubuntu:24.10

# Set the HOME environment variable
ENV USER='vtbUser'
ENV HOME=/home/${USER}/
# Create the user
RUN groupadd ${USER} \
    && useradd -g ${USER} -m ${USER} -s /bin/bash \
    && apt-get update \
    && apt-get install --no-install-recommends -y sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}
# Set the working directory to the user's home directory
WORKDIR $HOME
# location to VTB
ENV VTBHOME="/usr/local/vtb/"
# option to set project dir in container
RUN mkdir /VTB_PROJECTS/
RUN chmod 777 /VTB_PROJECTS

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get install --no-install-recommends -y \
                        autoconf \
                        bc \
                        bison \
                        build-essential \
                        ca-certificates \
                        ccache \
                        clang \
                        cmake \
                        flex \
                        gdb \
                        git \
                        gtkwave \
                        help2man \
                        libfl2 \
                        libfl-dev \
                        libgoogle-perftools-dev \
                        libsystemc \
                        libsystemc-dev \
                        numactl \
                        perl \
                        python3 \
                        wget \
                        z3 \
                        zlib1g \
                        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone and build slang
RUN git clone https://github.com/MikePopoloski/slang.git /usr/local/slang
RUN cd /usr/local/slang/ && git checkout v7.0 && mkdir build && cd build \
    && cmake .. \
    && make \
    && make install

# Clone and build verilator
RUN git clone https://github.com/verilator/verilator.git /usr/local/verilator
RUN cd /usr/local/verilator && git checkout v5.030-45-g2cb1a8de7 \
    && autoconf \
    && ./configure \
    && make

# Copy the rest of the Go application
COPY . /usr/local/vtb/

# update path
ENV PATH="/usr/local/slang/build/bin:${PATH}"
ENV PATH="/usr/local/verilator/bin:${PATH}"

USER $USER

# command to start your application
ENTRYPOINT ["/usr/local/vtb/entry.sh"]