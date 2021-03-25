FROM centos:centos7.4.1708

RUN yum -y update
RUN yum -y install vim which wget tar bzip2
RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-7

RUN yum -y install epel-release 
RUN yum -y install libibverbs.x86_64 libpsm2-devel.x86_64 opa-fastfabric.x86_64 libfabric-devel.x86_64
RUN yum -y install infinipath-psm-devel.x86_64 libsysfs.x86_64 slurm-pmi-devel.x86_64 libffi-devel.x86_64 rdma-core-devel.x86_64

# LOAD GNU 7.3.1
# General environment variables
ENV PATH=/opt/rh/devtoolset-7/root/usr/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib:${LD_LIBRARY_PATH}

RUN gcc --version

#### OpenMPI 3.1.4 installation ########
RUN mkdir -p /workdir && cd /workdir && wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz && tar -xf openmpi-3.1.4.tar.gz
ENV FC="gfortran"
ENV CC="gcc"
ENV CFLAGS="-g -O2 -march=core-avx2"
ENV CXXFLAGS="$CFLAGS"
ENV FCFLAGS="-g -O2 -march=core-avx2"
ENV LDFLAGS="-g -O2 -ldl -march=core-avx2"

RUN cd /workdir/openmpi-3.1.4 && ./configure --prefix=/opt/openmpi/3.1.4 FC=gfortran CC=gcc  --with-psm2=yes --with-memory-manager=none  --enable-static=yes --with-pmix --with-pmi --with-pmi-libdir="/usr/lib64/" --enable-shared --with-verbs --enable-mpirun-prefix-by-default --disable-dlopen && make -j 8 && make install

ENV PATH=/opt/openmpi/3.1.4/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/openmpi/3.1.4/lib:${LD_LIBRARY_PATH}

####### Test the location, version and usage the OpenMPI compiler #######
RUN which mpicc && mpicc --version

RUN mkdir /data
COPY hello_world_MPI.c /data/

RUN cd /data &&  mpicc -o hello_world_MPI.bin hello_world_MPI.c

CMD ["mpirun -np 2 /data/hello_world_MPI.bin"] 
