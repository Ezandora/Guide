
void SDungeonsOfDoomGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    //Let's see...
    //Normally, we assume the best path is to fax a quantum mechanic (in HC) or pull a large box (in SC)
    //However, that won't work for paths without a fax machine, or for people without a VIP key, or for people who desire to open the dungeons of doom regardless.
    //So, we suggest it in those cases.
    //We also want to work in aftercore - if they haven't unlocked the DOD yet and they've started, give suggestions.
    
    //lastPlusSignUnlock is set by the oracle, not reading the book.
    string title = "Dungeons of Doom";
    string image_name = "Dungeons of Doom";
    string [int] description;
    string [int] modifiers;
    string url = "da.php";
    
    boolean should_output = true;
    
    int turns_attempted = $location[The Enormous Greater-Than Sign].turnsAttemptedInLocation() + $location[the dungeons of doom].turnsAttemptedInLocation();
    
    //Should we unlock/farm the dungeons of doom?
    if (my_basestat(my_primestat()) < 45) //not yet
        return;
    if (!__misc_state["In run"] && turns_attempted == 0) //no, they haven't started yet
        return;
    if (__misc_state["In run"] && __quest_state["Level 13"].state_boolean["past gates"]) //no need for potions
        return;
    if (__misc_state["In run"] && turns_attempted == 0) //in run, but they haven't gone there
    {
        //Let's see.
        //They haven't adventured there yet, so we should only suggest this if it's a good idea.
        if (__misc_state["fax accessible"] && __misc_state["can use clovers"] || !in_hardcore()) //they can fax quantum mechanics and use clovers
            return;
    }
    //They are in run, can't fax quantum mechanics and are in hardcore. So, we'll proceed.
    
    if (get_property_int("lastPlusSignUnlock") == my_ascensions())
    {
        should_output = false;
        //Dungeons of doom unlocked.
        if ($item[plus sign].available_amount() > 0)
        {
            should_output = true;
            //Read plus sign:
            title = "Read plus sign";
            image_name = "__item plus sign";
            url = "inventory.php?which=3";
        }
        else if (__misc_state["In run"])
        {
            int bang_potions_identified = 0;
            foreach s in $strings[lastBangPotion819,lastBangPotion820,lastBangPotion821,lastBangPotion822,lastBangPotion823,lastBangPotion824,lastBangPotion825,lastBangPotion826,lastBangPotion827]
            {
                if (get_property(s).length() > 0)
                    bang_potions_identified += 1;
            }
            if (get_property_int("lastBangPotionReset") != my_ascensions())
                bang_potions_identified = 0;
            //Dungeon of doom unlocked.
            //FIXME do more
            //Suggest identifying potions?
            //Actually. Suggest farming one large box and using a clover, unless bad moon or if they need potions right now and lack three spare drunkenness
            if (__misc_state["can use clovers"])
            {
                if ($items[blessed large box].available_amount() > 0)
                    return;
                if ($items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() == 0)
                    return;
                should_output = true;
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Run +item in the dungeons of doom, find a large box.|Meatpaste with clover to make a blessed large box. (one of each potion)");
                description.listAppend(bang_potions_identified + "/9 bang potions identified.");
            }
            else
            {
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Find potions, identify them in combat.|Or acquire one of each, then use with 3 drunkenness available.");
                description.listAppend(bang_potions_identified + "/9 bang potions identified.");
            }
        }
    }
    else
    {
        boolean adventuring_in_sign = true;
        string [int] tasks;
        if (my_meat() < 1000)
            tasks.listAppend("acquire 1000 meat");
        if ($item[plus sign].available_amount() == 0)
            tasks.listAppend("acquire plus sign from non-combat");
        else if ($effect[Teleportitis].have_effect() == 0)
            tasks.listAppend("acquire teleportitis from non-combat or uppercase Q hitting you");
        else
        {
            adventuring_in_sign = false;
            tasks.listAppend("find the oracle, pay for major consultation");
        }
        
        title = "Unlock dungeons of doom";
        if (adventuring_in_sign)
        {
            modifiers.listAppend("-combat");
            if (!__quest_state["Level 13"].state_boolean["past gates"])
            {
                modifiers.listAppend("+150%/+400% item");
                description.listAppend("Run -combat/+item in the enormous greater-than sign.");
            }
            else
                description.listAppend("Run -combat in the enormous greater-than sign.");
            
        }
        description.listAppend(tasks.listJoinComponents(", ", "then").capitalizeFirstLetter() + ".");
    }
    
    if (should_output)
        optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(title, modifiers, description), $locations[the enormous greater-than sign,the dungeons of doom]));
}