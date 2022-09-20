    /*
                Fourmilab Double Pendulum
                       by John Walker

    */

    key owner;                          //  Owner UUID
    string ownerName;                   //  Name of owner

    integer commandChannel = 9;// 1993;      // Command channel in chat
    integer commandH;                   // Handle for command channel
    key whoDat = NULL_KEY;              // Avatar who sent command
    integer restrictAccess = 2;         // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;                // Echo chat and script commands ?
    integer trace = FALSE;              // Trace operation ?
    float timerTick = 0.01;             // Timer tick interval in seconds
    integer tockCount = 1;              // Update objects every tockCount ticks
    integer tock = 1;                   // Tock counter
    float globalScale = 1;              // Scale of box enclosing pendulum
    integer running = FALSE;            // Is simulation running ?
    float runEndTime;                   // Run end time or -1 if none
    integer trails = FALSE;             // Draw trail of bob ?
    integer paths = FALSE;              // Trace path with particle system ?
    integer sit = FALSE;                // Is avatar sitting on the bob ?
    integer flPlotPerm = FALSE;         // Use permanent objects for plotted lines ?
    integer linePlotters;               // Number of line plotters in inventory
    integer plotterNo = 0;              // Plotter round-robin selector
    string fuisWid;                     // Encoded constant plot line width

    integer pathChannel = -982449855;   // Channel for communicating with path markers
    string ypres = "P?+:$$";            // It's pronounced "Wipers"

    float rodDiam = 0.01;               // Pendulum rod diameter

    //  Bob and rod link numbers
    integer bob1;
    integer bob2;
    integer rod1;
    integer rod2;

    integer globe;
    integer plinth;

    string helpFileName = "Fourmilab Double Pendulum User Guide";

    //  Bob messages
    integer LM_BO_MOVE = 91;            // Bob has moved or rotated

    //  Script processing

    integer scriptActive = FALSE;       // Are we reading from a script ?
    integer scriptSuspend = FALSE;      // Suspend script execution for asynchronous event
    string configScript = "Script: Configuration";

    //  Script Processor messages
    integer LM_SP_INIT = 50;            // Initialise
    integer LM_SP_RESET = 51;           // Reset script
    integer LM_SP_STAT = 52;            // Print status
    integer LM_SP_RUN = 53;             // Add script to queue
    integer LM_SP_GET = 54;             // Request next line from script
    integer LM_SP_INPUT = 55;           // Input line from script
    integer LM_SP_EOF = 56;             // Script input at end of file
    integer LM_SP_READY = 57;           // New script ready
    integer LM_SP_ERROR = 58;           // Requested operation failed
    integer LM_SP_SETTINGS = 59;        // Set operating modes

    //  Command processor messages

    integer LM_CP_COMMAND = 223;        // Process command

    //  Menu Processor messages
