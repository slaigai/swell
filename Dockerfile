# FROM python:3.9.6-bullseye
ARG BASE_IMAGE=ubuntu:focal-20210416
ARG DEBIAN_FRONTEND=noninteractive

FROM $BASE_IMAGE as prod
ARG PYTHON_VERSION=3.9.6

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	apt-utils \
	git \
	autoconf \
	libtool \
	cmake \
	build-essential \
	zlib1g-dev \
	libssl-dev \
	libbz2-dev \
	libffi-dev \
	liblzma-dev \
	libncursesw5-dev \
	libgdbm-dev \
	libsqlite3-dev \
	libc6-dev \
	tk-dev \
	wget \
	flex \
	bison \
	curl \
	pkg-config

# Set up the ability to run things with libraries in /usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

# Install Python PYTHON_VERSION from source and set as the default Python version
RUN set +x; mkdir /tmp/python && \
	cd /tmp/python && \
	wget --no-check-certificate https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
	tar -xzvf Python-${PYTHON_VERSION}.tgz && \
	cd Python-${PYTHON_VERSION} && \
	./configure --enable-optimizations --enable-shared && \
	make -j8 install && \
	ln -sf /usr/local/bin/python3.9 /usr/bin/python3 && \
	rm -rf /tmp/python

# Switch over to the venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install setuptools
RUN pip3 install --no-cache-dir --upgrade pip setuptools
RUN pip3 install wheel

ENV PYTHONUNBUFFERED=TRUE

WORKDIR /code

CMD ["python", "swell/main.py"]
