
//_macrometeoriteUses
//_meteorShowerUses
RegisterResourceGenerationFunction("IOTMMeteorLoreGenerateResource");
void IOTMMeteorLoreGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!lookupSkill("Meteor Lore").have_skill())
        return;
    if (!__misc_state["in run"]) return;
    if (!mafiaIsPastRevision(18174)) return;
    if (myPathId() == PATH_G_LOVER) return;
    
    ChecklistEntry entry;
    entry.image_lookup_name = "__skill Meteor Lore";
    entry.importance_level = 3;
    if (get_property_int("_macrometeoriteUses") < 10)
    {
        int macrometeorite_uses_remaining = clampi(10 - get_property_int("_macrometeoriteUses"), 0, 10);
        string [int] description;
        description.listAppend("Reroll a monster to another in the area.");
        
        string [int] useful_places;
        if (spleen_limit() > 0 && lookupFamiliar("space jellyfish").familiar_is_usable() && get_property_int("_spaceJellyfishDrops") < 4 && myPathId() != PATH_LIVE_ASCEND_REPEAT)
        {
            string line = "stench monster area";
            if ($location[Pirates of the Garbage Barges].locationAvailable())
                line += " (garbage pirates)";
            line += " - extract stench jelly repeatedly, with the space jellyfish";
            useful_places.listAppend(line);
        }
        if (!__quest_state["Level 11 Palindome"].finished && get_property_int("palindomeDudesDefeated") < 5)
            useful_places.listAppend("inside the palindome");
        if (!__quest_state["Level 11 Manor"].finished && __quest_state["Level 11 Manor"].mafia_internal_step < 4 && $items[wine bomb, unstable fulminate].available_amount() == 0)
            useful_places.listAppend("haunted laundry room / haunted wine cellar");
        useful_places.listAppend("anywhere you olfact and get the wrong monster" + (($item[time-spinner].available_amount() > 0) ? ", unless time-spinning" : ""));
        
        if (useful_places.count() > 0 && myPathId() != PATH_COMMUNITY_SERVICE)
            description.listAppend("Reroll:|*-" + useful_places.listJoinComponents("|*-"));
        
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(macrometeorite_uses_remaining, "macrometeorite", "macrometeorites"), "", description));
    }
    if (get_property_int("_meteorShowerUses") < 5 && !__misc_state["familiars temporarily blocked"])
    {
        int meteor_shower_uses_remaining = clampi(5 - get_property_int("_meteorShowerUses"), 0, 5);
        
        string [int] description;
        description.listAppend("+200% weapon/spell damage, +20 familiar weight, for a single fight.");
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(meteor_shower_uses_remaining, "meteor shower", "meteor showers"), "", description));
    }
    if (lookupItem("metal meteoroid").available_amount() > 0 && in_ronin())
    {
        string [int] description;
        description.listAppend("Craft into useful equipment.");
        
        string [item] item_descriptions;
        item_descriptions[lookupItem("meteorb")] = "spell damage x2, like a lantern";
        item_descriptions[lookupItem("meteorthopedic shoes")] = "+5 adventures/day, +30% init, +15% moxie";
        item_descriptions[lookupItem("asteroid belt")] = "+10 ML, deflects attacks";
        //shooting morning star - 15% muscle tower test
        //meteorthopedic shoes - 15% moxie tower test
        //meteortarboard - 15% myst tower test
        if (!__quest_state["Level 13"].state_boolean["Stat race completed"] && __quest_state["Level 13"].state_string["Stat race type"] != "")
        {
            
            stat stat_race_type = __quest_state["Level 13"].state_string["Stat race type"].to_stat();
            if (stat_race_type == $stat[muscle])
                item_descriptions[lookupItem("shooting morning star")] = "+15% muscle for tower test";
            else if (stat_race_type == $stat[mysticality])
                item_descriptions[lookupItem("meteortarboard")] = "+15% myst for tower test";
        }
        string [int] items;
        foreach it, desc in item_descriptions
        {
            if (it.available_amount() == 0)
                items.listAppend(it + " (" + desc + ")");
        }
        if (items.count() > 0)
            description.listAppend("Could make " + items.listJoinComponents(", ", "or") + ".");
        if (lookupItem("metal meteoroid").item_amount() > 0)
            entry.url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9516";
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(lookupItem("metal meteoroid")), "", description));
    }
    
    if (entry.subentries.count() > 0)
        resource_entries.listAppend(entry);
}