//  integer LM_MP_INIT = 270;           // Initialise
    integer LM_MP_RESET = 271;          // Reset script
    integer LM_MP_STAT = 272;           // Print status
    integer LM_MP_SETTINGS = 273;       // Set operating modes
    integer LM_MP_RESUME = 274;         // Resume script after menu selection

    //  Plotter messages
    integer LM_PL_DRAW = 471;           // Draw a line

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    /*  Find a linked prim from its name.  Avoids having to slavishly
        link prims in order in complex builds to reference them later
        by link number.  You should only call this once, in state_entry(),
        and then save the link numbers in global variables.  Returns the
        prim number or -1 if no such prim was found.  Caution: if there
        are more than one prim with the given name, the first will be
        returned without warning of the duplication.  */

    integer findLinkNumber(string pname) {
        integer i = llGetLinkNumber() != 0;
        integer n = llGetNumberOfPrims() + i;

        for (; i < n; i++) {
            if (llGetLinkName(i) == pname) {
                return i;
            }
        }
//tawk("Gaaak!  " + pname);
        return -1;
    }

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == llGetOwner());
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llStringTrim(cmd, STRING_TRIM);
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && (c == ">")) {
                inbrack = FALSE;
            }
            if (c == "<") {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            tawk("Error: please specify on or off.");
            return -1;
        }
    }

    //  bobNo  --  Parse and validate bob or edge number

    integer bobNo(string arg) {
        integer bn = (integer) arg;
        if ((bn < 1) || (bn > 2)) {
            tawk("Specify number: 1 or 2.");
            return FALSE;
        }
        return bn;
    }

    //  fixangr  --  Range reduce an angle in radians

    float fixangr(float a) {
        return a - (TWO_PI * (llFloor(a / TWO_PI)));
    }

    //  eOnOff  -- Edit an on/off parameter

    string eOnOff(integer p) {
        if (p) {
            return "on";
        }
        return "off";
    }

    /*  fuis  --  Encode floating point number as base64 string

        The fuis function encodes its floating point argument as a six
        character string encoded as base64.  This version is modified
        from the original in the LSL Library.  By ignoring the
        distinction between +0 and -0, this version runs almost three
        times faster than the original.  While this does not preserve
        floating point numbers bit-for-bit, it doesn't make any
        difference in our calculations.
    */

    string fuis(float a) {
        /*  Test for negative number, ignoring the difference between
            +0 and -0.  While this does not preserve floating point
            numbers bit-for-bit, it doesn't make any difference in
            our calculations and is almost three times faster than
            the original code above.  */
        integer b = 0;
        if (a < 0) {
            b = 0x80000000;
        }

        if (a) {        // Is it greater than or less than zero ?
            //  Denormalized range check and last stride of normalized range
            if ((a = llFabs(a)) < 2.3509887016445750159374730744445e-38) {
                b = b | (integer) (a / 1.4012984643248170709237295832899e-45);   // Math overlaps; saves CPU time
            //  We never need to transmit infinity, so save the time testing for it.
            // } else if (a > 3.4028234663852885981170418348452e+38) { // Round up to infinity
            //     b = b | 0x7F800000;                                 // Positive or negative infinity
            } else if (a > 1.4012984643248170709237295832899e-45) { // It should at this point, except if it's NaN
                integer c = ~-llFloor(llLog(a) * 1.4426950408889634073599246810019);
                //  Extremes will error towards extremes. The following corrects it
                b = b | (0x7FFFFF & (integer) (a * (0x1000000 >> c))) |
                        ((126 + (c = ((integer) a - (3 <= (a *= llPow(2, -c))))) + c) * 0x800000);
                //  The previous requires a lot of unwinding to understand
            } else {
                //  NaN time!  We have no way to tell NaNs apart so pick one arbitrarily
                b = b | 0x7FC00000;
            }
        }

        return llGetSubString(llIntegerToBase64(b), 0, 5);
    }

    /*  fv --  Encode vector as base64 string}

        The fv function encodes the three components of a vector as
        consecutive fuis base64 strings.  */

    string fv(vector v) {
        return fuis(v.x) + fuis(v.y) + fuis(v.z);
    }

    //  ef  --  Edit floats in string to parsimonious representation

    string eff(float f) {
        return ef((string) f);
    }
