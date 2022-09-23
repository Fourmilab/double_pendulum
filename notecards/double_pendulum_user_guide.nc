                Fourmilab Double Pendulum User Guide

Fourmilab Double Pendulum is a physical model of a double pendulum
system in which two masses (“bobs”) swing on frictionless bearings on
rods, with the first mass connected to a fixed hub and the second mass
swinging freely beneath the first.  This simple system exhibits
extraordinarily complicated and chaotic motion, which changes
dramatically as parameters of the system (masses of the bobs, lengths
of the rods, initial displacements of the masses) are varied. Fourmilab
Double Pendulum models an ideal double pendulum system, with no
friction or air resistance, and allows you to change the parameters of
the model and observe the results.  Facilities allow tracking the
chaotic motion of the lower bob, displaying its path as the system
evolves. The model is fully scriptable with commands supplied in
notecards in its inventory and scripts may define pop-up menus through
which an avatar may interact with the model.

A demonstration of the model and features may be viewed on YouTube at:
    https://www.youtube.com/watch?TBA

REZZING DOUBLE PENDULUM IN-WORLD

To use Fourmilab Double Pendulum, simply rez the object in-world on
land where you are allowed to create objects (land you own or have
permission to use, or in a public sandbox that supports scripted
objects).  The land impact is 7.  You can create as many models as you
wish, limited only by your parcel's prim capacity.  If you create
multiple objects in proximity to one another, you may want to assign
them different chat channels (see the Channel command below) so you can
control each independently.  You can demonstrate and control many of
the features of Double Pendulum from a system of menus which can be
launched by the chat command:
    /1993 script run Commander
A demonstration of the model and commands can be run with:
    /1993 script run Demonstration

SITTING ON THE PENDULUM

You can sit on the lower bob and move with it as it swings by right
clicking anywhere on the model except the wooden base and selecting
“Sit Here”. Sitting on the wooden base will cause you to sit statically
atop the model.  If one avatar is already sitting on the pendulum bob
and a second tries to sit there, the second will be seated on top.

CHAT COMMANDS

