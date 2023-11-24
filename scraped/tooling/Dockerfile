# Use a base image with necessary build tools
FROM centos:7

ARG version

ENV VERSION $version

WORKDIR /root/rpmbuild

# Install RPM build dependencies
RUN yum install -y \
    rpm-build \
    rpmdevtools \
    && yum clean all

# Set up RPM build environment
RUN rpmdev-setuptree


RUN mkdir -p /tmp/talon-server-$version && \
    mv /opt/executables/talon/talon-server /tmp/talon-server-$version && \
    tar --create --file /opt/executables/talon-server-$version.tar.gz /tmp/talon-server-$version && \
    mv /opt/executables/talon-server-$version.tar.gz /root/rpmbuild/SOURCES/
# Copy your source files to the container
# COPY ./my-app /root/rpmbuild/SOURCES/my-app

COPY executables/talon/talon-server.spec /root/rpmbuild/SPECS/talon-server.spec

# Copy the spec file to the container
# COPY ./my-app.spec /root/rpmbuild/SPECS/my-app.spec

# Set the working directory

# Build the RPM package
# RUN rpmbuild -bb SPECS/my-app.spec

