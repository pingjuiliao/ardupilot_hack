SITL=../ardupilot/Tools/autotest/sim_vehicle.py
ELF=../ardupilot/build/sitl/bin/arducopter

all: run
run:
	$(SITL) -v ArduCopter -N --vehicle-binary=$(ELF) --map --console
clean:
	rm $(wildcard trace.txt) $(wildcard mav*) $(wildcard *.bin)
	rm -rf $(wildcard terrain)