Fourmilab Double Pendulum accepts commands submitted on local chat
channel 1993 (the year the paper “Double Pendulum: An experiment in
chaos” was published in the American Journal of Physics) and responds
in local chat. Commands are as follows.  (Most chat commands and
parameters, except those specifying names from the inventory, may be
abbreviated to as few as two characters and are insensitive to upper
and lower case.)

    Access public/group/owner
        Specifies who can send commands to the object.  You can
        restrict it to the owner only, members of the owner's group, or
        open to the general public.  Default access is by owner.

    Boot
        Reset the script.  All settings will be restored to their
        defaults.  If you have changed the chat command channel, this
        will restore it to the default of 1993.

    Channel n
        Set the channel on which the object listens for commands in
        local chat to channel n.  If you subsequently reset the script
        with the “Boot” command or manually, the chat channel will
        revert to the default of 1993.

    Clear
        Send vertical white space to local chat to separate output when
        debugging.

    Echo text
        Echo the text in local chat.  This allows scripts to send
        messages to those running them to let them know what they're
        doing.

    Help
        Send this notecard to the requester.

    Menu
        These commands allow displaying a custom menu dialogue with
        buttons which, when clicked, cause commands to be executed
        as if entered from chat or a notecard script.

        Menu begin name "Menu text"
            Begins the definition of a menu with the given name.  When
            the menu is displayed, the quoted Menu text will appear at
            the top of the dialogue box.

        Menu button "Label" "Command 1" "Command 2" ...
            Defines a button with the specified label which, when
            clicked, causes the listed commands to be run as if entered
            from chat or submitted by a script.  If the label or
            commands contain spaces, they should be quoted.  Two
            consecutive quote marks may be used to include a quote in
            the label or command.  Due to limitations in Second Life's
            dialogue system, a maximum of 12 buttons may be defined in
            a menu and button labels can contain no more than 24
            characters.  A button with the label "*Timeout*" will not
            be displayed in the menu but its commands will be run if
            the menu times out after one minute without user response.
            The commands defined for a button may include those
            described below as being used only with scripts, such as
            “Script pause” and “Script loop”.

        Menu delete name
            Deletes a previously defined menu with the specified name.

        Menu end
            Completes the definition of a menu started with “Menu
            begin” and subsequent “Menu button” commands.  You may
            define as many menus as you wish, limited only by available
            memory for the script.

        Menu kill
            Terminates listening for clicks in the currently displayed
            menu.  Second Life provides no way to remove a displayed
            menu from the screen, so it continues to be shown until the
            user closes its window.

        Menu list [ name ]
            If no name is specified, lists the names of defined menus.
            If a name is given, lists the buttons of that menu and
            the commands they run when clicked.

        Menu reset
            Resets the menu system, terminating any active menu and
            deleting all previously-defined menus.

        Menu show name [ continue ]
            Display the named menu and begin listening for clicks on
            the buttons it contains.  Normally, displaying a menu from
            a script causes script execution to pause until the user
            clicks a button in the menu or it times out.  If “continue”
            is specified, script execution will continue while the menu
            is displayed.  The “Menu show” command may be used within
            menu button command lists, allowing complex chaining of
            menus and construction of hierarchical menu systems.

    Reset
        Resets the model to the initial conditions specified by “Set
        angle”.  Use this when you want to compare the evolution of
        the model as you change masses and rod lengths.

    Run on/off/time/asynchronous
        Starts or stops an animation in which the model is updated
        every time tick (see “Set tick” and “Set tock” below).  If a
        number is specified instead of “on” or “off”, the animation
        will run for that number of seconds and stop automatically.
        Execution of commands from a script is suspended while an
        animation is in progress, so you can use timed Run commands in
        a script to demonstrate different parameters.  If
        “asynchronous” is specified (as always, you can abbreviate this
        to as few as two characters), the simulation will be started
        for an indefinite period but a script that submits the command
        will not be paused.  This allows building menu systems that
        permit a user to change parameters while a simulation is
        running and see the effects immediately.

    Script
        These commands control the running of scripts stored in
        notecards in the inventory of the object.  Commands in scripts
        are identical to those entered in local chat (but, of course,
        are not preceded by a slash and channel number).  Blank lines
        and those beginning with a “#” character are treated as
        comments and ignored.

        Script list
            Print a list of scripts in the inventory.  Only notecards
            whose names begin with “Script: ” are listed and may be
            run.

        Script resume
            Resumes a paused script, whether due to an unexpired timed
            pause or a pause until touched or resumed.

        Script run [ Script Name ]
            Run the specified Script Name.  The name must be specified
            exactly as in the inventory, without the leading “Script: ”.
            Scripts may be nested, so the “Script run” command may
            appear within a script.  Entering “Script run” with no
            script name terminates any running script(s).

        Script set name "Value"
            Defines a macro with the given name and value which may be
            used in script and menu commands by specifying the name
            within curly brackets.  Names are case-insensitive, but
            values are case-sensitive and may contain spaces.  For
            example, in a menu you might define a button:
                menu button "Rotate" "rotate {plane} {sign}{ang}" "menu show Rot"
            where the macros can be changed by other buttons in the
            menu, for example:
                menu button "XY" "script set plane xy" "menu show Rot"

        Script set name
            Deletes a macro with the specified name.  Macros remain
            defined until the script processor is reset or they are
            explicitly deleted, so scripts and menus should clean up
            macros they define to avoid memory exhaustion errors.

        Script set *
            Deletes all defined macros.

        Script set
            Lists all defined macros and their values.

            The following commands may be used only within scripts or
            commands defined for Menu buttons.

            Script loop [ n ]
                Begin a loop within the script which will be executed n
                times, or forever if n is omitted.  Loops may be
                nested, and scripts may run other scripts within loops.
                An infinite loop can be terminated by “Script run” with
                no script name or by the “Boot” command.

            Script end
                Marks the end of a “Script loop”.  If the number of
                iterations has been reached, proceeds to the next
                command.  Otherwise, repeats, starting at the top of
                the loop.

            Script pause [ n/touch/region ]
                Pauses execution of the script for n seconds.  If the
                argument is omitted, the script is paused for one
                second.  If “touch” is specified, the script will be
                paused until the object is touched or a “Script resume”
                command is entered from chat.  Specifying “region”
                resumes the script when the object enters a new region,
                which can only occur if you happen to be wearing it as
                an attachment, which is a pretty odd thing to do.

            Script wait n[unit] [ offset[unit] ]
                Pause the script until the start of the next n units of
                time, where unit may be “s”=seconds, “m”=minutes,
                “h“=hours, or ”d”=days, plus the offset time, similarly
                specified.  This can be used in loops to periodically
                run shows at specified intervals.  For example, the
                following script runs a five minute show once an hour
                at 15 minutes after the hour.
                    Script loop
                        Script wait 1h 15m
                        Script run MyHourlyShow
                    Script end

    Set
        Set a variety of parameters.

        Set case on/off/hat
            Shows (“on”) or hides (“off”) the wooden base and glass
            display case containing the model.  This only controls
            appearance and does not affect the simulation in any way.
            Setting case to “hat” configures the object to be worn as
            a hat: it sets scale to 0.3, rotates the model to be
            vertical when attached to the skull, adjusts the position
            to be around the top of a typical head, and hides the
            wooden base.  To wear, select and attach to Skull.
            Depending on the size and shape of your head and hair, you
            may need to adjust the position of the hat with the viewer
            Edit facility after attaching.

        Set colour component <R, G, B> [ alpha ]
            Sets the colour and optional transparency of components of
            the model, where component is specified by a number as
            follows.
                    1   Bob 1 (top)
                    2   Bob 2 (bottom)
                    3   Rod 1 (top)
                    4   Rod 2 (bottom)
                    5   Hub
            If alpha is specified, it sets transparency between 0
            (invisible) and 1 (opaque).

        Set diameter
            Sets the diameter of the rods connecting the two bobs in
            metres.  This value is automatically scaled by “Set scale”.
            The default is 0.01 metres (1 centimetre).

        Set echo on/off
            Controls whether commands entered from local chat or a
            script are echoed to local chat as they are executed.

        Set gravity n
            Sets the gravitational force on the bobs in arbitrary units
            with a default of 0.1.  The rods are assumed to be massless.

        Set length rodno l
            Sets the relative length of the specified rod (1 for top, 2
            for bottom) to length l.  The initial length of both rods
            is set to 50.  As the model is automatically scaled, only
            the ratio of the two rod lengths matters: for example,
            setting rod 1 to 100 and rod 2 to 200 will make rod 2 twice
            as long as rod 1.

        Set mass bobno m
            Sets the mass of the specified bob number to value m in
            arbitrary units.  The default mass of both bobs is 50.
            This is an absolute value: increasing the mass makes a bob
            rise less high as it swings.

        Set path on/off/lines [ permanent/clear ]
            Controls two methods of plotting the path traced out by the
            lower bob as it moves.  “Set path on” activates the
            dropping of particles by the bob as it swings, leaving a
            trace that persists for around 20 seconds before
            evaporating. This uses the Second Life “particle system”
            mechanism, which doesn't look all that great but it's
            lightweight and doesn't slow down the simulation.  If you
            specify “Set path lines”, temporary thin cylinder prims
            will be left behind by the bob as it moves, tracing the
            path.  This draws a very clear path but, as it involves
            creating numerous new objects, can slow the simulation.
            The path objects are automatically cleaned up by the Second
            Life garbage collector after about a minute (the time can
            vary depending on activity and object content of the land
            where the model is installed).  You can explicitly delete
            the paths with “Set path off” or “Set path lines clear”.
            Particle system paths cannot be cleared, but will evaporate
            naturally after you turn off their generation.  If you
            enable path generation with “Set path lines permanent”, the
            objects making up the path will be permanent, not temporary
            prims.  These count against the prim capacity of the land
            at the rate of one land impact per line segment, so this
            adds up quickly.  If you have land with limited capacity,
            you may want to experiment with this mode in a public
            sandbox.  “Set path lines clear” may be used to delete
            permanent path objects.

        Set scale n[x]
            Set the scale factor used to size the model and all
            components.  The default scale factor is 1; adjust the
            scale to make the object whatever size you wish. If the
            scale factor is followed by an “x” (upper or lower case),
            it is multiplied by the current scale factor.  For example,
            a specification of “0.5x” sets the scale factor to half its
            current value.  The scale factor only affects how large the
            objects appear in world: it does not change the lengths of
            the rods in the simulation.

        Set tick n
            Sets the time in seconds between integration steps when the
            Run command is active.  For smooth animation, try a setting
            of 0.1 (a tenth of a second) or a little smaller.

        Set tock n
            Specifies how frequently (number of ticks) the model in
            world is updated from the simulation of pendulum movement.
            The default is 1, which updates on every tick.  If you are
            using a very small tick or are plotting a path with “Set
            path lines”, you may want to increase the tock value to,
            say, 3, to avoid slowing down the simulation.

        Set trace on/off
            Enable or disable output, sent to the owner on local chat,
            describing operations as they occur.  This is generally
            only of interest to developers.

    Status
        Show status of the object, including settings and memory usage.

