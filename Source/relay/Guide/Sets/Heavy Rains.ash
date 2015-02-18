void SHeavyRainsGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_HEAVY_RAINS)
		return;
    
    item thunder_item = lookupItem("thunder thigh");
    item rain_item = lookupItem("aquaconda brain");
    item lightning_item = lookupItem("lightning milk");
    
    boolean [item] all_skill_items;
    all_skill_items[thunder_item] = true;
    all_skill_items[rain_item] = true;
    all_skill_items[lightning_item] = true;
    
    if (thunder_item.available_amount() + rain_item.available_amount() + lightning_item.available_amount() > 0)
    {
        //Let's learn skills:
        skill [item][int] skills_for_item;
        
        skills_for_item[thunder_item] = listMakeBlankSkill();
        skills_for_item[rain_item] = listMakeBlankSkill();
        skills_for_item[lightning_item] = listMakeBlankSkill();
        
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunder Clap"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thundercloud"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunder Bird"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunderheart"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunderstrike"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunder Down Underwear"));
        skills_for_item[thunder_item].listAppend(lookupSkill("Thunder Thighs"));
        
        skills_for_item[rain_item].listAppend(lookupSkill("Rain Man"));
        skills_for_item[rain_item].listAppend(lookupSkill("Rainy Day"));
        skills_for_item[rain_item].listAppend(lookupSkill("Make it Rain"));
        skills_for_item[rain_item].listAppend(lookupSkill("Rain Dance"));
        skills_for_item[rain_item].listAppend(lookupSkill("Rainbow"));
        skills_for_item[rain_item].listAppend(lookupSkill("Rain Coat"));
        skills_for_item[rain_item].listAppend(lookupSkill("Rain Delay"));
        
        skills_for_item[lightning_item].listAppend(lookupSkill("Lightning Strike"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Clean-Hair Lightning"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Ball Lightning"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Sheet Lightning"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Lightning Bolt"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Lightning Rod"));
        skills_for_item[lightning_item].listAppend(lookupSkill("Riding the Lightning"));
        
        string [skill] description_for_skill;
        
        description_for_skill[lookupSkill("Thunder Clap")] = "Turn-costing banish. (lasts 40 turns, no stats, no items, no meat)";
        description_for_skill[lookupSkill("Thundercloud")] = "Water depth increasing effect";
        description_for_skill[lookupSkill("Thunderheart")] = "+100% HP, surviving";
        description_for_skill[lookupSkill("Thunderstrike")] = "Monster stunning";
        description_for_skill[lookupSkill("Thunder Thighs")] = "Thunder regen, passive";
        description_for_skill[lookupSkill("Thunder Bird")] = "Monster deleveling";
        if (in_hardcore())
            description_for_skill[lookupSkill("Thunder Down Underwear")] = "safety pants (if you want to)";
        
        
        description_for_skill[lookupSkill("Rain Man")] = "Fax any monster repeatedly";
        description_for_skill[lookupSkill("Rainy Day")] = "Water depth increasing effect";
        if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
            description_for_skill[lookupSkill("Make it Rain")] = "+300% meat for a single turn (nuns)";
        description_for_skill[lookupSkill("Rain Dance")] = "+20% item effect";
        description_for_skill[lookupSkill("Rain Delay")] = "passive, +3 resist all";
        
        description_for_skill[lookupSkill("Lightning Strike")] = "Kills monster, gain stats/drops, makes adventure not use a turn (effective free run/hipster)";
        description_for_skill[lookupSkill("Ball Lightning")] = "Yellow ray (100 turn cooldown)";
        description_for_skill[lookupSkill("Riding the Lightning")] = "passive, +100% max MP";
        
        
        description_for_skill[lookupSkill("Sheet Lightning")] = "+100% spell damage effect";
        //description_for_skill[lookupSkill("Thunder Down Underwear")] = "Summon once/day pants: +100 DA/HP, HP regen";
        //description_for_skill[lookupSkill("Rain Coat")] = "Summons once/day shirt: +40% init, +10% item, +2 resist all";
        //description_for_skill[lookupSkill("Lightning Rod")] = "Summons once/day weapon: +200% spell damage";
        
        
        int [item] available_skills_for_item;
        int [item] max_available_skills_for_item;
        
        foreach it in skills_for_item
        {
            foreach key in skills_for_item[it]
            {
                skill s = skills_for_item[it][key];
                if (s.skill_is_usable())
                    continue;
                max_available_skills_for_item[it] += 1;
                available_skills_for_item[it] = MIN(max_available_skills_for_item[it], it.available_amount());
            }
        }
        
        //available_skills_for_item[thunder_item] = 7;
        //available_skills_for_item[rain_item] = 7;
        //available_skills_for_item[lightning_item] = 7;
        
        
        string [int] description;
        
        string [int] available_skill_types;
        
        string [int] items_to_use_description;
        
        string [item] item_to_typename;
        item_to_typename[thunder_item] = "thunder";
        item_to_typename[rain_item] = "rain";
        item_to_typename[lightning_item] = "lightning";
        
        string url = "";
        string [item] item_to_url;
        
        item_to_url[thunder_item] = "inv_use.php?which=3&whichitem=7648&pwd=" + my_hash();
        item_to_url[rain_item] = "inv_use.php?which=3&whichitem=7647&pwd=" + my_hash();
        foreach it in all_skill_items
        {
            if (available_skills_for_item[it] > 0)
            {
                available_skill_types.listAppend(item_to_typename[it]);
                items_to_use_description.listAppend(pluralize(available_skills_for_item[it], it));
                
                if (url.length() == 0)
                    url = item_to_url[it];
            }
        }
        
        url = "inventory.php?which=3"; //mafia won't remove the skill glands quite properly (needs to happen when you click the NC option, not at inv_use.php)
        
        description.listAppend("Use " + items_to_use_description.listJoinComponents(", ", "and") + ".");
        
        
        foreach it in all_skill_items
        {
            if (available_skills_for_item[it] == 0)
                continue;
            
            int other_count = 0;
            string [int] relevant_descriptions;
            foreach key in skills_for_item[it]
            {
                skill s = skills_for_item[it][key];
                if (s.skill_is_usable())
                    continue;
                if (!(description_for_skill contains s))
                {
                    other_count += 1;
                    continue;
                }
                relevant_descriptions.listAppend(s + ": " + description_for_skill[s]);
            }
            if (other_count > 0)
            {
                if (relevant_descriptions.count() > 0)
                    relevant_descriptions.listAppend("Or " + pluralizeWordy(other_count, "other skill", "other skills") + ".");
                else
                    relevant_descriptions.listAppend(pluralizeWordy(other_count, "possible skill", "possible skills").capitalizeFirstLetter() + ".");
            }
            
            description.listAppend(HTMLGenerateSpanOfClass(item_to_typename[it].capitalizeFirstLetter() + ":", "r_bold") + HTMLGenerateIndentedText(relevant_descriptions.listJoinComponents("<hr>")));
        }
        
        if (available_skill_types.count() > 0)
            task_entries.listAppend(ChecklistEntryMake("__familiar personal raincloud", url, ChecklistSubentryMake("Learn " + available_skill_types.listJoinComponents(", ", "and") + " skills", "", description), -10));
    }
}

void SHeavyRainsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if (my_path_id() != PATH_HEAVY_RAINS)
		return;
    
    //available_resources_entries.listAppend(ChecklistEntryMake("__item gym membership card", "inventory.php?which=3", ChecklistSubentryMake(pluralize($item[gym membership card]), "", description), importance_level_item));
    
    
    int fishbone_amount = lookupItem("freshwater fishbone").available_amount();
    
    if (fishbone_amount >= 5) //only show if there's something to buy
    {
        int [item] fishbone_item_costs;
        string [item] fishbone_item_descriptions;
        
        //Are these worth suggesting?
        //fishbone_item_descriptions[lookupItem("fishbone facemask")] = "-30 ML";
        //fishbone_item_costs[lookupItem("fishbone facemask")] = 5;
        //fishbone_item_descriptions[lookupItem("fishbone fins")] = "survivability";
        //fishbone_item_costs[lookupItem("fishbone fins")] = 20;
        
        fishbone_item_descriptions[lookupItem("fishbone bracers")] = "+100% spell damage";
        fishbone_item_costs[lookupItem("fishbone bracers")] = 5;
        
        
        fishbone_item_descriptions[lookupItem("fishbone corset")] = "-water depth";
        fishbone_item_costs[lookupItem("fishbone corset")] = 10;
        
        
        fishbone_item_descriptions[lookupItem("fishbone kneepads")] = "+60% init";
        fishbone_item_costs[lookupItem("fishbone kneepads")] = 15;
        
        fishbone_item_descriptions[lookupItem("fishbone catcher's mitt")] = "-washaway";
        fishbone_item_costs[lookupItem("fishbone catcher's mitt")] = 30;
        
        string [int] description;
        foreach it in fishbone_item_costs
        {
            if (it == $item[none])
                continue;
            int cost = fishbone_item_costs[it];
            
            
            int amount_needed = 1;
            if (it.to_slot() == $slot[acc1] || it.to_slot() == $slot[acc2] || it.to_slot() == $slot[acc3])
                amount_needed = 3;
                
            int creatable = 0;
            if (fishbone_item_costs[it] != 0)
                creatable = MIN(amount_needed, fishbone_amount / fishbone_item_costs[it]);
            
            if (it.available_amount() >= amount_needed || creatable == 0)
                continue;
            int amount_to_make = MIN(creatable, amount_needed - it.available_amount());
            
            description.listAppend(pluralize(amount_to_make, it) + ": " + fishbone_item_descriptions[it]);
        }
        available_resources_entries.listAppend(ChecklistEntryMake("__item freshwater fishbone", "shop.php?whichshop=fishbones", ChecklistSubentryMake(pluralize(lookupItem("freshwater fishbone")), "", description), 7));
    }
    
    if (lookupItem("catfish whiskers").available_amount() > 0)
    {
        //should we add in area suggestions?
        available_resources_entries.listAppend(ChecklistEntryMake("__item catfish whiskers", "inventory.php?which=3", ChecklistSubentryMake(pluralize(lookupItem("catfish whiskers")), "", "40 turns of -washaway"), 7));
    }
}