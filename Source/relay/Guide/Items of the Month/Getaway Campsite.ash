
RegisterResourceGenerationFunction("IOTMGetawayCampsiteGenerateResource");
void IOTMGetawayCampsiteGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!__iotms_usable[lookupItem("Distant Woods Getaway Brochure")]) return;
	
	item firewood = lookupItem("stick of firewood");
	int cloud_buffs_left = clampi(1 - get_property_int("_campAwayCloudBuffs"), 0, 1);
    int smile_buffs_left = clampi(3 - get_property_int("_campAwaySmileBuffs"), 0, 3);
    
    if (cloud_buffs_left > 0) { // && lookupEffect("That's Just Cloud-Talk, Man").have_effect() == 0)
    	string [int] description;
        description.listAppend("Large +stat buff. Gaze at the stars.");
        if (firewood.have() || lookupItem("campfire smoke").have())
        	description.listAppend("If you don't see it, you could make and use campfire smoke first.");
        resource_entries.listAppend(ChecklistEntryMake("__item Newbiesport&trade; tent", "place.php?whichplace=campaway", ChecklistSubentryMake("Cloud-talk buff obtainable", "", description), 0).ChecklistEntryTagEntry("getaway campsite"));
    }
    if (smile_buffs_left > 0) { // && lookupEffect("That's Just Cloud-Talk, Man").have_effect() == 0)
        // Implementation of campSmile.ash by @fredg1
        string [int] [string] buffCycle;
            buffCycle [0] ["effect"] = my_sign() == "Blender" ? "+50% booze drop" : "+25% booze drop" ;
            buffCycle [0] ["name"] = "Blender";
            buffCycle [1] ["effect"] = my_sign() == "Packrat" ? "+50% meat" : "+25% meat" ;
            buffCycle [1] ["name"] = "Packrat";
            buffCycle [2] ["effect"] = my_sign() == "Mongoose" ? "+20% critical hit" : "+10% critical hit" ;
            buffCycle [2] ["name"] = "Mongoose";
            buffCycle [3] ["effect"] = my_sign() == "Wallaby" ? "+20% spell critical hit" : "+10% spell critical hit" ;
            buffCycle [3] ["name"] = "Wallaby";
            buffCycle [4] ["effect"] = my_sign() == "Vole" ? "+10~30 HP/adventure" : "+5~15 HP/adventure" ;
            buffCycle [4] ["name"] = "Vole";
            buffCycle [5] ["effect"] = my_sign() == "Platypus" ? "+5 familiar experience" : "+3 familiar experience" ;
            buffCycle [5] ["name"] = "Platypus";
            buffCycle [6] ["effect"] = my_sign() == "Opossum" ? "+100% candy drop" : "+50% candy drop" ;
            buffCycle [6] ["name"] = "Opossum";
            buffCycle [7] ["effect"] = my_sign() == "Marmot" ? "+8~12 MP/adventure" : "+4~6 MP/adventure" ;
            buffCycle [7] ["name"] = "Marmot";
            buffCycle [8] ["effect"] = my_sign() == "Wombat" ? "Damage Absorption +100" : "Damage Absorption +50" ;
            buffCycle [8] ["name"] = "Wombat";

        boolean isLeapYear(int year) {
            if (year % 400 == 0) return true;
            else if (year % 100 == 0) return false;
            else if (year % 4 == 0) return true;
            else return false;
        }

        int getOffset(int year) { // made by @Skaazi
            int offset = 5; // for 2020
            for ( int i = year; i > 2020; i-- ) {
                if ( isLeapYear( i - 1 ) ) { offset += 1; }
                offset += 365;
            }
            return offset % 9;
        }

        string [int] description;
        description.listAppend("Gaze at the stars.");

        int offset = getOffset(format_date_time("yyyyMMdd", today_to_string(), "yyyy").to_int());
        int todaysArbitraryNumber = format_date_time("yyyyMMdd", today_to_string(), "D").to_int() + my_path_id() + offset;
        int todaysCycleNumber = todaysArbitraryNumber % 9;
        
        description.listAppend("Will get: " + (my_sign() == buffCycle [todaysCycleNumber] ["name"] ? "Big " : "") + "Smile of the " + buffCycle [todaysCycleNumber] ["name"] + " (" + buffCycle [todaysCycleNumber] ["effect"] + ")");

        resource_entries.listAppend(ChecklistEntryMake("__item Newbiesport&trade; tent", "place.php?whichplace=campaway", ChecklistSubentryMake(pluralise(smile_buffs_left, "smile buff", "smile buffs") + " obtainable", "20 turns", description), 5).ChecklistEntryTagEntry("getaway campsite"));
    }
    if (firewood.have() && __misc_state["in run"]) {
    	string [int] description;
     
        string [int] various_options;
        if (__misc_state["can eat just about anything"])
        	various_options.listAppend("food");
        if (firewood.available_amount() >= 5 && myPathId() != PATH_GELATINOUS_NOOB) {
            if (!lookupItem("whittled tiara").have())
            	various_options.listAppend("whittled tiara for +elemental damage");
            if (!lookupItem("whittled shorts").have())
                various_options.listAppend("whittled shorts for +2 all res");
            if (!lookupItem("whittled flute").have())
                various_options.listAppend("whittled flute for +25% meat");
            if (firewood.available_amount() >= 10) {
            	if (!lookupItem("whittled bear figurine").have() && !__misc_state["familiars temporarily blocked"])
                    various_options.listAppend("whittled bear figurine for +5 familiar weight");
                if (!lookupItem("whittled owl figurine").have())
                    various_options.listAppend("whittled owl figurine for +20 ML");
                if (!lookupItem("whittled fox figurine").have())
                    various_options.listAppend("whittled fox figurine figurine for +50% init");
            }
            if (firewood.available_amount() >= 100 && !lookupItem("whittled walking stick").have())
                various_options.listAppend("whittled walking stick for a bunch of stuff");
        }
        if (various_options.count() > 0)
        	description.listAppend(various_options.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
        resource_entries.listAppend(ChecklistEntryMake("__item Newbiesport&trade; tent", "shop.php?whichshop=campfire", ChecklistSubentryMake(pluralise(firewood), "", description), 5).ChecklistEntryTagEntry("getaway campsite"));
    }
}
