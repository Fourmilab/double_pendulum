
#  Main

menu begin Main "Choose command family menu"
menu button Model "menu show Model"
menu button Rotate "menu show Rotate"
menu button View "menu show View"
menu button Settings "menu show Settings"
menu button Exit
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Rotate

script set ang "30"
script set sign "+"

menu begin Rotate "Rotate bobs"
menu button "0°" "script set ang 0" "menu show Rotate"
menu button "45°" "script set ang 30" "menu show Rotate"
menu button "90°" "script set ang 90" "menu show Rotate"
menu button "135°" "script set ang 135" "menu show Rotate"
menu button "179°" "script set ang 179" "menu show Rotate"
menu button "+" "script set sign +" "menu show Rotate"
menu button "−" "script set sign -" "menu show Rotate"
menu button "Bob 1" "set angle 1 {sign}{ang}" "menu show Rotate"
menu button "Bob 2" "set angle 2 {sign}{ang}" "menu show Rotate"
menu button "Run" "run async" "menu show Rotate"
menu button "Stop" "run off" "menu show Rotate"
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Settings

script set rate 5

menu begin Settings "Model and simulation settings"
menu button "Case on" "set case on" "menu show Settings"
menu button "Case off" "set case off" "menu show Settings"
menu button "Gravity -" "set gravity 0.05" "menu show Settings"
menu button "Gravity 1" "set gravity 0.1" "menu show Settings"
menu button "Gravity +" "set gravity 0.5" "menu show Settings"
menu button Reset "rotate reset" "Menu show Settings "
menu button "Run" "run async" "menu show Settings"
menu button "Stop" "run off" "menu show Settings"
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Model

menu begin Model "Set model parameters"
menu button "Standard" "reset" "menu show Model"
menu button "Heavy bob 1" "set mass 1 200" "set mass 2 50" "menu show Model"
menu button "Heavy bob 2" "set mass 1 50" "set mass 2 200" "menu show Model"
menu button "Long rod 1" "set length 1 300" "set length 2 100" "menu show Model"
menu button "Long rod 2" "set length 1 100" "set length 2 300" "menu show Model"
menu button "Elevated" "set angle 1 1" "set angle 2 -1" "menu show Model"
menu button "Lowered" "set angle 1 135" "set angle 2 -135" "menu show Model"
menu button "Run" "run async" "menu show Model"
menu button "Stop" "run off" "menu show Model"
menu button Main "Menu show Main"
menu end

#   View

menu begin View "Set viewing parameters"
menu button "Smaller" "set scale 0.8x auto" "menu show View "
menu button "Scale 1" "set scale 1 auto" "menu show View "
menu button "Bigger" "set scale 1.25x auto" "menu show View "
menu button "Path lines" "set path lines" "menu show View"
menu button "Path trail" "set path on" "menu show View"
menu button "Path off" "set path off" "menu show View"
menu button "Run" "run async" "menu show View"
menu button "Stop" "run off" "menu show View"
menu button "Reset" "reset" "menu show View"
menu button Main "menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

menu show Main

script set *
#set scale 1
reset

@echo Exiting Commander
