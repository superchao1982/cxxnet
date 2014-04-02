# set LD_LIBRARY_PATH

export CC  = gcc
export CXX = g++
export NVCC =nvcc
export CAFFE=/home/source/caffe
export CFLAGS = -Wall -O3 -msse4 -Wno-unknown-pragmas -funroll-loops -fopenmp -I../mshadow/ -DMSHADOW_USE_SSE=1 -I$(CAFFE)/include -DCXXNET_ADAPT_CAFFE=1 -DBOOST_NOINLINE='__attribute__ ((noinline))'
export LDFLAGS= -lm -lcudart -lcublas -lmkl_core -lmkl_intel_lp64 -lmkl_intel_thread -liomp5 -lpthread -lcurand -lz -lcaffe -lX11
export NVCCFLAGS = -O3 -ccbin $(CXX)

# specify tensor path
BIN = cxxnet_learner
OBJ = cxxnet_data.o cxxnet_nnet_cpu.o
CUOBJ = cxxnet_nnet_gpu.o
CUBIN =
.PHONY: clean all

all: $(BIN) $(OBJ) $(CUBIN) $(CUOBJ)

cxxnet_nnet_gpu.o: cxxnet/nnet/cxxnet_nnet.cu cxxnet/core/*.hpp cxxnet/core/*.h cxxnet/nnet/*.hpp cxxnet/nnet/*.h
cxxnet_nnet_cpu.o: cxxnet/nnet/cxxnet_nnet.cpp cxxnet/core/*.hpp cxxnet/core/*.h cxxnet/nnet/*.hpp cxxnet/nnet/*.h
cxxnet_data.o: cxxnet/io/cxxnet_data.cpp cxxnet/io/*.hpp cxxnet/utils/cxxnet_io_utils.h
cxxnet_learner: cxxnet/cxxnet_main.cpp cxxnet_data.o cxxnet_nnet_cpu.o cxxnet_nnet_gpu.o

$(BIN) :
	$(CXX) $(CFLAGS) $(LDFLAGS) -o $@ $(filter %.cpp %.o %.c, $^)

$(OBJ) :
	$(CXX) -c $(CFLAGS) -o $@ $(firstword $(filter %.cpp %.c, $^) )

$(CUOBJ) :
	$(NVCC) -c -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" $(filter %.cu, $^)
$(CUBIN) :
	$(NVCC) -o $@ $(NVCCFLAGS) -Xcompiler "$(CFLAGS)" -Xlinker "$(LDFLAGS)" $(filter %.cu %.cpp %.o, $^)

clean:
	$(RM) $(OBJ) $(BIN) $(CUBIN) $(CUOBJ) *~


