
    //  Pendulum bob

    integer sit = FALSE;                // Is somebody sitting on this edge ?
    key seated = NULL_KEY;              // UUID of seated avatar
    vector sitPos = < 0.6, 0.09, -0.6 >;  // Initial sit position
    vector sitRot = < 0, 90, 0 >;       // Initial sit rotation
    vector camOffset = <0, 0, 2>;       // Offset of camera lens from sit position
    vector camAng = <0, 0, 0>;          // Camera look-at point relative to camOffset

    //  Bob messages
    integer LM_BO_MOVE = 91;            // Bob has moved or rotated

    /*  flMoveSittingAvatar  --  Move an avatar sitting on an edge
                                 (specified by its link number or
                                 LINK_THIS) to a new position and
                                 rotation relative to the edge.  */
/*
    flMoveSittingAvatar(integer link, vector pos, rotation rot) {
        key user = llAvatarOnLinkSitTarget(link);
        if (user) {
            vector size = llGetAgentSize(user); // Make sure this is an avatar
            if (size != ZERO_VECTOR) {
                /*  Since there may be avatars sitting on more than one
                    link in an object, search through the link numbers
                    to find the avatar whose key matches the one sitting
                    on this link.
                integer linkNum = llGetNumberOfPrims();
                do {
                    if (user == llGetLinkKey(linkNum)) {
                        //  We need to make the position and rotation local to the current prim
                        list local;
                        if (llGetLinkKey(link) != llGetLinkKey(1)) {
                            local = llGetLinkPrimitiveParams(link, [ PRIM_POS_LOCAL, PRIM_ROT_LOCAL ]);
                        }
                        //  Magic numbers to correct for flakiness in sitting avatar position
                        float fAdjust = ((((0.008906 * size.z) + -0.049831) * size.z) + 0.088967) * size.z;
                        llSetLinkPrimitiveParamsFast(linkNum, [
                            PRIM_POS_LOCAL, ((pos + <0, 0, 0.4> - (llRot2Up(rot) * fAdjust)) *
                                llList2Rot(local, 1)) + llList2Vector(local, 0),
//                            PRIM_ROT_LOCAL, rot * llList2Rot(local, 1)
PRIM_ROT_LOCAL,  llAxisAngle2Rot(<0, 0, 1>, 0) * llList2Rot(local, 1)
                        ]);
                        return;
                    }
                 } while (--linkNum);
            } else {
                //  In case we cannot find the avatar, un-sit the user by key
                llUnSit(user);
            }
        }
    }
*/

    //  adjustAvatar  --  Reposition avatar to new location of seat

    adjustAvatar() {
        key sitter = llAvatarOnLinkSitTarget(LINK_THIS);
        if (sitter != NULL_KEY) {
            vector size = llGetAgentSize(sitter);   // Is sitter an avatar ?
            if (size != ZERO_VECTOR) {
                /*  Since there may be avatars sitting on more than one
                    link in an object, search through the link numbers
                    to find the avatar whose key matches the one sitting
                    on this link.  */
                integer linkNum = llGetNumberOfPrims();
                integer avlink;
                for (avlink = 1; avlink <= linkNum; avlink++) {
                    if (sitter == llGetLinkKey(avlink)) {
//float pFudge = ((((0.008906 * size.z) + -0.049831) * size.z) + 0.088967) * size.z;
//vector sPos = (llGetLocalPos() + <0, 0, 0.4> - (llRot2Up(llGetLocalRot()) * pFudge)) * llGetLocalRot();
llSetLinkPrimitiveParamsFast(avlink, [
PRIM_ROT_LOCAL, llEuler2Rot(<-PI_BY_TWO, 0, -PI_BY_TWO>),
PRIM_POS_LOCAL, llGetLocalPos() + <0, 0.7, 0.4>
]);
                        avlink = linkNum + 1;           // Escape from loop
                    }
                }
            }
        }
    }

    default {

        state_entry() {
//            llLinkSitTarget(LINK_THIS, sitPos, llEuler2Rot(sitRot * DEG_TO_RAD));
            llLinkSitTarget(LINK_THIS, sitPos, llEuler2Rot(<270, 0, 0> * DEG_TO_RAD));
            llSetLinkCamera(LINK_THIS, camOffset, camAng);
//llOwnerSay("Init bob");
        }

        link_message(integer sender, integer num, string str, key id) {
            if (num == LM_BO_MOVE) {
//llOwnerSay("BO_MOVE");
                if (sit) {
                    adjustAvatar();
/*
//                    flMoveSittingAvatar(LINK_THIS, sitPos, llEuler2Rot(sitRot * DEG_TO_RAD));
                    key sitter = llAvatarOnLinkSitTarget(LINK_THIS);
                    if (sitter != NULL_KEY) {
                        vector size = llGetAgentSize(sitter);   // Is sitter an avatar ?
                        if (size != ZERO_VECTOR) {
                            /*  Since there may be avatars sitting on more than one
                                link in an object, search through the link numbers
                                to find the avatar whose key matches the one sitting
                                on this link.
                            integer linkNum = llGetNumberOfPrims();
                            integer avlink;
                            for (avlink = 1; avlink <= linkNum; avlink++) {
                                if (sitter == llGetLinkKey(avlink)) {
//float pFudge = ((((0.008906 * size.z) + -0.049831) * size.z) + 0.088967) * size.z;
//vector sPos = (llGetLocalPos() + <0, 0, 0.4> - (llRot2Up(llGetLocalRot()) * pFudge)) * llGetLocalRot();
llSetLinkPrimitiveParamsFast(avlink, [
PRIM_POS_LOCAL, llGetLocalPos() + <0.5, 0.5, 0>,
PRIM_ROT_LOCAL, llEuler2Rot(<270, 0, 0> * DEG_TO_RAD) ]);
                                }
                            }
                        }
                    }
*/
                }
            }
        }

        /*  The changed event handler detects when an avatar
            sits on the bob or stands up and departs.  We need
            to know if somebody is sitting so that we
            can move the seated avatar with the bob while we're
            running the animation.  */

        changed(integer change) {
            seated = llAvatarOnLinkSitTarget(LINK_THIS);
            if (change & CHANGED_LINK) {
                if ((seated == NULL_KEY) && sit) {
                    //  Avatar has stood up, departing
                    sit = FALSE;
//llOwnerSay("Stood");
                } else if ((!sit) && (seated != NULL_KEY)) {
                    //  Avatar has sat on the edge
                    seated = llAvatarOnSitTarget();
                    sit = TRUE;
                    adjustAvatar();
//llOwnerSay("Sat");
                }
            }
        }
    }
