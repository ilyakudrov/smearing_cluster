SRC_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/src
INCLUDE_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/include
OBJ_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/obj
OBJ_FILES=$(OBJ_PATH)/link.o $(OBJ_PATH)/data.o $(OBJ_PATH)/matrix.o $(OBJ_PATH)/basic_observables.o $(OBJ_PATH)/flux_tube.o $(OBJ_PATH)/smearing.o
C_PATH=/home/clusters/rrcmpi/kudrov/general_code/lib/cpu/src/c-lime
C_FILES=$(C_PATH)/lime_fseeko.c  $(C_PATH)/lime_header.c  $(C_PATH)/lime_reader.c  $(C_PATH)/lime_utils.c  $(C_PATH)/lime_writer.c
FLOAT=double
FLAGS=-D DOUBLE -fopenmp
GCC=/home/itep/kudrov/installed/gcc-9/bin/g++
MATRIX=su2
MATRIX_PLAKET=su2
MATRIX_WILSON=su2

all: smearing smearing_dependence_potential smearing_dependence_flux_wilson

smearing: smearing.o
	$(GCC) smearing.o $(OBJ_FILES) $(C_FILES) -o exe/smearing_$(MATRIX)
	rm smearing.o
smearing.o: smearing.cpp
	$(GCC) -O4 smearing.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing.o

smearing_dependence: smearing_dependence.o
	$(GCC) smearing_dependence.o $(OBJ_FILES) -o exe/smearing_dependence_$(MATRIX)
	rm smearing_dependence.o
smearing_dependence.o: smearing_dependence.cpp
	$(GCC) -O4 smearing_dependence.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing_dependence.o

smearing_dependence_potential: smearing_dependence_potential.o
	$(GCC) smearing_dependence_potential.o -fopenmp $(C_FILES) $(OBJ_FILES) -o exe/smearing_dependence_potential_$(MATRIX)
	rm smearing_dependence_potential.o
smearing_dependence_potential.o: smearing_dependence_potential.cpp
	$(GCC) -O4 smearing_dependence_potential.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing_dependence_potential.o

smearing_dependence_flux_wilson: smearing_dependence_flux_wilson.o $(C_FILES)
	$(GCC) smearing_dependence_flux_wilson.o -fopenmp $(OBJ_FILES) $(C_FILES) -o exe/smearing_dependence_flux_wilson_$(MATRIX_PLAKET)_$(MATRIX_WILSON)
	rm smearing_dependence_flux_wilson.o
smearing_dependence_flux_wilson.o: smearing_dependence_flux_wilson.cpp
	$(GCC) -O4 smearing_dependence_flux_wilson.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX_WILSON=$(MATRIX_WILSON) -DMATRIX_PLAKET=$(MATRIX_PLAKET) -o smearing_dependence_flux_wilson.o

smearing_dependence_potential_spatial: smearing_dependence_potential_spatial.o
	$(GCC) smearing_dependence_potential_spatial.o $(OBJ_FILES) -o exe/smearing_dependence_potential_spatial_$(MATRIX)
	rm smearing_dependence_potential_spatial.o
smearing_dependence_potential_spatial.o: smearing_dependence_potential_spatial.cpp
	$(GCC) -O4 smearing_dependence_potential_spatial.cpp $(FLAGS) -c -I$(INCLUDE_PATH) -DMATRIX=$(MATRIX) -o smearing_dependence_potential_spatial.o
