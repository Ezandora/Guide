RegisterTaskGenerationFunction("IOTMIntergnatGenerateTasks");
void IOTMIntergnatGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    
    if (!get_property_boolean("demonSummoned") && __misc_state["in run"] && !__quest_state["Level 13"].state_boolean["king waiting to be freed"] && $familiar[intergnat].familiar_is_usable() && my_path_id() != PATH_AVATAR_OF_SNEAKY_PETE)
    {
        //Should we show this if they aren't using the intergnat? ... Yes?
        //demonName12, thin black candle, scroll of ancient forbidden unspeakable evil
        string [int] reasons;
        if (!get_property("demonName12").contains_text("Neil ") && my_level() < 13) //13 is +50% init... it's kind of useful? But not worth mentioning if they don't have it by this point?
        {
            reasons.listAppend("learn demon name");
        }
        if ($item[thin black candle].available_amount() < 3)
        {
            if ($item[thin black candle].available_amount() < 2)
                reasons.listAppend("collect " + int_to_wordy(3 - $item[thin black candle].available_amount()) + " more thin black candles");
            else
                reasons.listAppend("collect One More Thin black candle");
        }
        if ($item[scroll of ancient forbidden unspeakable evil].available_amount() == 0)
        {
            reasons.listAppend("collect a scroll of ancient forbidden unspeakable evil");
        }
        if (reasons.count() > 0)
        {
            string [int] description;
            description.listAppend(reasons.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
            string url = "";
            string title = "Continue running Intergnat for demon summon";
            if (my_familiar() != $familiar[intergnat])
            {
                url = "familiar.php";
                title = "Possibly run Intergnat for demon summon";
            }
            //Don't use the intergnat icon, because animation is distracting:
            optional_task_entries.listAppend(ChecklistEntryMake("__item thin black candle", url, ChecklistSubentryMake(title, "", description)));
        }
    }
}

RegisterResourceGenerationFunction("IOTMIntergnatGenerateResource");
void IOTMIntergnatGenerateResource(ChecklistEntry [int] resource_entries)
{
    if ($item[infinite BACON machine].available_amount() > 0 && !get_property_boolean("_baconMachineUsed") && mafiaIsPastRevision(16926))
    {
        //suggest using it:
        resource_entries.listAppend(ChecklistEntryMake("__item infinite BACON machine", "inventory.php?which=3", ChecklistSubentryMake("Infinite BACON machine", "", "100 BACON/day."), 7));
    }
    if ($item[daily dungeon malware].available_amount() > 0 && __misc_state_int["fat loot tokens needed"] > 0)
    {
        resource_entries.listAppend(ChecklistEntryMake("__item daily dungeon malware", "da.php", ChecklistSubentryMake("Daily dungeon malware", "", "Use on a daily dungeon monster to gain a fat loot token."), 7));
    }
    int bacon_amount = $item[BACON].available_amount();
    if (__misc_state["in run"] && bacon_amount > 0 && in_ronin())
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
            if (!__misc_state["yellow ray available"] & $effect[everything looks yellow].have_effect() == 0 && my_path_id() != PATH_G_LOVER)
                bacon_description[$item[Viral video]] = "yellow ray";
            if (my_path_id() != PATH_G_LOVER)
	            bacon_description[$item[print screen button]] = "copies a monster";
            if (__misc_state_int["fat loot tokens needed"] > 0)
                bacon_description[$item[daily dungeon malware]] = "expensive DD token source";
            if (availableFullness() >= 15)
                bacon_description[$item[gallon of milk]] = "lazy/expensive food source. Incurs a debuff";
            
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
                
                resource_entries.listAppend(ChecklistEntryMake("__item BACON", "shop.php?whichshop=bacon", ChecklistSubentryMake(pluralise($item[BACON]), "", description), 7));
            }
        }
    }
}
