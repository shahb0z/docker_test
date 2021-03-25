FROM centos:centos7.4.1708

COPY hello_world_openMP.c /data/
COPY hello_world_MPI.c /data/

RUN yum -y update
RUN yum -y install vim which wget tar bzip2
RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-7

RUN yum -y install epel-release                
RUN yum -y install libibverbs.x86_64
RUN yum -y install libpsm2-devel.x86_64   
RUN yum -y install opa-fastfabric.x86_64
RUN yum -y install libfabric-devel.x86_64
RUN yum -y install infinipath-psm-devel.x86_64
RUN yum -y install libsysfs.x86_64
RUN yum -y install slurm-pmi-devel.x86_64
RUN yum -y install libffi-devel.x86_64
RUN yum -y install rdma-core-devel.x86_64

ENV PATH=/opt/rh/devtoolset-7/root/usr/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib:${LD_LIBRARY_PATH}

RUN mkdir -p /workdir && cd /workdir
RUN wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz

RUN tar -xf /workdir/openmpi-3.1.4.tar.gz
RUN cd openmpi-3.1.4
ENV FC="gfortran"
ENV CC="gcc"
ENV CFLAGS="-g -O2 -march=core-avx2"
ENV CXXFLAGS="$CFLAGS"
ENV FCFLAGS="-g -O2 -march=core-avx2"
ENV LDFLAGS="-g -O2 -ldl -march=core-avx2"
RUN ./configure --prefix=/opt/openmpi/3.1.4 FC=gfortran CC=gcc  --with-psm2=yes --with-memory-manager=none  --enable-static=yes --with-pmix --with-pmi --with-pmi-libdir="/usr/lib64/" --enable-shared --with-verbs --enable-mpirun-prefix-by-default --disable-dlopen
RUN make -j 8
RUN make install

ENV PATH=/opt/openmpi/3.1.4/bin:${PATH}
ENV LD_LIBRARY_PATH=/opt/openmpi/3.1.4/lib:${LD_LIBRARY_PATH}

RUN which mpicc 
RUN mpicc --version 

RUN cd /data
RUN mpicc -o hello_world_MPI.bin hello_world_MPI.c

ENV MANPATH=/opt/openmpi/3.1.4/share/man:${MANPATH}
ENV INFOPATH=/opt/openmpi/3.1.4/share/info:${INFOPATH}
  
