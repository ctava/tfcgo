FROM ubuntu:16.04

MAINTAINER Chris Tava <chris1tava@gmail.com>

#Begin: install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libcurl3-dev \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        locate \
        pkg-config \
        python-dev \
        rsync \
        software-properties-common \
        sudo \
        unzip \
        zip \
        zlib1g-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        sklearn \
        pandas \
        && \
    python -m ipykernel.kernelspec
#End: install prerequisites

#Begin: install basel
# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/etc/bazel.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.5.2
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
#End: install basel

#Begin: Download and build TensorFlow
RUN git clone https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout r1.2
WORKDIR /tensorflow

ENV CI_BUILD_PYTHON python

RUN tensorflow/tools/ci_build/builds/configured CPU \
    bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
        tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip --no-cache-dir install --upgrade /tmp/pip/tensorflow-*.whl
    #rm -rf /tmp/pip && \
    #rm -rf /root/.cache
#End: Download and build TensorFlow

#Begin: install golang
ENV GOLANG_VERSION 1.8.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_SHA256_CHECKSUM 1862f4c3d3907e59b04a757cfda0ea7aa9ef39274af99a784f5be843c80c6772
ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin:/usr/local/go/bin
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz && \
    echo "$GOLANG_SHA256_CHECKSUM golang.tar.gz" | sha256sum -c - && \
    sudo tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
#End: install golang

#Begin: install tensorflow library
ENV TENSORFLOW_LIB_GZIP libtensorflow-cpu-linux-x86_64-1.2.1.tar.gz
ENV TARGET_DIRECTORY /usr/local
RUN  curl -fsSL "https://storage.googleapis.com/tensorflow/libtensorflow/$TENSORFLOW_LIB_GZIP" -o $TENSORFLOW_LIB_GZIP && \
     tar -C $TARGET_DIRECTORY -xzf $TENSORFLOW_LIB_GZIP && \
     rm -Rf $TENSORFLOW_LIB_GZIP
ENV LD_LIBRARY_PATH $TARGET_DIRECTORY/lib
ENV LIBRARY_PATH $TARGET_DIRECTORY/lib
RUN go get github.com/tensorflow/tensorflow/tensorflow/go
#End: install tensorflow library

#Begin: install protoc
ENV PROTOC_VERSION 3.3.0
ENV PROTOC_LIB_ZIP protoc-$PROTOC_VERSION-linux-x86_64.zip
ENV TARGET_DIRECTORY /usr/local
RUN  curl -fsSL "https://github.com/google/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_LIB_ZIP" -o $PROTOC_LIB_ZIP && \
     sudo unzip $PROTOC_LIB_ZIP -d $TARGET_DIRECTORY && \
     rm -Rf $TPROTOC_LIB_ZIP
#End: install protoc

#Begin: generate go files from protobufs
RUN go get github.com/golang/protobuf/proto
RUN go get github.com/golang/protobuf/protoc-gen-go
ENV TF_DIR /go/src/github.com/tensorflow/tensorflow
ENV TF_PB_DIR /go/src/github.com/tensorflow/tensorflow/tensorflow/go/pb
RUN mkdir -p $TF_PB_DIR
RUN /usr/local/bin/protoc -I $TF_DIR \
  --go_out=$TF_PB_DIR \
  $TF_DIR/tensorflow/core/framework/*.proto
#End: generate go files from protobufs

#Begin: add supplemental tensorflow go files to proper location
ADD ./tensorflow/graphio.go /go/src/github.com/tensorflow/tensorflow/tensorflow/go/graphio.go
#End: add supplemental tensorflow go files to proper location

#Begin: install tfcgo + go-tensorflow files
#RUN go get github.com/asimshankar/go-tensorflow/variable
RUN go get github.com/ctava/tfcgo
#End: install tfcgo + go-tensorflow files

WORKDIR "/go/src/github.com/ctava/tfcgo/examples"
#CMD ["/bin/bash"]
