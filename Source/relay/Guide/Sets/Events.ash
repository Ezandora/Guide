void SEventsCrimbo2014GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (format_today_to_string("yyyy-MM") != "2014-12")
        return;
    
    //Crimbo 2014:
    effect oily_legs_effect = lookupEffect("Oily Legs");
    effect crimbonar_effect = lookupEffect("Crimbonar");
    effect loose_joints_effect = lookupEffect("Loose Joints");
    
    
    if (oily_legs_effect == $effect[none] || crimbonar_effect == $effect[none] || loose_joints_effect == $effect[none]) //Older copy. We'll just not output anything - it's very hard to juggle not knowing about effects.
        return;
    
    //Examine mine:
    string mine_layout = get_property("mineLayout5");
    int crimbonium_seen = stringCountSubstringMatches(mine_layout, "title=\"nugget of Crimbonium\"");

    boolean should_output_new_cavern_suggestion = false;
    boolean need_fast_suggestions = false;
    if (__last_adventure_location != lookupLocation("The Crimbonium Mine"))
    {
        if (have_outfit_components("High-Radiation Mining Gear") && oily_legs_effect.have_effect() > 0 && oily_legs_effect != $effect[none])
        {
            need_fast_suggestions = true;
        }
    }
    
    if (__last_adventure_location == lookupLocation("The Crimbonium Mine") || need_fast_suggestions)
    {
        if (true)
        {
            
            effect [int] need_mining_oil_for_effects;
            string [int] effect_reasons;
            
            if (oily_legs_effect.have_effect() == 0 && oily_legs_effect != $effect[none])
            {
                need_mining_oil_for_effects.listAppend(oily_legs_effect);
                effect_reasons.listAppend("free-mining");
            }
            if (crimbonar_effect.have_effect() == 0 && crimbonar_effect != $effect[none] && $effect[object detection].have_effect() == 0)
            {
                need_mining_oil_for_effects.listAppend(crimbonar_effect);
                effect_reasons.listAppend("crimbonium locations");
            }
            
            if (need_mining_oil_for_effects.count() > 0 && lookupItem("flask of mining oil").available_amount() > 0)
            {
                string description;
                
                description = "Gives " + need_mining_oil_for_effects.listJoinComponents("/") + " for " + effect_reasons.listJoinComponents(", ", "and") + ".";
                
                string url = "inventory.php?which=3";
                task_entries.listAppend(ChecklistEntryMake("__item flask of mining oil", url, ChecklistSubentryMake(HTMLGenerateSpanFont("Use flask of mining oil before mining", "red"), "", HTMLGenerateSpanFont(description, "red")), -11));
            }
        }
        if (crimbonium_seen >= 6)
        {
            string url = lookupLocation("The Crimbonium Mine").getClickableURLForLocation();
            task_entries.listAppend(ChecklistEntryMake("__item nugget of Crimbonium", url, ChecklistSubentryMake(HTMLGenerateSpanFont("Find another mine", "red"), "", HTMLGenerateSpanFont("Only six nuggets of Crimbonium to a mine.", "red")), -11));
        }
    }
    if (need_fast_suggestions)
    {
        //want here, after above warnings
        string url = lookupLocation("The Crimbonium Mine").getClickableURLForLocation();
        if (!is_wearing_outfit("High-Radiation Mining Gear"))
            url = "inventory.php?which=2";
        task_entries.listAppend(ChecklistEntryMake("__item nugget of Crimbonium", url, ChecklistSubentryMake(HTMLGenerateSpanFont("Mine for crimbonium", "red"), "", HTMLGenerateSpanFont("Will not cost a turn.", "red")), -11));
    }
    
    //Main crimbo:
    if (true)
    {
        //If they have oily legs, adventure in the mine.
        //Else, if they have Loose Joints, adventure in the camp.
        //Else, if they have a flask, use the flask and then mine.
        //Else, adventure in the camp.
        ChecklistSubentry subentry;
        subentry.header = "Crimbo 2014";
        
        boolean [location] relevant_locations;
        relevant_locations[lookupLocation("The Crimbonium Mine")] = true;
        relevant_locations[lookupLocation("The Crimbonium Mining Camp")] = true;
        
        string url = "place.php?whichplace=desertbeach";
        boolean should_output_camp_suggestions = false;
        if (lookupItem("radiation-resistant helmet").available_amount() == 0 || lookupItem("high-energy mining laser").available_amount() == 0 || lookupItem("servo-assisted exo-pants").available_amount() == 0)
        {
            should_output_camp_suggestions = true;
            subentry.entries.listAppend("Need to acquire High-Radiation Mining Gear. (low drop)");
        }
        else if (oily_legs_effect.have_effect() > 0)
        {
            url = lookupLocation("The Crimbonium Mine").getClickableURLForLocation();
            if (my_hp() == 0)
            {
                url = "shop.php?whichshop=doc";
                subentry.entries.listAppend("Restore HP at Doc Galaktik. (1 HP)");
            }
            else
            {
                if (!is_wearing_outfit("High-Radiation Mining Gear"))
                    url = "inventory.php?which=2";
                subentry.entries.listAppend("Mine in the mine for " + pluraliseWordy(oily_legs_effect.have_effect(), "more turn", "more turns") + ".");
                if (crimbonar_effect.have_effect() > 0 || $effect[object detection].have_effect() > 0)
                    subentry.entries.listAppend("Try to look for a large group of flashing spots. All the crimbonium is packed together.");
                if (!is_wearing_outfit("High-Radiation Mining Gear"))
                    subentry.entries.listAppend("Wear the High-Radiation Mining Gear outfit.");
                if (crimbonium_seen >= 6)
                    subentry.entries.listAppend("Find a new cavern.");
                else if (crimbonium_seen >= 0)
                    subentry.entries.listAppend(pluraliseWordy(6 - crimbonium_seen, "more nugget", "more nuggets").capitaliseFirstLetter() + " of crimbonium in mine.");
            }
            
        }
        else if (loose_joints_effect.have_effect() > 0)
        {
            should_output_camp_suggestions = true;
        }
        else if (lookupItem("flask of mining oil").available_amount() > 0)
        {
            subentry.entries.listAppend("Use flask of mining oil to acquire a mining/camp farming effect.");
            subentry.entries.listAppend("Cylindrical molds stop dropping after around two hundred adventures in the area, per day.");
            url = "inventory.php?which=3";
        }
        else
        {
            should_output_camp_suggestions = true;
        }
        if (__misc_state["In run"])
            optional_task_entries.listAppend(ChecklistEntryMake("__item nugget of Crimbonium", url, subentry, relevant_locations));
        else
            task_entries.listAppend(ChecklistEntryMake("__item nugget of Crimbonium", url, subentry, relevant_locations));
        if (should_output_camp_suggestions)
        {
            subentry.modifiers.listAppend("+item");
            string line = "Adventure in the Crimbonium Mining Camp";
            if (loose_joints_effect.have_effect() >= 200)
                line += " for a few hundred turns";
            else if (loose_joints_effect.have_effect() > 0)
                line += " for possibly " + pluraliseWordy(loose_joints_effect.have_effect(), "more turn", "more turns");
            line += ".|Cylindrical molds stop dropping after around two hundred adventures in the area, per day.";
            subentry.entries.listPrepend(line);
            if (is_wearing_outfit("High-Radiation Mining Gear"))
                subentry.entries.listAppend("You don't need to wear mining gear there.");
        }
    }
}

void SEventsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    SEventsCrimbo2014GenerateTasks(task_entries, optional_task_entries, future_task_entries);
}