ARG BUILD_FROM
FROM $BUILD_FROM

ARG TENSORFLOW_VERSION
ARG BAZEL_VERSION
ARG HDF5_VERSION
ENV JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk"

WORKDIR /usr/src
RUN apk add --no-cache \
        freetype libpng libjpeg-turbo musl openblas \
    && apk add --no-cache --virtual=.build-dependencies \
        git cmake curl freetype-dev g++ libjpeg-turbo-dev libpng-dev \
        linux-headers make musl-dev openblas-dev openjdk8 zip patch \
        autoconf automake libtool file sed \
    && curl -SL https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz | tar xzf - \
    && cd /usr/src/hdf5-$HDF5_VERSION \
    && autoreconf -f -i \
    && ./configure --prefix=/usr/local \
    && make \
    && make install \
    && cd /usr/src \
    && rm -rf /usr/src/hdf5-$HDF5_VERSION \
    && curl -SLO https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-dist.zip \
    && mkdir bazel-$BAZEL_VERSION \
    && unzip -qd bazel-$BAZEL_VERSION bazel-$BAZEL_VERSION-dist.zip \
    && cd /usr/src/bazel-$BAZEL_VERSION \
    && ./compile.sh \
    && cp -p output/bazel /usr/bin/ \
    && cd /usr/src \
    && rm -rf /usr/src/bazel-$BAZEL_VERSION \
    && pip3 install --no-cache-dir wheel six numpy \
    && pip3 install --no-cache-dir --no-deps keras_applications==1.0.5 keras_preprocessing==1.0.3 \
    && git clone -b v$TENSORFLOW_VERSION --depth 1 https://github.com/tensorflow/tensorflow \
    && cd /usr/src/tensorflow \
    && sed -i -e '/define TF_GENERATE_BACKTRACE/d' tensorflow/core/platform/default/stacktrace.h \
    && sed -i -e '/define TF_GENERATE_STACKTRACE/d' tensorflow/core/platform/stacktrace_handler.cc \
    && PYTHON_BIN_PATH=/usr/local/bin/python3 PYTHON_LIB_PATH=/usr/local/lib/python3.6/site-packages \
        CC_OPT_FLAGS="-march=native" TF_NEED_JEMALLOC=1 TF_CUDA_CLANG=0 TF_NEED_GCP=0 TF_NEED_HDFS=0 \
        TF_NEED_S3=0 TF_ENABLE_XLA=0 TF_NEED_GDR=0 TF_NEED_VERBS=0 TF_CUDA_CLANG=0 TF_NEED_ROCM=0 \
        TF_NEED_OPENCL_SYCL=0 TF_NEED_OPENCL=0 TF_NEED_CUDA=0 TF_NEED_MPI=0 TF_NEED_IGNITE=0 \
        python3 configure.py \
    && bazel build --config=opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
        //tensorflow/tools/pip_package:build_pip_package \
    && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /usr/src/tensorflow_pkg \
    && cd /usr/src \
    && rm -rf /usr/src/tensorflow \
    && rm -f /usr/bin/bazel \
    && pip3 uninstall -y wheel keras_applications keras_preprocessing \
    && rm -f /usr/src/*.zip \
    && apk del .build-dependencies

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /data
CMD ["/run.sh"]