DEMONSTRATION AND EXAMPLE SCRIPT NOTECARDS

    The following script notecards are included in the inventory of the
    Double Pendulum object and may be run with the chat command “Script
    run” followed by the name of the script, which may not be
    abbreviated and must be given with capital and lower case letters
    as shown. All of these notecards are full permission so you can use
    them as models for your own development.

    Commander
        Script which defines and displays a series of linked menus that
        provide access to many of the Double Pendulum commands and
        options without requiring use of chat commands.  Illustrates
        how to build an interactive menu system.

    Configuration
        Default configuration script, which simply displays a message
        letting the user know about the Demonstration.

    Demonstration
        This is the standard demonstration script for the object.

CONFIGURATION NOTECARD

When Double Pendulum is initially rezzed or reset with the Boot
command, if there is a notecard in its inventory named “Script:
Configuration”, the commands it contains will be executed as if entered
via local chat (do not specify the chat channel on the script lines).
This allows you to automatically preset preferences as you like.

PERMISSIONS AND THE DEVELOPMENT KIT

Fourmilab Double Pendulum is delivered with “full permissions”.  Every
part of the object, including the scripts, may be copied, modified, and
transferred subject only to the license below.  If you find a bug and
fix it, or add a feature, please let me know so I can include it for
others to use.  The distribution includes a “Development Kit”
directory, which includes all of the components of the model.

The Development Kit directory contains a Logs subdirectory which
includes the development narratives for the project.  If you wonder
“Why does it work that way?” the answer may be there.

Source code for this project is maintained on and available from the
GitHub repository:
    https://github.com/Fourmilab/double_pendulum

LICENSE

This product (software, documents, and models) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.

ACKNOWLEDGEMENTS

The simulation and numerical integration code used in this model was
based upon a JavaScript model written by Abhishek Chaudhary and posted
on GitHub as:
    https://github.com/theabbie/DoublePendulum
This code was published under the MIT license:
    https://raw.githubusercontent.com/theabbie/DoublePendulum/master/LICENSE
which allows all forms of use of the software subject only to
attribution of authorship and inclusion of the license, which is
incorporated here by the above references.  Many thanks to the author
for making this code available, which simplified the development of
this project.
