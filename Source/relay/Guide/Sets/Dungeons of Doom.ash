
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
    
    if (my_basestat(my_primestat()) < 45) //not yet
        return;
    if (turns_attempted == 0) //no, they haven't started yet
        return;
    
    if (get_property_ascension("lastPlusSignUnlock"))
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
            description.listAppend("Run -combat in the enormous greater-than sign.");
            
        }
        description.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
    }
    
    if (should_output)
        optional_task_entries.listAppend(ChecklistEntryMake(282, image_name, url, ChecklistSubentryMake(title, modifiers, description), $locations[the enormous greater-than sign,the dungeons of doom]));
}
