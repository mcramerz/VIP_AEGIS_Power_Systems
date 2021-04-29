# VIP_AEGIS_Power_Systems
Above are the 3 files needed to run a simulation in GRIDLAB-D. The csv file is an output from BEAM that has vehicle position data or each vehicle updated every second.
The MATLAB scipt will take this csv file and use it to create 60 different PLAYER files that will be used to tell each charger when to turn on and off.
After the PLAYER files are created, the GLM file can be run in the GRIDLAB-D terminal using the "gridlabd" command followed by the file name (ex:load_35).
GRIDLAB-D will then create a CSV file for each charger in the system along with each node (see diagram of system for difference between chargers and nodes) that will contain
the voltage, current, and power at each node for each second of the simulation.
