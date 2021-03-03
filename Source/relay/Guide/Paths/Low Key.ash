RegisterTaskGenerationFunction("PathLowKeyGenerateTasks");
void PathLowKeyGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (my_path_id() != PATH_LOKI) //I've never met this man in my life
		return;
    location [item] key_locations = {
    $item[Anchovy can key]:$location[The Haunted Pantry],
    $item[Weremoose key]:$location[Cobb's Knob Menagerie, Level 2],
    $item[Treasure chest key]:$location[Belowdecks],
    $item[Batting cage key]:$location[The Bat Hole Entrance],
    $item[F'c'le sh'c'le k'y]:$location[The F'c'le],
    $item[Actual skeleton key]:$location[The Skeleton Store],
    $item[Cactus key]:$location[The Arid, Extra-Dry Desert],
    $item[Music Box Key]:$location[The Haunted Nursery],
    $item[Ice Key]:$location[The Icy Peak],
    $item[Knob treasury key]:$location[Cobb's Knob Treasury],
    $item[Demonic key]:$location[Pandamonium Slums],
    $item[Scrap metal key]:$location[The Old Landfill],
    $item[Deep-fried key]:$location[Madness Bakery],
    $item[Peg key]:$location[The Obligatory Pirate's Cove],
    $item[Knob labinet key]:$location[Cobb's Knob Laboratory],
    $item[Knob shaft skate key]:$location[The Knob Shaft],
    $item[Discarded bike lock key]:$location[The Overgrown Lot],
    $item[Clown car key]:$location[The "Fun" House],
    $item[Rabbit's foot key]:$location[The Dire Warren],
    $item[Key sausage]:$location[Cobb's Knob Kitchens],
    $item[Black rose key]:$location[The Haunted Conservatory],
    $item[10549]:$location[South of the Border],
    $item[Kekekey]:$location[The Valley of Rof L'm Fao],
    };
    //clown car key,batting cage key,10549,knob labinet key,weremoose key,peg key,kekekey,rabbit's foot key,knob shaft skate key,ice key,anchovy can key,cactus key,f'c'le sh'c'le k'y,treasure chest key,demonic key,key sausage,knob treasury key,scrap metal key,black rose key,music box key,actual skeleton key,deep-fried key,discarded bike lock key
    
    //FIXME suggest starting the three quests
	boolean [item] keys_we_need;
	
	boolean need_keys = QuestState("questL13Final").mafia_internal_step <= 6;
	
    string [int] keys_used = split_string_alternate(get_property("nsTowerDoorKeysUsed"), ",");
    boolean [string] keys_used_inverted = keys_used.listInvert();
	if (need_keys)
	{
        foreach key, l in key_locations
        {
        	//if (debug) keys_we_need[key] = true;
            if (key == $item[none]) continue;
            if (key.have()) continue;
            if (keys_used_inverted[key.to_string()]) continue;
            keys_we_need[key] = true;
        }
	}
	
    foreach key in keys_we_need
	{
		location l = key_locations[key];
        boolean location_available = l.locationAvailable();
        if ($locations[Barrrney's Barrr,The F'c'le,The Poop Deck,Belowdecks] contains l && (have_outfit_components("Swashbuckling Getup") || $item[pirate fledges].have())) //need to improve the locationAvailable API to distinguish between "could adventure there, with equipment" and "can adventure there right this second"
        	location_available = true;
        
        string title = "Adventure in " + l;
        
        if (!location_available)
        	title = HTMLGenerateSpanFont(title, "grey");
        
        int turns_left = clampi(12 - l.turns_spent, 0, 12);
        
        ChecklistSubentry subentry = ChecklistSubentryMake(title, "", "");
        
        //per-zone:
        if (!location_available)
        {
        	if (l == $location[The "Fun" House])
         	   subentry.entries.listAppend("Unlock by " + (!guild_store_available() ? "unlocking your guild and " : "") + "completing the first part of the nemesis quest.");
            else if (l == $location[The Bat Hole Entrance])
            	subentry.entries.listAppend("Unlock by starting the level 4 quest.");
            else if (l == $location[South of the Border])
            	subentry.entries.listAppend("Unlock by opening the desert.");
            else if (l == $location[Cobb's Knob Laboratory])
            	subentry.entries.listAppend("Unlock by completing the level 5 quest.");
            else if (l == $location[Cobb's Knob Menagerie\, Level 2])
            	subentry.entries.listAppend("Unlock by collecting the menagerie key from Knob Goblin Very Mad Scientist in cobb's knob laboratory.");
            else if (l == $location[The Obligatory Pirate's Cove])
            	subentry.entries.listAppend("Unlock by unlocking the mysterious island.");
            else if (l == $location[The Valley of Rof L'm Fao])
            	subentry.entries.listAppend("Unlock by finishing the level 9 quest.");
            else if (l == $location[The Dire Warren])
            	subentry.entries.listAppend("This should be unlocked. If you are seeing this message, it is in error. Which means someone will see it eventually. Congrats!");
            else if (l == $location[The Knob Shaft])
            	subentry.entries.listAppend("Unlock by ... has anyone ever been here before? I'm not sure it's a real place, let me check the wiki|I think they made it up, but you can unlock it by completing the level 5 quest.");
            else if (l == $location[The Icy Peak])
            	subentry.entries.listAppend("Unlock during the level 8 quest.");
            else if (l == $location[The Arid\, Extra-Dry Desert])
            	subentry.entries.listAppend("Unlock during the level 11 quest.");
            else if (l == $location[The F'c'le])
            	subentry.entries.listAppend("Unlock by completing the pirate quest.");
            else if (l == $location[Belowdecks])
            	subentry.entries.listAppend("Unlock by reading the level 11 diary and adventuring on the poop deck.");
            else if (l == $location[Pandamonium Slums])
            	subentry.entries.listAppend("Unlock by finishing the level 6 quest.");
            else if (l == $location[Cobb's Knob Kitchens])
            	subentry.entries.listAppend("Unlock during the level 5 quest.");
            else if (l == $location[Cobb's Knob Treasury])
            	subentry.entries.listAppend("Unlock during the level 5 quest.");
            else if (l == $location[The Old Landfill])
            	subentry.entries.listAppend("Unlock by speaking to the hippy in the distant woods.");
            else if (l == $location[The Haunted Conservatory] || l == $location[The Haunted Pantry])
            	subentry.entries.listAppend("Unlock by reading... a note you got from the mail? I think?");
            else if (l == $location[The Haunted Nursery])
            	subentry.entries.listAppend("Unlock by completing the manor quest.");
            else if (l == $location[The Skeleton Store])
            	subentry.entries.listAppend("Unlock by talking to the meat smith in town.");
            else if (l == $location[Madness Bakery])
            	subentry.entries.listAppend("Unlock by talking to the Armorer and Leggerer's.");
            else if (l == $location[The Overgrown Lot])
            	subentry.entries.listAppend("Unlock by talking to Doc Galaktik.");
        }
        else
        {
            if (turns_left <= 1)
                subentry.entries.listAppend("Key next turn.");
            else
            {
                subentry.entries.listAppend(pluralise(turns_left, "turn", "turns") + " until key.");
                if (__misc_state["free runs available"])
                    subentry.modifiers.listAppend("free runs");
                if (__misc_state["have hipster"])
                    subentry.modifiers.listAppend(__misc_state_string["hipster name"]);
            }
                
            if ($locations[Barrrney's Barrr,The F'c'le,The Poop Deck,Belowdecks,The Obligatory Pirate's Cove] contains l)
            {
                if (QuestState("questL12War").mafia_internal_step == 2)
                {
                	subentry.entries.listAppend("Finish the war first.");
                }
                if (l != $location[The Obligatory Pirate's Cove] && !($item[pirate fledges].equipped() || is_wearing_outfit("Swashbuckling Getup")))
                {
                	if ($item[pirate fledges].have())
	                	subentry.entries.listAppend("Equip the pirate fledges first.");
                    else if (have_outfit_components("Swashbuckling Getup"))
	                	subentry.entries.listAppend("Equip the swashbuckling getup first.");
                    else
	                	subentry.entries.listAppend("Find the swashbuckling getup first.");
                }
            }
        }
        
        
        
        task_entries.listAppend(ChecklistEntryMake("__item Asdon Martin keyfob", l.getClickableURLForLocation(), subentry, 8).ChecklistEntryTag("low key summer path"));
    }      
}
