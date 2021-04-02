GCC=/home/itep/kudrov/gcc-9.2.0-install/bin/g++
SRC_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/src
INCLUDE_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/include
OBJ_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/obj
OBJ_FILES=$(OBJ_PATH)/result.o
FLOAT=double
FLAGS=-D DOUBLE

all: get_aver_wilson get_aver_flux

get_aver_wilson: get_aver_wilson.o $(OBJ_FILES)
	$(GCC) get_aver_wilson.o $(OBJ_FILES) -o exe/get_aver_wilson
	rm get_aver_wilson.o
get_aver_wilson.o: get_aver_wilson.cpp
	$(GCC) -O4 -c get_aver_wilson.cpp -I$(INCLUDE_PATH) $(FLAGS) -o get_aver_wilson.o
get_aver_flux: get_aver_flux.o $(OBJ_FILES)
	$(GCC) get_aver_flux.o $(OBJ_FILES) -o exe/get_aver_flux
	rm get_aver_flux.o
get_aver_flux.o: get_aver_flux.cpp
	$(GCC) -O4 -c get_aver_flux.cpp -I$(INCLUDE_PATH) $(FLAGS) -o get_aver_flux.o
