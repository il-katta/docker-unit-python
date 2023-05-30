FROM docker.io/nginx/unit:1.29.1-python3.11

ENV GDAL_VERSION 3.6.4

RUN set -x && \
    apt-get -qq update && \
    apt-get -y install \
      nginx \
      # gdal build - removed: libexpat1-dev liblzma-dev libpq-dev ( for psycopg2 )
      cmake libjsoncpp-dev libgeos-dev libhdf4-dev libhdf5-dev libopencl-clang-dev libgeotiff-dev libzstd-dev \
      binutils libproj-dev \
      # python-magic
      libmagic1 \
      && \
    pip install --no-cache-dir -U setuptools && \
    mkdir -p /usr/local/libgdal && \
    curl -sL https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz | tar xz -C /usr/local/libgdal --strip-components=1 && \
    cd /usr/local/libgdal && \
    mkdir -p build && cd build && cmake -DCMAKE_PREFIX_PATH=/usr -DCMAKE_BUILD_TYPE=Release .. && \
    #./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install && \
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && ldconfig && \
    cd / && rm -rf /usr/local/libgdal && \
    apt-get -y --purge autoremove cmake libjsoncpp-dev libgeos-dev libhdf4-dev libhdf5-dev libopencl-clang-dev libgeotiff-dev libzstd-dev && \
    apt-get -y install \
        # libjsoncpp-dev
        libjsoncpp24 \
        # libgeos-dev
        libgeos-3.9.0 libgeos-c1v5 \
        # libhdf4-dev
        libhdf4-0 \
        # libhdf5-dev
        libhdf5-hl-100 \
        # libopencl-clang-dev
        libopencl-clang11 \
        # libgeotiff-dev 
        libgeotiff5 \
        # libproj-dev 
        libproj19 proj-data \
        && \
    pip install --no-cache-dir -U gdal==$GDAL_VERSION && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENV CPLUS_INCLUDE_PATH /usr/local/include/
ENV C_INCLUDE_PATH /usr/local/include/

ADD test.py /tmp/test.py

RUN python /tmp/test.py
