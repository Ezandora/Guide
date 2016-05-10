RegisterResourceGenerationFunction("IOTMIntergnatGenerateResource");
void IOTMIntergnatGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("infinite BACON machine").available_amount() > 0 && !get_property_boolean("_baconMachineUsed") && mafiaIsPastRevision(16926))
    {
        //suggest using it:
        resource_entries.listAppend(ChecklistEntryMake("__item infinite BACON machine", "inventory.php?which=3", ChecklistSubentryMake("Infinite BACON machine", "", "100 BACON/day."), 7));
    }
    if (lookupItem("daily dungeon malware").available_amount() > 0 && __misc_state_int["fat loot tokens needed"] > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item daily dungeon malware", "da.php", ChecklistSubentryMake("Daily dungeon malware", "", "Use on a daily dungeon monster to gain a fat loot token."), 7));
    }
    int bacon_amount = lookupItem("BACON").available_amount();
    if (__misc_state["in run"] && bacon_amount > 0)
    {
        /*
        Viral video - YR if they don't have one.
        Print screen button - Copy, kind of unlimited use.
        Daily dungeon malware - It seems very expensive for what it does, but, we could suggest it?
        
        Gallon of milk - food, though not amazing. The debuff causes issues, but mostly just for the alcove.
        */
        coinmaster meme_shop = "Internet Meme Shop".to_coinmaster();
        if (meme_shop != $coinmaster[none])
        {
            string [item] bacon_description;
            if (!__misc_state["yellow ray available"] & $effect[everything looks yellow].have_effect() == 0)
                bacon_description[lookupItem("Viral video")] = "yellow ray";
            bacon_description[lookupItem("print screen button")] = "copies a monster";
            if (__misc_state_int["fat loot tokens needed"] > 0)
                bacon_description[lookupItem("daily dungeon malware")] = "expensive DD token source";
            if (availableFullness() >= 15)
                bacon_description[lookupItem("gallon of milk")] = "lazy/expensive food source. Incurs a debuff";
            
            string [int][int] table;
            foreach it, item_description in bacon_description
            {
                int bacon_cost = meme_shop.sell_price(it);
                string [int] line;
                line.listAppend(it.capitaliseFirstLetter());
                line.listAppend(bacon_cost);
                line.listAppend(item_description.capitaliseFirstLetter() + ".");
                if (bacon_cost > bacon_amount)
                {
                    foreach key in line
                    {
                        line[key] = HTMLGenerateSpanFont(line[key], "grey");
                    }
                }
                table.listAppend(line);
            }
            if (table.count() > 0)
            {
                string [int] description;
                description.listAppend(HTMLGenerateSimpleTableLines(table));
                
                resource_entries.listAppend(ChecklistEntryMake("__item BACON", "shop.php?whichshop=bacon", ChecklistSubentryMake(pluralise(lookupItem("BACON")), "", description), 7));
            }
        }
    }
}