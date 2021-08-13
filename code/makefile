SRC_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/src
INCLUDE_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/include
OBJ_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/obj
OBJ_FILES=$(OBJ_PATH)/link.o $(OBJ_PATH)/result.o $(OBJ_PATH)/data.o $(OBJ_PATH)/matrix.o $(OBJ_PATH)/basic_observables.o $(OBJ_PATH)/flux_tube.o $(OBJ_PATH)/smearing.o
FLOAT=double
FLAGS=-D DOUBLE
GCC=$(HOME)/gcc-9.2.0-install/bin/g++
MATRIX=abelian

smearing: smearing.o
	$(GCC) smearing.o $(OBJ_FILES) -o exe/smearing_$(MATRIX)
	rm smearing.o
smearing.o: smearing.cpp
	$(GCC) -O4 smearing.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing.o
smearing_dependence: smearing_dependence.o
	$(GCC) smearing_dependence.o $(OBJ_FILES) -o exe/smearing_dependence_$(MATRIX)
	rm smearing_dependence.o
smearing_dependence.o: smearing_dependence.cpp
	$(GCC) -O4 smearing_dependence.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing_dependence.o
