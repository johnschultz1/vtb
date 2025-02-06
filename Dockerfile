# Start from the Alpine base image
FROM ubuntu:24.10

# Create the user
RUN groupadd vtbUser \
    && useradd -g vtbUser -m vtbUser -s /bin/bash \
    && apt-get update \
    && apt-get install --no-install-recommends -y sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo vtbUser ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/vtbUser \
    && chmod 0440 /etc/sudoers.d/vtbUser

# Set the HOME environment variable
ENV HOME=/home/vtbUser/

# Set the working directory to the user's home directory
WORKDIR $HOME

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

# Install Go
RUN wget https://dl.google.com/go/go1.23.5.linux-amd64.tar.gz -O go.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

# Set environment variables
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

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

# Set up environment for the Go application
WORKDIR /usr/local/vtb/
COPY go.mod go.sum ./
RUN  go mod download && go mod verify

# Copy the rest of the Go application
COPY . /usr/local/vtb/

# Build the Go application
RUN go build -o /usr/local/vtb/bin/vtb

# update path
ENV PATH="/usr/local/slang/build/bin:${PATH}"
ENV PATH="/usr/local/go/bin:${PATH}"
ENV PATH="/usr/local/vtb/bin:${PATH}"
ENV PATH="/usr/local/verilator/bin:${PATH}"

# location to VTB
ENV VTBHOME="/usr/local/vtb/"
# option to set project dir in container
ENV PROJECTSHOME=${HOME}/vtbUser/VTB_PROJECTS/
ENV PROJECTNAME='newPrj'
# location to Verilator home dir, uncomment and set
ENV VERIHOME='/usr/local/verilator/'
# location to Verilator exe
ENV VERIEXE='${VERIHOME}/bin/verilator'
# options to pass to verilator
ENV VERIOPTS=' --debug --Wno-lint --sv --timing --trace --public --trace-structs '
# includes to pass to verilator
ENV VERIINC=' -I${VERIHOME}/include -I${VTBHOME}/src -I${PROJECTSHOME/$PROJECTNAME}/verif/run/vtb '
# location to Slang exe
ENV SLANGEXE='slang'
# options to pass to slang
ENV SLANGOPTS='--allow-toplevel-iface-ports'

USER vtbUser

# gtk wave viewing exports
#export GTK_MODULES=gail:atk-bridge
#export GTK_PATH=/usr/lib/x86_64-linux-gnu/gtk-2.0/modules
#export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

# command to start your application
ENTRYPOINT ["/usr/local/vtb/bin/vtb"]
