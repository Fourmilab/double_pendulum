#
#               Demonstration script
#
@echo Fourmilab Double Pendulum demonstrates the
@echo chaotic motion of a a pendulum made of two
@echo linked masses free to rotate in a plane.

script set segment "30"
script pause 2
set scale 2
reset
run {segment}

@echo
@echo Commands give you full control over the model.
@echo Let's increase the mass of the green pendulum
@echo bob.
@echo
reset
set mass 1 150
run {segment}

@echo
@echo Now try it with a larger red bob and green back to
@echo the original mass.
@echo
reset
set mass 1 100
set mass 2 150
run {segment}

@echo
@echo Let's try a configuration with equal masses and a
@echo longer first rod and shorter second rod.
@echo
reset
set length 1 300
set length 2 100
run {segment}

@echo
@echo Turnabout's fair play.  What happens when we flip
@echo the lengths of the two rods?
@echo
reset
set length 1 100
set length 2 300
run {segment}

@echo
@echo Trace path of second bob by drawing temporary
@echo lines with prims.
@echo
reset
set paths lines
run {segment}
set paths off

@echo
@echo Trace path of second bob by dropping particles.
@echo
reset
set angle 1 1
set angle 2 -1
set paths on
run {segment}
set paths off

@echo
@echo Set angles of rods.  Can be set while the simulation
@echo is running.
@echo
reset
set angle 1 0
script pause 0.5
set angle 1 45
script pause 0.5
set angle 1 90
script pause 0.5
set angle 1 180
script pause 0.5
set angle 1 270
script pause 0.5
set angle 2 0
script pause 0.5
set angle 2 45
script pause 0.5
set angle 2 90
script pause 0.5
set angle 2 180
run asynchronous
script pause 5
set angle 1 1
set angle 2 -45
script pause 5
set angle 1 90
script pause 5
run off

@echo
@echo Show or hide display case.
@echo
reset
set angle 1 -90
set angle 2 0
set mass 1 275
set length 1 250
run asynchronous
script pause 2
set case off
script pause 5
set case on
script pause 2
run off

@echo
@echo Adjust gravitational force
@echo
@echo Low gravity simulation
@echo
reset
set angle 1 30
set angle 2 30
set gravity 0.005
run {segment}
script pause 1
@echo
@echo High gravity simulation
@echo
reset
set angle 1 30
set angle 2 30
set gravity 0.5
script pause 5
run {segment}

reset
set angle 1 0
set angle 2 -90
@echo
@echo You can sit on and ride the pendulum bob.
@echo Right click on model and choose Sit Here.
@echo
script pause 10
@echo
@echo Ready?  Here we go!
@echo
run {segment}
@echo
@echo Click Stand to leave the bob.
@echo

reset
@echo
@echo You can develop your own scripts and
@echo menu systems for demonstrations and
@echo experiments.  The Commander script and
@echo menus allow menu-based control of many
@echo simulation parameters.  You can launch
@echo Commander with:
@echo     /1993 script run Commander
@echo
script run Commander

@echo
@echo This concludes the scripted demonstration.
@echo You can run the demonstration at any time
@echo with:
@echo     /1993 script run Demonstration
@echo
@echo For more information and complete documentation
@echo of script and menu commands, see the
@echo Double Pendulum User Guide, available with:
@echo     /1993 help