/*
    string efv(vector v) {          // Helper that takes a vector argument
        return ef((string) v);
    }
*/
    //  Static constants to avoid costly allocation
    string efkdig = "0123456789";
    string efkdifdec = "0123456789.";

    string ef(string s) {
        integer p = llStringLength(s) - 1;

        while (p >= 0) {
            //  Ignore non-digits after numbers
            while ((p >= 0) &&
                   (llSubStringIndex(efkdig, llGetSubString(s, p, p)) < 0)) {
                p--;
            }
            //  Verify we have a sequence of digits and one decimal point
            integer o = p - 1;
            integer digits = 1;
            integer decimals = 0;
            string c;
            while ((o >= 0) &&
                   (llSubStringIndex(efkdifdec, (c = llGetSubString(s, o, o))) >= 0)) {
                o--;
                if (c == ".") {
                    decimals++;
                } else {
                    digits++;
                }
            }
            if ((digits > 1) && (decimals == 1)) {
                //  Elide trailing zeroes
                integer b = p;
                while ((b >= 0) && (llGetSubString(s, b, b) == "0")) {
                    b--;
                }
                //  If we've deleted all the way to the decimal point, remove it
                if ((b >= 0) && (llGetSubString(s, b, b) == ".")) {
                    b--;
                }
                //  Remove everything we've trimmed from the number
                if (b < p) {
                    s = llDeleteSubString(s, b + 1, p);
                    p = b;
                }
                //  Done with this number.  Skip to next non digit or decimal
                while ((p >= 0) &&
                       (llSubStringIndex(efkdifdec, llGetSubString(s, p, p)) >= 0)) {
                    p--;
                }
            } else {
                //  This is not a floating point number
                p = o;
            }
        }
        return s;
    }

    float x0;
    float y0;
    float ang0;
    float ang1;
    float v0;
    float v1;
    float acc0;
    float acc1;
    float l0;
    float l1;
    float m0;
    float m1;
    float g;
    float massScaleFactor;
    float speedScaleFactor;
    float dt;
    float moment0;
    float moment1;

    //  calculateBobPosition  --  Compute Cartesian co-ordinates of bob

    vector calculateBobPosition(float X0, float Y0, float angle, float len) {
        float offsetX = len * llSin(angle);
        float offsetY = len * llCos(angle);
        return < X0 + offsetX, Y0 + offsetY, 0 >;
    }

    //  getUpperBob  --  Get upper bob position

    vector getUpperBob() {
        return calculateBobPosition(x0, y0, ang0, l0);
    }

    //  getLowerBob  --  Get lower bob position

    vector getLowerBob() {
        vector upperBobPos = getUpperBob();
        return calculateBobPosition(upperBobPos.x, upperBobPos.y, -ang1, l1);
    }

    //  hamiltonian  --  Compute Hamiltonian from angles and momenta

    rotation hamiltonian(float Ang0,  float Ang1,  float Moment0,  float Moment1) {
        float sinA0mA1 = llSin(Ang0 - Ang1);
        float C0 = l0 * l1 * (m0 + m1 * (sinA0mA1 * sinA0mA1));
        float C1 = (Moment0 * Moment1 * llSin(Ang0 - Ang1)) / C0;
        float pl1xM0 = l1 * Moment0;
        float pl0xM1 = l0 * Moment1;
        float C2 =
            ((m1 * (pl1xM0 * pl1xM0) +
            (m0 + m1) * (pl0xM1 * pl0xM1) -
            2 * l0 * l1 * m1 * Moment0 * Moment1 * llCos(Ang0 - Ang1)) *
            llSin(2 * (Ang0 - Ang1))) / (2 * (C0 * C0));
        float F_Ang0 =
          (l1 * Moment0 - l0 * Moment1 * llCos(Ang0 - Ang1)) / (l0 * C0);
        float F_Ang1 =
          (l0 * (m0 + m1) * Moment1 -
            l1 * m1 * Moment0 * llCos(Ang0 - Ang1)) /
          (l1 * m1 * C0);
        float F_Moment0 = -(m0 + m1) * g * l0 * llSin(Ang0) - C1 + C2;
        float F_Moment1 = -m1 * g * l1 * llSin(Ang1) + C1 - C2;
        return < F_Ang0, F_Ang1, F_Moment0, F_Moment1 >;
    }

    //  move  --  Move one step of dT

    move(float an0, float an1, float mom0, float mom1, float dT) {
        rotation curr = < an0, an1, mom0, mom1 >;
        rotation k1 = hamiltonian(an0, an1, mom0, mom1);
        rotation k2 = hamiltonian(curr.x + (0.5 * dT * k1.x),
                                  curr.y + (0.5 * dT * k1.y),
                                  curr.z + (0.5 * dT * k1.z),
                                  curr.s + (0.5 * dT * k1.s));
        rotation k3 = hamiltonian(curr.x + (0.5 * dT * k2.x),
                                  curr.y + (0.5 * dT * k2.y),
                                  curr.z + (0.5 * dT * k2.z),
                                  curr.s + (0.5 * dT * k2.s));
        rotation k4 = hamiltonian(curr.x + (dT * k3.x),
                                  curr.y + (dT * k3.y),
                                  curr.z + (dT * k3.z),
                                  curr.s + (dT * k3.s));
        rotation R = < (dT * (k1.x + 2 * k2.x + 2 * k3.x + k4.x)) / 6,
                       (dT * (k1.y + 2 * k2.y + 2 * k3.y + k4.y)) / 6,
                       (dT * (k1.z + 2 * k2.z + 2 * k3.z + k4.z)) / 6,
                       (dT * (k1.s + 2 * k2.s + 2 * k3.s + k4.s)) / 6
                     >;
        ang0 += R.x;
        ang1 += R.y;
        moment0 += R.z;
        moment1 += R.s;
        ang0 = fixangr((3 * PI) + ang0) - PI;
        ang1 = fixangr((3 * PI) + ang1) - PI;
    }

    //  setMoments  --  Compute moments from motion parameters

    setMoments() {
        float commonVal = m1 * l0 * l1 * llCos(ang0 - ang1);
        moment0 = (m0 + m1) * (l0 * l0) * v0 + v1 * commonVal;
        moment1 = m1 * (l1 * l1) * v1 + v0 * commonVal;
    }

    //  initModel  --  Initialise model parameters

    float scale;                    // Global scale factor

    initModel(float hgt, float wid) {
        float scaleWidth = 100;
        float scaleHeight = (100 * hgt) / wid;
        scale = scaleWidth;
        if (scaleHeight < scale) {
            scale = scaleHeight;
        }

        x0 = y0 = 0;
        ang0 = ang1 = v0 = v1 = acc0 = acc1 = 0;
        l0 = l1 = 50;
        m0 = m1 = 100;
        g = 0.1;
        massScaleFactor = speedScaleFactor = 1.2;
        dt = 1;

        setMoments();
    }

    //  placeRod  --  Place a rod at specified endpoints

    placeRod(integer linkno, vector p1, vector p2) {
        float length = llVecDist(p1, p2);
        vector midPoint = (p1 + p2) / 2;

        llSetLinkPrimitiveParamsFast(linkno,
            [ PRIM_POS_LOCAL, midPoint,
              PRIM_ROT_LOCAL, llRotBetween(<0, 0, 1>, llVecNorm(p2 - midPoint)),
              PRIM_SIZE, <rodDiam * globalScale,
                          rodDiam * globalScale, length> ]);
    }

    //  resetModel  --  Reset model to initial conditions

    resetModel() {
        running = FALSE;
        llSetTimerEvent(0);
        initModel(58.9852, 100);
        ang0 = (7 * PI) / 8;  // 3 * PI_BY_TWO;
        ang1 = -PI_BY_TWO;
        setMoments();
    }

    //  displayModel  --  Display current model state

    vector llbob = <0, 0, -1>;      // Previous lower bob position

    displayModel() {
        vector ubob = getUpperBob();
        vector lbob = getLowerBob();
        float scaler = (globalScale / (l0 + l1)) / 2;
        ubob *= scaler;
        lbob *= scaler;
        //  Transform due to local rotation of top pivot
        ubob = <ubob.x, -ubob.y, 0>;
        lbob = <lbob.x, -lbob.y, 0>;
        llSetLinkPrimitiveParamsFast(bob1,
            [ PRIM_POS_LOCAL, ubob ]);
        placeRod(rod1, <x0, y0, 0> / scale, ubob);
        llSetLinkPrimitiveParamsFast(bob2, [ PRIM_ROT_LOCAL,
            (llRotBetween(<0, 0, 1>,
             llVecNorm(lbob - ubob)) *
             llAxisAngle2Rot(<0, 0, 1>, PI_BY_TWO)) ] + [ PRIM_POS_LOCAL, lbob ]);
        placeRod(rod2, ubob, lbob);
        if (trails && (llbob.z == 0) && (llbob != lbob)) {
            vector rp = llGetPos();
            rotation rr = llGetRot();
            vector rlbob = (lbob * rr) + rp;
            vector rllbob = (llbob * rr) + rp;
            llMessageLinked(LINK_THIS, LM_PL_DRAW,
                fv(rllbob) + fv(rlbob) + fv(llList2Vector(llGetLinkPrimitiveParams(bob2,
                    [ PRIM_COLOR, ALL_SIDES ]), 0)) + fuisWid +
                    llChar(48 + flPlotPerm) + (string) (plotterNo + 1),
                whoDat);
            plotterNo = (plotterNo + 1) % linePlotters;
        }
        llbob = lbob;
        if (sit) {
            llMessageLinked(bob2, LM_BO_MOVE, "", NULL_KEY);
        }
    }

    //  updateModel  --  Update model for one animation step

    updateModel() {
        move(ang0, ang1, moment0, moment1, dt);
        if (--tock <= 0) {
            displayModel();
            tock = tockCount;
        }
    }

    //  updateBobs  --  Update bobs when mass changes

    updateBobs() {
        float dia = 0.05 * llSqrt(m0 / 100) * globalScale;
        llSetLinkPrimitiveParamsFast(bob1,
            [ PRIM_SIZE, < dia, dia, dia > ]);
        dia = 0.05 * llSqrt(m1 / 100) * globalScale;
        llSetLinkPrimitiveParamsFast(bob2,
            [ PRIM_SIZE, < dia, dia, dia > ]);
         llSetLinkPrimitiveParamsFast(LINK_THIS,
            [ PRIM_SIZE, < 0.05, 0.05, 0.015 > * globalScale]);

    }

    //  clearPaths  --  Delete any path tracing objects

    clearPaths() {
        llRegionSay(pathChannel, llList2Json(JSON_ARRAY, [ ypres ]));
    }

    //  updateGlobe  --  Update enclosing display case

    updateGlobe() {
        vector plinthSize = < 0.86, 0.05, 0.5 >;
        vector plinthPos = < 0, -0.788, 0 >;
        float dia = globalScale * 1.1;
        llSetLinkPrimitiveParamsFast(globe,
            [ PRIM_SIZE, < dia, dia, 0.05 * globalScale > ]);
        llSetLinkPrimitiveParamsFast(plinth,
            [ PRIM_SIZE, plinthSize * globalScale,
              PRIM_POS_LOCAL, plinthPos * globalScale ]);
        llLinkSitTarget(plinth,
            < 0, -0.4, dia + (0.25 * globalScale) + 0.4 >,
            llEuler2Rot(<0, 0, -PI_BY_TWO>));
    }

    //  sendSettings  --  Send settings to other scripts

    sendSettings() {
        llMessageLinked(LINK_THIS, LM_SP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
        llMessageLinked(LINK_THIS, LM_MP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
    }

    /*  scriptResume  --  Resume script execution when asynchronous
                          command completes.  */

    scriptResume() {
        if (scriptActive) {
            if (scriptSuspend) {
                scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", NULL_KEY);
                if (trace) {
                    tawk("Script resumed.");
                }
            }
        }
    }

    //  processCommand  --  Process a command

    integer processCommand(key id, string message, integer fromScript) {
        if (!checkAccess(id)) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        /*  If echo is enabled, echo command to sender unless
            prefixed with "@".  The command is prefixed with ">>"
            if entered from chat or "++" if from a script.  */

        integer echoCmd = TRUE;
        if (llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 0, 0) == "@") {
            echoCmd = FALSE;
            message = llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 1, -1);
        }
        if (echo && echoCmd) {
            string prefix = ">> ";
            if (fromScript) {
                prefix = "++ ";
            }
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = fixArgs(llToLower(message));
        list args = llParseString2List(lmessage, [" "], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Access who                  Restrict chat command access to public/group/owner

        if (abbrP(command, "ac")) {
            string who = llList2String(args, 1);

            if (abbrP(who, "p")) {          // Public
                restrictAccess = 0;
            } else if (abbrP(who, "g")) {   // Group
                restrictAccess = 1;
            } else if (abbrP(who, "o")) {   // Owner
                restrictAccess = 2;
            } else {
                tawk("Unknown access restriction \"" + who +
                    "\".  Valid: public, group, owner.\n");
                return FALSE;
            }

        //  Boot                        Reset script

        } else if (abbrP(command, "bo")) {
            llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
            llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
            llSleep(0.25);
            llResetScript();

        /*  Channel n                   Change command channel.  Note that
                                        the channel change is lost on a
                                        script reset.  */

        } else if (abbrP(command, "ch")) {
            integer newch = (integer) llList2String(args, 1);
            if ((newch < 2)) {
                tawk("Invalid channel " + (string) newch + ".");
                return FALSE;
            } else {
                llListenRemove(commandH);
                commandChannel = newch;
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                llSetText("Edge Factory\n/" + (string) commandChannel, < 0, 1, 0 >, 1);
                tawk("Listening on /" + (string) commandChannel);
            }

        //  Clear                       Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Echo text               Send text to sender

        } else if (abbrP(command, "ec")) {
            integer dindex = llSubStringIndex(lmessage, command);
            integer doff = llSubStringIndex(llGetSubString(lmessage, dindex, -1), " ");
            string emsg = " ";
            if (doff >= 0) {
                emsg = llStringTrim(llGetSubString(message, dindex + doff + 1, -1),
                            STRING_TRIM_TAIL);
            }
            tawk(emsg);

        //  Help                        Display help text

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Reset

        } else if (abbrP(command, "re")) {
            resetModel();
            displayModel();

        //  Run on/off/time/async   Start / stop simulation

        } else if (abbrP(command, "ru")) {
            integer sync = TRUE;
            runEndTime = -1;
            if (argn >= 2) {
                if (llSubStringIndex("0123456789.", llGetSubString(sparam, 0, 0)) >= 0) {
                    runEndTime = llGetTime() + ((float) sparam);
                    sparam = "on";
                } else if (abbrP(sparam, "as")) {
                    sync = FALSE;
                    sparam = "on";
                }
                running = onOff(sparam);
            } else {
                running = !running;
            }
            if (running) {
                llSetTimerEvent(timerTick);
                scriptSuspend = sync;
            } else {
                llSetTimerEvent(0);
                scriptResume();
            }

        //  Set                     Set parameter

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);

            //  Set angle bobno angle

            if (abbrP(sparam, "an")) {
                integer n = bobNo(svalue);
                if (n > 0) {
                    if (argn >= 4) {
                        float ang = llList2Float(args, 3) * DEG_TO_RAD;
                        if (n == 1) {
                            ang0 = fixangr(PI - ang);
                        } else {
                            ang1 = fixangr(PI + ang);
                        }
                        displayModel();
                    } else {
                        tawk("Angle missing.");
                    }
                } else {
                    return FALSE;
                }

                //  Set case on/off

                } else if (abbrP(sparam, "ca")) {
                    float alpha = onOff(svalue);
                    llSetLinkAlpha(globe, alpha * 0.25, ALL_SIDES);
                    llSetLinkAlpha(plinth, alpha, ALL_SIDES);

                //  Set colour 1/2/3/4 <r, g, b> [ alpha ]

                } else if (abbrP(sparam, "co")) {
                    integer n = (integer) svalue;
                    if ((n >= 1) && (n <= 5)) {
                        integer lk = llList2Integer(
                            [ bob1, bob2, rod1, rod2, LINK_ROOT ], n - 1);
                        float alpha = 1;
                        if (argn >= 5) {
                            alpha = llList2Float(args, 4);
                        }
                        llSetLinkColor(lk, (vector) llList2String(args, 3), ALL_SIDES);
                        llSetLinkAlpha(lk, alpha, ALL_SIDES);
                    }

                //  Set diameter n

                } else if (abbrP(sparam, "di")) {
                    rodDiam = (float) svalue;

                //  Set echo on/off

                } else if (abbrP(sparam, "ec")) {
                    echo = onOff(svalue);
                    sendSettings();

                //  Set gravity n

                } else if (abbrP(sparam, "gr")) {
                    g = (float) svalue;

                //  Set length bobno l

                } else if (abbrP(sparam, "le")) {
                    integer n = bobNo(svalue);
                    if (n > 0) {
                        if (argn >= 4) {
                            float l = llList2Float(args, 3);
                            if (l <= 0) {
                                tawk("Length must be positive.");
                                return FALSE;
                            }
                            if (n == 1) {
                                l0 = l;
                            } else {
                                l1 = l;
                            }
                            displayModel();
                        } else {
                            tawk("Length missing.");
                        }
                    } else {
                        return FALSE;
                    }

                //  Set mass bobno l

                } else if (abbrP(sparam, "ma")) {
                    integer n = bobNo(svalue);
                    if (n > 0) {
                        if (argn >= 4) {
                            float m = llList2Float(args, 3);
                            if (m <= 0) {
                                tawk("Mass must be positive.");
                                return FALSE;
                            }
                            if (n == 1) {
                                m0 = m;
                            } else {
                                m1 = m;
                            }
                            updateBobs();
                            displayModel();
                        } else {
                            tawk("Mass missing.");
                        }
                    } else {
                        return FALSE;
                    }

                //  Set path on/off/lines [ permanent/clear ]

                } else if (abbrP(sparam, "pa")) {
                    if (abbrP(svalue, "li")) {
                        if (paths) {
                            paths = FALSE;
                        }
                        trails = TRUE;
                        flPlotPerm = FALSE;
                        if (argn >= 4) {
                            string larg = llList2String(args, 3);
                            flPlotPerm = abbrP(larg, "pe");
                            if (abbrP(larg, "cl")) {
                                trails = FALSE;
                                clearPaths();
                            }
                        }
                    } else {
                        if (trails && (!flPlotPerm)) {
                            clearPaths();
                        }
                        trails = FALSE;
                        paths = onOff(svalue);
                    }
                    if (paths) {
                        vector pcol = llList2Vector(llGetLinkPrimitiveParams(bob2,
                            [ PRIM_COLOR, ALL_SIDES ]), 0);
                        llLinkParticleSystem(bob2,
                            [ PSYS_PART_FLAGS,
                              PSYS_PART_EMISSIVE_MASK |
                                PSYS_PART_INTERP_COLOR_MASK |
                                PSYS_PART_RIBBON_MASK,
                              PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
                              PSYS_PART_START_COLOR, pcol,
                              PSYS_PART_END_COLOR, pcol,
                              PSYS_PART_START_SCALE, <0.0625, 0.4, 1>,
                              PSYS_PART_END_SCALE, <0.0625, 0.4, 1>,
                              PSYS_SRC_MAX_AGE, 0,
                              PSYS_PART_MAX_AGE, 20,
                              PSYS_SRC_BURST_RATE, 0,
                              PSYS_SRC_BURST_PART_COUNT, 500
                            ]);
/*
                        llLinkParticleSystem(bob2,
                            [ PSYS_PART_FLAGS,
                              PSYS_PART_EMISSIVE_MASK |
                                PSYS_PART_INTERP_COLOR_MASK ,
                              PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
                              PSYS_PART_START_COLOR, <1, 1, 1>,
                              PSYS_PART_END_COLOR, <1, 0, 0>,
                              PSYS_PART_START_ALPHA, 1,
                              PSYS_PART_END_ALPHA, 0.25,
                              PSYS_PART_START_SCALE, <0.03125, 0.03125, 1>,
                              PSYS_PART_END_SCALE, <0.03125, 0.03125, 1>,
                              PSYS_SRC_MAX_AGE, 0,
                              PSYS_PART_MAX_AGE, 30,
                              PSYS_SRC_BURST_RATE, 0,
                              PSYS_SRC_BURST_PART_COUNT, 500
                            ]);
*/
                    } else {
                        llLinkParticleSystem(bob2, [ ]);
                    }

                //  Set scale n

                } else if (abbrP(sparam, "sc")) {
                    if (llGetSubString(svalue, -1, -1) == "x") {
                        globalScale *= (float) llGetSubString(svalue, 0, -2);
                    } else {
                        globalScale = (float) svalue;
                    }
                    updateGlobe();
                    updateBobs();
                    displayModel();

                //  Set tick n

                } else if (abbrP(sparam, "ti")) {
                    timerTick = (float) svalue;
                    if (running) {
                        llSetTimerEvent(timerTick);
                    }

                //  Set tock n

                } else if (abbrP(sparam, "to")) {
                    tockCount = (integer) svalue;

                //  Set trace on/off

                } else if (abbrP(sparam, "tr")) {
                    trace = onOff(svalue);
                    sendSettings();

                } else {
                    tawk("Setting unknown.");
                    return FALSE;
                }

        //  Status                  Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            string s;
            s += "Trace: " + eOnOff(trace) + "  Echo: " + eOnOff(echo) +
                 "  Run: " + eOnOff(running) +
                 "  Tick: " + eff(timerTick) + "\n";
            s += "  Length 1: " + eff(l0) + "  2: " + eff(l0) +
                 "\n  Mass 1: " + eff(m0) + "  2: " + eff(m1) + "\n";
            s += "  Gravity: " + eff(g) + "  Scale: " + eff(globalScale) + "\n";
            s += "  Line plotters: " + (string) linePlotters + "\n";
            s += "Script memory.  Free: " + (string) mFree +
                    "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";
            tawk(s);
            //  Request status of Script Processor
            llMessageLinked(LINK_THIS, LM_SP_STAT, "", id);
            //  Request status of Menu Processor
            llMessageLinked(LINK_THIS, LM_MP_STAT, "", id);

        //  Test                        Run test
/*
        } else if (abbrP(command, "te")) {
*/

        //    Commands processed by other scripts
        //  Script                  Script commands
        //  Menu                    Menu commands

        } else if (abbrP(command, "sc") || abbrP(command, "me")) {
            if ((abbrP(command, "me") && abbrP(sparam, "sh")) &&
                ((argn < 4) || (!abbrP(llList2String(args, -1), "co")))) {
                scriptSuspend = TRUE;
            }
            llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);

        } else {
            tawk("Huh?  \"" + message + "\" undefined.  Chat /" +
                (string) commandChannel + " help for instructions.");
            return FALSE;
        }
        return TRUE;
    }

    default {

        state_entry() {
            owner = whoDat = llGetOwner();
            ownerName =  llKey2Name(owner);  //  Save name of owner

//          llSetText("Double Pendulum\n/" + (string) commandChannel, < 0, 1, 0 >, 1);
llSetText("", ZERO_VECTOR, 0);

            bob1 = findLinkNumber("Bob 1");
            bob2 = findLinkNumber("Bob 2");
            rod1 = findLinkNumber("Rod 1");
            rod2 = findLinkNumber("Rod 2");

            globe = findLinkNumber("Globe");
            plinth = findLinkNumber("Plinth");
/*
integer i;
for (i = 0; i <= 7; i++) {
//    llLinkSitTarget(i, ZERO_VECTOR, ZERO_ROTATION);
    llSetLinkCamera(i, ZERO_VECTOR, ZERO_VECTOR);
}
*/
//llSitTarget( ZERO_VECTOR, ZERO_ROTATION);

            //  Count how many line plotters we have in the inventory

            fuisWid = fuis(0.01);           // Initialise constant plot line width
            linePlotters = 0;
            while (llGetInventoryType("Line plotter " + (string) (linePlotters + 1)) ==
                        INVENTORY_SCRIPT) {
                linePlotters++;
            }

            llLinkParticleSystem(bob2, [ ]);
            clearPaths();
            resetModel();
            updateGlobe();
            updateBobs();
            displayModel();

            //  Start listening on the command chat channel
            commandH = llListen(commandChannel, "", NULL_KEY, "");
            llOwnerSay("Listening on /" + (string) commandChannel);

            //  Reset the script and menu processors
            llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
            llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
            llSleep(0.1);           // Allow script process to finish reset
            sendSettings();

            //  If a configuration script exists, run it
            if (llGetInventoryType(configScript) == INVENTORY_NOTECARD) {
                llMessageLinked(LINK_THIS, LM_SP_RUN, configScript, whoDat);
            }
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            processCommand(id, message, FALSE);
        }

        link_message(integer sender, integer num, string str, key id) {

            //  Script Processor messages

            //  LM_SP_READY (57): Script ready to read

            if (num == LM_SP_READY) {
                scriptActive = TRUE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", id);  // Get the first line

            //  LM_SP_INPUT (55): Next executable line from script

            } else if (num == LM_SP_INPUT) {
                if (str != "") {                // Process only if not hard EOF
                    scriptSuspend = FALSE;
                    // Some commands set scriptSuspend
                    integer stat = processCommand(id, str, TRUE);
                    if (stat) {
                        if (!scriptSuspend) {
                            llMessageLinked(LINK_THIS, LM_SP_GET, "", id);
                        }
                    } else {
                        //  Error in script command.  Abort script input.
                        scriptActive = scriptSuspend = FALSE;
                        llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
                        tawk("Script terminated.");
                    }
                }

            //  LM_SP_EOF (56): End of file reading from script

            } else if (num == LM_SP_EOF) {
                scriptActive = FALSE;           // Mark script input complete

            //  LM_SP_ERROR (58): Error processing script request

            } else if (num == LM_SP_ERROR) {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Script error: " + str);
                scriptActive = scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);

            //  LM_MP_RESUME (274): Resume script after menu selection or timeout

            } else if (num == LM_MP_RESUME) {
                scriptResume();
            }
        }

        //  Detect when an avatar sits on the bob

        changed(integer change) {
            key seated = llAvatarOnLinkSitTarget(bob2);
            if (change & CHANGED_LINK) {
                if ((seated == NULL_KEY) && sit) {
                    //  Avatar has stood up, departing
                    sit = FALSE;
                } else if ((!sit) && (seated != NULL_KEY)) {
                    //  Avatar has sat on the bob
                    sit = TRUE;
                }
            }
        }

        //  The timer event handles updates while animating

        timer() {
           updateModel();
            if (runEndTime >= 0) {
                if (llGetTime() >= runEndTime) {
                    running = FALSE;
                    llSetTimerEvent(0);
                    scriptResume();
                }
            }
         }
    }
