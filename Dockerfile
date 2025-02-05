# Start from the Alpine base image
FROM ubuntu:24.10

#USER nobody

# Set the HOME environment variable
ENV HOME=/home/

# Set the working directory to the user's home directory
WORKDIR $HOME

# Set environment variables to avoid prompts from APT during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies needed for fetching and installing packages
RUN apt-get update && apt-get install -y \
    bash \
    build-essential \ 
    linux-headers-generic \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libffi-dev \
    libncurses5-dev \
    libssl-dev \
    libreadline-dev \
    libsqlite3-dev \
    libtk8.6 \ 
    cmake \
    python3 \
    python3-pip \
    git \
    wget \
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

# location to VTB
ENV VTBHOME="/usr/local/vtb/"
# location to Verilator home dir, uncomment and set
ENV VERIHOME=''
# location to Verilator exe
ENV VERIEXE='${VERIHOME}/bin/verilator'
# options to pass to verilator
ENV VERIOPTS=' --debug --Wno-lint --sv --timing --trace --public --trace-structs '
# includes to pass to verilator
ENV VERIINC=' -I${VERIHOME}/include -I${VTBHOME}/src -I${PROJECTDIR}/verif/run/vtb '
# location to Slang exe
ENV SLANGEXE='slang'
# options to pass to slang
ENV SLANGOPTS='--allow-toplevel-iface-ports'
# option to set project dir in container
ENV PROJECTSHOME=${HOME}/VTB_PROJECTS/
ENV PROJECTNAME='newPrj'

# gtk wave viewing exports
#export GTK_MODULES=gail:atk-bridge
#export GTK_PATH=/usr/lib/x86_64-linux-gnu/gtk-2.0/modules
#export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH

# command to start your application
ENTRYPOINT ["/usr/local/vtb/bin/vtb"]
