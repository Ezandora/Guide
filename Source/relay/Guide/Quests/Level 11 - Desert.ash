void QLevel11DesertInit()
{
    QuestState state;
    QuestStateParseMafiaQuestProperty(state, "questL11Desert");
    state.quest_name = "Desert Quest";
    state.image_name = "Pyramid"; //"__item instant karma";
    
    int gnasir_progress = get_property_int("gnasirProgress");
    
    state.state_boolean["Stone Rose Given"] = (gnasir_progress & 1) > 0;
    state.state_boolean["Black Paint Given"] = (gnasir_progress & 2) > 0;
    state.state_boolean["Killing Jar Given"] = (gnasir_progress & 4) > 0;
    state.state_boolean["Manual Pages Given"] = (gnasir_progress & 8) > 0;
    state.state_boolean["Wormridden"] = (gnasir_progress & 16) > 0;
    
    state.state_int["Desert Exploration"] = get_property_int("desertExploration");
    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
        state.state_int["Desert Exploration"] = 100;
    state.state_boolean["Desert Explored"] = (state.state_int["Desert Exploration"] == 100);
    if (state.finished) //in case mafia doesn't detect it properly
    {
        state.state_int["Desert Exploration"] = 100;
        state.state_boolean["Desert Explored"] = true;
    }
        
    
    
    boolean have_uv_compass_equipped = false;
    
    if (!__misc_state["can equip just about any weapon"])
        have_uv_compass_equipped = true;
    if ($item[UV-resistant compass].equipped_amount() > 0)
        have_uv_compass_equipped = true;
    if ($item[ornate dowsing rod].equipped_amount() > 0)
        have_uv_compass_equipped = true;
    
    state.state_boolean["Have UV-Compass eqipped"] = have_uv_compass_equipped;

    __quest_state["Level 11 Desert"] = state;
}

