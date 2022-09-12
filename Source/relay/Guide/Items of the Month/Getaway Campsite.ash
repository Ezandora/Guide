
RegisterResourceGenerationFunction("IOTMGetawayCampsiteGenerateResource");
void IOTMGetawayCampsiteGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!__iotms_usable[$item[Distant Woods Getaway Brochure]]) return;
	
	item firewood = $item[stick of firewood];
	int cloud_buffs_left = clampi(1 - get_property_int("_campAwayCloudBuffs"), 0, 1);
    int smile_buffs_left = clampi(3 - get_property_int("_campAwaySmileBuffs"), 0, 3);
    
    if (cloud_buffs_left > 0)// && $effect[That's Just Cloud-Talk, Man].have_effect() == 0)
    {
    	string [int] description;
        description.listAppend("Large +stat buff. Gaze at the stars.");
        if (firewood.have() || $item[campfire smoke].have())
        	description.listAppend("If you don't see it, you could make and use campfire smoke, first.");
        resource_entries.listAppend(ChecklistEntryMake(535, "__item Newbiesport&trade; tent", "place.php?whichplace=campaway", ChecklistSubentryMake("Cloud-talk buff obtainable", "", description), 0).ChecklistEntryTag("getaway campsite").ChecklistEntrySetCategory("buff").ChecklistEntrySetSpecificImage("__effect That's Just Cloud-Talk, Man"));
    }
    if (smile_buffs_left > 0)// && $effect[That's Just Cloud-Talk, Man].have_effect() == 0)
    {
        resource_entries.listAppend(ChecklistEntryMake(536, "__item Newbiesport&trade; tent", "place.php?whichplace=campaway", ChecklistSubentryMake(pluralise(smile_buffs_left, "smile buff", "smile buffs") + " obtainable", "", "Various minor effects. Gaze at the stars."), 5).ChecklistEntryTag("getaway campsite").ChecklistEntrySetCategory("buff").ChecklistEntrySetSpecificImage("__effect Smile of the " + my_sign()));
    }
    if (firewood.have() && __misc_state["in run"])
    {
    	string [int] description;
     
        string [int] various_options;
        if (__misc_state["can eat just about anything"])
        	various_options.listAppend("food");
        if (firewood.available_amount() >= 5 && my_path_id_legacy() != PATH_GELATINOUS_NOOB)
        {
            if (!$item[whittled tiara].have())
            	various_options.listAppend("whittled tiara for +elemental damage");
            if (!$item[whittled shorts].have())
                various_options.listAppend("whittled shorts for +2 all res");
            if (!$item[whittled flute].have())
                various_options.listAppend("whittled flute for +25% meat");
            if (firewood.available_amount() >= 10)
            {
            	if (!$item[whittled bear figurine].have() && !__misc_state["familiars temporarily blocked"])
                    various_options.listAppend("whittled bear figurine for +5 familiar weight");
                if (!$item[whittled owl figurine].have())
                    various_options.listAppend("whittled owl figurine for +20 ML");
                if (!$item[whittled fox figurine].have())
                    various_options.listAppend("whittled fox figurine figurine for +50% init");
            }
            if (firewood.available_amount() >= 100 && !$item[whittled walking stick].have())
                various_options.listAppend("whittled walking stick for a bunch of stuff");
        }
        if (various_options.count() > 0)
        	description.listAppend(various_options.listJoinComponents(", ", "or").capitaliseFirstLetter() + ".");
        resource_entries.listAppend(ChecklistEntryMake(537, "__item Newbiesport&trade; tent", "shop.php?whichshop=campfire", ChecklistSubentryMake(pluralise(firewood), "", description), 5).ChecklistEntryTag("getaway campsite").ChecklistEntrySetSpecificImage("__item " + firewood));
    }
}
