    /*
                flPlotLine Parallel Plotter
    */

    key owner;                          // Owner UUID
    key whoDat;                         // Person we're talking to

    integer plotterID;                  // Our plotter number

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

    /*  siuf  --  Decode base64-encoded floating point number

        The siuf function decodes a floating point number encoded with
        fuis.  */

    float siuf(string b) {
        integer a = llBase64ToInteger(b);
        if (0x7F800000 & ~a) {
            return llPow(2, (a | !a) + 0xffffff6a) *
                      (((!!(a = (0xff & (a >> 23)))) * 0x800000) |
                       (a & 0x7fffff)) * (1 | (a >> 31));
        }
        return (!(a & 0x7FFFFF)) * (float) "inf" * ((a >> 31) | 1);
    }

    /*  Decode base64-encoded vector

        This is a helper function to decode a vector packed as three
        consecutive siuf-encoded floats.  */

    vector sv(string b) {
        return(< siuf(llGetSubString(b, 0, 5)),
                 siuf(llGetSubString(b, 6, 11)),
                 siuf(llGetSubString(b, 12, -1)) >);
    }

    //  flPlotLine  --  Plot a line by rezzing a prim in space

    //  List of selectable diameters for lines
    list flPlotLineDiam = [ 0.01, 0.015, 0.02, 0.025 ];
    integer flPlotPerm = FALSE;     // Use permanent objects for plotted lines ?

    flPlotLine(vector fromPoint, vector toPoint,
               vector colour, float diameter) {
        float length = llVecDist(fromPoint, toPoint);
        vector midPoint = (fromPoint + toPoint) / 2;

        //  Encode length as integer from 0 to 1023 (10 bits)
        integer ilength = llRound((length * 100) - 0.01);
        if (ilength > 1023) {
            ilength = 1023;
        }

        //  Encode colour as RGB with 16 levels of colour (12 bits)
        integer icolour = (llRound(colour.x * 15) << 8) |
                          (llRound(colour.y * 15) << 4) |
                           llRound(colour.z * 15);

        /*  Find the closest match to the requested diameter
            among the options available in flPlotLineDiam  */

        integer bestdia;
        float bestdiamatch = 1e20;
        integer diax;

        for (diax = 0; diax < 4; diax++) {
            float d = llFabs(diameter - llList2Float(flPlotLineDiam, diax));
            if (d < bestdiamatch) {
                bestdiamatch = d;
                bestdia = diax;
            }
        }

        string lineObj = "flPlotLine";
        if (flPlotPerm) {
            lineObj = "flPlotLine Permanent";
        }
        llRezObject(lineObj, midPoint, ZERO_VECTOR,
            llRotBetween(<0, 0, 1>, llVecNorm(toPoint - midPoint)),
            ((bestdia << 22) | (icolour << 10) | ilength)
        );
    }

    default {
        state_entry() {
            owner = whoDat = llGetOwner();
            plotterID = (integer) llGetSubString(llGetScriptName(), 12, -1);
        }

        link_message(integer sender, integer num, string str, key id) {

            //  LM_PL_DRAW (471): Draw line

            if (num == LM_PL_DRAW) {
                vector from = sv(llGetSubString(str, 0, 17));
                vector to = sv(llGetSubString(str, 18, 35));
                vector colour = sv(llGetSubString(str, 36, 53));
                float dia = siuf(llGetSubString(str, 54, 59));
                flPlotPerm = (integer) llGetSubString(str, 60, 60);
                integer pid = (integer) llGetSubString(str, 61, -1);
                if (pid == plotterID) {
                    flPlotLine(
                        from,               // From point
                        to,                 // To point
                        colour,             // Colour
                        dia                 // Diameter
                    );
                }
            }
        }
    }