void QLevel11DesertGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 11 Desert"].in_progress && __quest_state["Level 11"].mafia_internal_step <3)
        return;
    QuestState base_quest_state = __quest_state["Level 11 Desert"];
    ChecklistSubentry subentry;
    subentry.header = base_quest_state.quest_name;
    string url = "";

    if (base_quest_state.state_boolean["Desert Explored"])
        return;
        
    url = "place.php?whichplace=desertbeach";
    int exploration = base_quest_state.state_int["Desert Exploration"];
    int exploration_remaining = 100 - exploration;
    float exploration_per_turn = 1.0;
    if ($item[ornate dowsing rod].available_amount() > 0)
        exploration_per_turn += 2.0; //FIXME make completely accurate for first turn? not enough information available
    else if ($item[uv-resistant compass].available_amount() > 0)
        exploration_per_turn += 1.0;
    if (my_path_id() == PATH_LICENSE_TO_ADVENTURE && get_property_boolean("bondDesert"))
        exploration_per_turn += 2.0;
    
    boolean have_blacklight_bulb = (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && get_property("peteMotorbikeHeadlight") == "Blacklight Bulb");
    if (have_blacklight_bulb)
        exploration_per_turn += 2.0;
    //FIXME deal with ultra-hydrated
    int combats_remaining = exploration_remaining;
    combats_remaining = ceil(to_float(exploration_remaining) / exploration_per_turn);
    subentry.entries.listAppend(exploration_remaining + "% exploration remaining. (" + pluralise(combats_remaining, "combat", "combats") + ")");
    if ($effect[ultrahydrated].have_effect() == 0)
    {
        if (__last_adventure_location == $location[the arid, extra-dry desert])
        {
            string [int] description;
            description.listAppend("Adventure in the Oasis.");
            if ($items[ten-leaf clover, disassembled clover].available_amount() > 0)
                description.listAppend("Potentially clover for 20 turns, versus 5.");
            task_entries.listAppend(ChecklistEntryMake("__effect ultrahydrated", "place.php?whichplace=desertbeach", ChecklistSubentryMake("Acquire ultrahydrated effect", "", description), -11));
        }
        //if (exploration > 0)
            //subentry.entries.listAppend("Need ultra-hydrated from The Oasis. (potential clover for 20 turns)");
    }
    if (exploration < 10)
    {
        int turns_until_gnasir_found = -1;
        if (exploration_per_turn != 0.0)
            turns_until_gnasir_found = ceil(to_float(10 - exploration) / exploration_per_turn);
        
        subentry.entries.listAppend("Find Gnasir after " + pluralise(turns_until_gnasir_found, "turn", "turns") + ".");
    }
    else if (get_property_int("gnasirProgress") == 0 && exploration <= 14 && !$location[the arid, extra-dry desert].noncombat_queue.contains_text("A Sietch in Time"))
    {
        subentry.entries.listAppend("Find Gnasir next turn.");
    }
    else
    {
        boolean need_pages = false;
        if (!base_quest_state.state_boolean["Black Paint Given"])
        {
            if ($item[can of black paint].available_amount() == 0)
            {
                if (black_market_available())
                    subentry.entries.listAppend("Buy can of black paint, give it to Gnasir.");
            }
            else
                subentry.entries.listAppend("Give can of black paint to Gnasir.");
                
        }
        if (!base_quest_state.state_boolean["Stone Rose Given"])
        {
            if ($item[stone rose].available_amount() > 0)
                subentry.entries.listAppend("Give stone rose to Gnasir.");
            else
            {
                string line = "Potentially adventure in Oasis for stone rose";
                line += ".";
                if (delayRemainingInLocation($location[the oasis]) > 0)
                {
                    string hipster_text = "";
                    if (__misc_state["have hipster"])
                    {
                        hipster_text = " (use " + __misc_state_string["hipster name"] + ")";
                    }
                    line += "|Delay for " + pluralise(delayRemainingInLocation($location[the oasis]), "turn", "turns") + hipster_text + ".";
                }
                subentry.entries.listAppend(line);
            }
        }
        if (!base_quest_state.state_boolean["Manual Pages Given"])
        {
            if ($item[worm-riding manual page].available_amount() == 15)
                subentry.entries.listAppend("Give Gnasir the worm-riding manual pages.");
            else
            {
                int remaining = 15 - $item[worm-riding manual page].available_amount();
                
                subentry.entries.listAppend("Find " + pluralise(remaining, "more worm-riding manual page", "more worm-riding manual pages") + ".");
                need_pages = true;
            }
            
        }
        else if (!base_quest_state.state_boolean["Wormridden"])
        {
            subentry.modifiers.listAppend("rhythm");
            if ($item[drum machine].available_amount() > 0)
            {
                subentry.entries.listAppend("Use drum machine.");
            }
        }
        if (!base_quest_state.state_boolean["Wormridden"] && $item[drum machine].available_amount() == 0)
        {
            if (base_quest_state.state_boolean["Manual Pages Given"])
                subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), use drum machine.");
            else
                subentry.entries.listAppend("Potentially acquire drum machine from blur. (+234% item), collect/return pages, then use drum machine.");
            subentry.modifiers.listAppend("+234% item");
        }
        if (!base_quest_state.state_boolean["Killing Jar Given"])
        {
            if ($item[killing jar].available_amount() > 0)
                subentry.entries.listAppend("Give Gnasir the killing jar.");
            else
                subentry.entries.listAppend("Potentially find killing jar. (banshee, haunted library, 10% drop, YR?)");
        }
        
        if (__misc_state["have hipster"])
        {
            subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
            
            string line = __misc_state_string["hipster name"].capitaliseFirstLetter() + " for free combats";
            if (need_pages)
                line += " and manual pages";
            line += ".";
            subentry.entries.listAppend(line);
        }
    }
    if ($effect[ultrahydrated].have_effect() == 0)
    {
        if (exploration > 0)
            subentry.entries.listAppend("Acquire ultrahydrated effect from oasis. (potential clover for 20 adventures)");
    }
    if ($item[desert sightseeing pamphlet].available_amount() > 0)
    {
        if ($item[desert sightseeing pamphlet].available_amount() == 1)
            subentry.entries.listAppend("Use your desert sightseeing pamphlet. (+15% exploration)");
        else
            subentry.entries.listAppend("Use your desert sightseeing pamphlets. (+15% exploration)");
    }
    if (!base_quest_state.state_boolean["Have UV-Compass eqipped"] && __quest_state["Level 11 Desert"].state_int["Desert Exploration"] < 99)
    {
        boolean should_output_compass_in_red = true;
        string line = "";
        string line_extra = "";
        if ($item[ornate dowsing rod].available_amount() > 0)
        {
            line = "Equip the ornate dowsing rod.";
            url = "inventory.php?which=2";
        }
        else
        {
            if ($item[uv-resistant compass].available_amount() == 0 && !(my_path_id() == PATH_LICENSE_TO_ADVENTURE && get_property_boolean("bondDesert")))
            {
                line = "Acquire";
                if (have_blacklight_bulb)
                {
                    line = "Possibly acquire";
                    should_output_compass_in_red = false;
                }
              
                line += " UV-resistant compass, equip for faster desert exploration. (shore vacation)";
                if ($item[Shore Inc. Ship Trip Scrip].available_amount() > 0)
                    url = "shop.php?whichshop=shore";
              
                if ($item[odd silver coin].available_amount() > 0 || $item[grimstone mask].available_amount() > 0 || get_property("grimstoneMaskPath") != "") //FIXME check for the correct grimstoneMaskPath
                {
                    line_extra += "|Or acquire ornate dowsing rod from Paul's Boutique? (5 odd silver coins)";
                }
              
            }
            else if ($item[uv-resistant compass].available_amount() > 0)
            {
                line = "Equip the UV-resistant compass.";
                url = "inventory.php?which=2";
            }
        }
        if (line != "")
        {
            if (should_output_compass_in_red)
                line = HTMLGenerateSpanFont(line, "red");
            line += line_extra;
            subentry.entries.listAppend(line);
        }
    }
    task_entries.listAppend(ChecklistEntryMake(base_quest_state.image_name, url, subentry, $locations[the arid\, extra-dry desert,the oasis]));
}
