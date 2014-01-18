//merkinQuestPath

Record StringHandle
{
    string s;
};

void QSeaInit()
{
	if (!__misc_state["In aftercore"])
		return;
    
    //Have they adventured anywhere underwater?
    boolean have_adventured_in_relevant_area = false;
    foreach l in $locations[the briny deeps, the brinier deepers, the briniest deepests, an octopus's garden,the wreck of the edgar fitzsimmons, the mer-kin outpost, madness reef,the marinara trench, the dive bar,anemone mine, the coral corral, mer-kin elementary school,mer-kin library,mer-kin gymnasium,mer-kin colosseum,the caliginous abyss]
    {
        if (l.turnsAttemptedInLocation() > 0)
        {
            have_adventured_in_relevant_area = true;
            break;
        }
    }
    //don't list the quest unless they've started on the path under the sea:
    if (!have_adventured_in_relevant_area && $items[Mer-kin trailmap,Mer-kin lockkey,Mer-kin stashbox,wriggling flytrap pellet,damp old boot,Grandma's Map,Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].available_amount() == 0)
        return;
        
    
	//FIXME support mom
    if (true)
    {
        QuestState state;
        
        string quest_path = get_property("merkinQuestPath");
        if (quest_path == "done")
            QuestStateParseMafiaQuestPropertyValue(state, "finished");
        else
        {
            QuestStateParseMafiaQuestPropertyValue(state, "started");
        }
        
        state.quest_name = "Sea Quest";
        state.image_name = "Sea";
        
        __quest_state["Sea Temple"] = state;
    }
    if (true)
    {
        QuestState state;
        
        QuestStateParseMafiaQuestProperty(state, "questS02Monkees", false); //don't issue a quest load
        state.quest_name = "Hey, Hey, They're Sea Monkees";
        state.image_name = "Sea";
        
        
        __quest_state["Sea Monkees"] = state;
    }
}

void QSeaGenerateTempleEntry(ChecklistSubentry subentry, StringHandle image_name)
{
    string path = get_property("merkinQuestPath");
    
    boolean can_fight_dad_sea_monkee = $items[Goggles of Loathing,Stick-Knife of Loathing,Scepter of Loathing,Jeans of Loathing,Treads of Loathing,Belt of Loathing,Pocket Square of Loathing].items_missing().count() <= 1;
    
    boolean have_one_outfit = false;
    if (can_fight_dad_sea_monkee)
        have_one_outfit = true;
    foreach outfit_name in $strings[Mer-kin Scholar's Vestments,Mer-kin Gladiatorial Gear,Crappy Mer-kin Disguise]
    {
        if (have_outfit_components(outfit_name))
        {
            have_one_outfit = true;
            break;
        }
    }
    
    
    if (!have_one_outfit)
    {
        subentry.entries.listAppend("Acquire crappy mer-kin disguise from grandma sea monkee.");
        return;
    }
    
    boolean at_boss = false;
    boolean at_gladiator_boss = false;
    boolean at_scholar_boss = false;
    if (path == "gladiator")
    {
        image_name.s = "Shub-Jigguwatt";
        at_gladiator_boss = true;
    }
    else if (path == "scholar")
    {
        image_name.s = "Yog-Urt";
        at_scholar_boss = true;
    }
    at_boss = at_gladiator_boss || at_scholar_boss;
    
    if (!at_boss || at_gladiator_boss)
    {
        string [int] description;
        string [int] modifiers;
        //gladiator:
        if (at_gladiator_boss)
        {
            description.listAppend("Buff muscle, equip a powerful weapon.");
            description.listAppend("Delevel him with crayon shavings for a bit, then attack with your weapon.");
            description.listAppend("Make sure not to have anything along that will attack him. (saucespheres, familiars, hand in glove, etc)");
            if (my_mp() > 0)
                description.listAppend("Try to reduce your MP to 0 before fighting him.");
        }
        else
        {
            if (!have_outfit_components("Mer-kin Gladiatorial Gear"))
            {
                description.listAppend("Acquire gladiatorial outfit.|Components can be found by running +combat in the gymnasium.");
                modifiers.listAppend("+combat");
            }
            else
            {
                string shrap_suggestion = "Shrap is nice for this.";
                if (!lookupSkill("shrap").have_skill())
                {
                    if (lookupItem("warbear metalworking primer (used)").available_amount() > 0)
                    {
                        shrap_suggestion += " (use your used copy of warbear metalworking primer)";
                    }
                    else
                        shrap_suggestion += " (from warbear metalworking primer)";
                }
                modifiers.listAppend("spell damage percent");
                modifiers.listAppend("mysticality");
                description.listAppend("Fight in the colosseum!");
                description.listAppend("Easy way is to buff mysticality and spell damage percent, then cast powerful spells.|" + shrap_suggestion);
                description.listAppend("There's another way, but it's a bit complicated. Check the wiki?");
            }
        }
        string modifier_string = "";
        if (modifiers.count() > 0)
            modifier_string = ChecklistGenerateModifierSpan(modifiers);
        if (description.count() > 0)
            subentry.entries.listAppend("Gladiator path" +  HTMLGenerateIndentedText(modifier_string + description.listJoinComponents("<hr>")));
    }
    if (!at_boss || at_scholar_boss)
    {
        string [int] description;
        string [int] modifiers;
        //scholar:
        if (at_scholar_boss)
        {
            description.listAppend("Wear several mer-kin prayerbeads and possibly a mer-kin gutgirdle.");
            description.listAppend("Avoid wearing any +hp gear or buffs. Ideally, you want low HP.");
            description.listAppend("Each round, use a different healing item, until you lose the Suckrament effect.|After that, your stats are restored. Fully heal, then attack!");
            string [int] potential_healers = split_string_mutable("mer-kin healscroll (full HP),scented massage oil (full HP),soggy used band-aid (full HP),extra-strength red potion (+200 HP),red pixel potion (+100-120 HP),red potion (+100 HP),filthy poultice (+80-120 HP),gauze garter (+80-120 HP),green pixel potion (+40-60 HP),cartoon heart (40-60 HP),red plastic oyster egg (+35-40 HP)", ","); //thank you, wiki
            description.listAppend("Potential healing items:|*" + potential_healers.listJoinComponents("|*"));
        }
        else
        {
            if (!have_outfit_components("Mer-kin Scholar's Vestments"))
            {
                description.listAppend("Acquire scholar outfit.|Components can be found by running -combat in the elementary school.");
                modifiers.listAppend("-combat");
            }
            else
            {
                if ($item[Mer-kin dreadscroll].available_amount() == 0)
                {
                    description.listAppend("Adventure in the library. Find the dreadscroll.");
                    modifiers.listAppend("-combat");
                }
                else
                {
                    description.listAppend("Solve the dreadscroll.");
                    description.listAppend("Clues are from:|*Three non-combats in the library. (vocabulary)|*Use a mer-kin killscroll in combat. (vocabulary)|*Use a mer-kin healscroll in combat. (vocabulary)|*Use a mer-kin knucklebone.|*Cast deep dark visions.|*Eat sushi with mer-kin worktea.");
                }
            }
        }
        string modifier_string = "";
        if (modifiers.count() > 0)
            modifier_string = ChecklistGenerateModifierSpan(modifiers);
        if (description.count() > 0)
            subentry.entries.listAppend("Scholar path" +  HTMLGenerateIndentedText(modifier_string + description.listJoinComponents("<hr>")));
    }
    if (!at_boss && can_fight_dad_sea_monkee)
    {
        string [int] description;
        
        description.listAppend("Equip Clothing of Loathing, go to the temple.");
        description.listAppend("Fling 120MP hobopolis spells at him.");
        description.listAppend("Use Mafia's \"dad\" GCLI command to see which element to use.");
        if (my_mp() < 1200)
            description.listAppend("Will need 1200MP, or less if using shrap/volcanometeor showeruption.");
        
        if (description.count() > 0)
            subentry.entries.listAppend("Dad sea monkee path" + HTMLGenerateIndentedText(description.listJoinComponents("<hr>")));
    }
    
    item [class] class_to_scholar_item;
    item [class] class_to_gladiator_item;
    
    class_to_scholar_item[$class[seal clubber]] = $item[Cold Stone of Hatred];
    class_to_scholar_item[$class[turtle tamer]] = $item[Girdle of Hatred];
    class_to_scholar_item[$class[pastamancer]] = $item[Staff of Simmering Hatred];
    class_to_scholar_item[$class[sauceror]] = $item[Pantaloons of Hatred];
    class_to_scholar_item[$class[disco bandit]] = $item[Fuzzy Slippers of Hatred];
    class_to_scholar_item[$class[accordion thief]] = $item[Lens of Hatred];
    
    class_to_gladiator_item[$class[seal clubber]] = $item[Ass-Stompers of Violence];
    class_to_gladiator_item[$class[turtle tamer]] = $item[Brand of Violence];
    class_to_gladiator_item[$class[pastamancer]] = $item[Novelty Belt Buckle of Violence];
    class_to_gladiator_item[$class[sauceror]] = $item[Lens of Violence];
    class_to_gladiator_item[$class[disco bandit]] = $item[Pigsticker of Violence];
    class_to_gladiator_item[$class[accordion thief]] = $item[Jodhpurs of Violence];
    
    item scholar_item = class_to_scholar_item[my_class()];
    item gladiator_item = class_to_gladiator_item[my_class()];
    
    if (!at_boss)
    {
        string line = "Can acquire " + scholar_item + " (scholar) or " + gladiator_item + " (gladiator)";
        if (can_fight_dad_sea_monkee)
            line += " or " + $item[pocket square of loathing] + " (dad)";
        subentry.entries.listAppend(line);
    }
    else if (at_gladiator_boss)
        subentry.entries.listAppend("Will acquire " + gladiator_item + ".");
    else if (at_scholar_boss)
        subentry.entries.listAppend("Will acquire " + scholar_item + ".");
}

//Hmm. Possibly show taffy in resources, if they're under the sea?

void QSeaGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	QuestState temple_quest_state = __quest_state["Sea Temple"];
	QuestState monkees_quest_state = __quest_state["Sea Monkees"];
	
	if (!__misc_state["In aftercore"])
		return;
    
	boolean have_something_to_do_in_sea = false;
	if (!temple_quest_state.finished && (temple_quest_state.in_progress || temple_quest_state.startable))
		have_something_to_do_in_sea = true;
		
	ChecklistSubentry subentry;
	string image_name = temple_quest_state.image_name;
	
	subentry.header = temple_quest_state.quest_name;
	string url = "seafloor.php";
    boolean need_minus_combat_modifier = false;
	
    
    if ($effect[fishy].have_effect() == 0)
    {
        string line = "Acquire fishy.|*Easy way: Semi-rare in the brinier deeps, 50 turns.";
        if ($item[fishy pipe].available_amount() > 0 && !get_property_boolean("_fishyPipeUsed"))
            line += "|*Use fishy pipe.";
        subentry.entries.listAppend(line);
    }
        
	if (!temple_quest_state.finished)
	{
		if (get_property("seahorseName").length() == 0)
		{
            boolean professional_roper = false;
            //merkinLockkeyMonster questS01OldGuy questS02Monkees
			//Need to reach the temple:
			if (get_property("lassoTraining") != "expertly")
			{
				string line = "";
				if ($item[sea lasso].available_amount() == 0)
					line += "Buy and use a sea lasso in each combat.";
				else
					line += "Use a sea lasso in each combat.";
				if ($item[sea cowboy hat].equipped_amount() == 0)
					line += "|*Wear a sea cowboy hat to improve roping.";
				if ($item[sea chaps].equipped_amount() == 0)
					line += "|*Wear sea chaps to improve roping.";
				subentry.entries.listAppend(line);
			}
            else
            {
                professional_roper = true;
				string line = "";
				if ($item[sea lasso].available_amount() == 0)
					line += "Buy a sea lasso.";
				if ($item[sea cowbell].available_amount() <3 )
                {
                    int needed_amount = MAX(3 - $item[sea cowbell].available_amount(), 0);
					line += "Buy " + pluralizeWordy(needed_amount, "sea cowbell", "sea cowbells") + ".";
                }
                if (line.length() > 0)
                    subentry.entries.listAppend(line);
            }
            location class_grandpa_location;
            if (my_primestat() == $stat[muscle])
                class_grandpa_location = $location[Anemone Mine];
            if (my_primestat() == $stat[mysticality])
                class_grandpa_location = $location[The Marinara Trench];
            if (my_primestat() == $stat[moxie])
                class_grandpa_location = $location[the dive bar];
            
            int grandpa_ncs_remaining = 3 - class_grandpa_location.noncombatTurnsAttemptedInLocation();
            //Detect where we are:
            //This won't work beyond talking to little brother, my apologies
            if ($location[the Coral corral].turnsAttemptedInLocation() > 0)
            {
                //Coral corral. Banish strategy.
                string sea_horse_details;
                if (!professional_roper)
                    sea_horse_details = "|But first, train up your roping skills.";
                else
                    sea_horse_details = "|Once found, use three sea cowbells on him, then a sea lasso.";
                subentry.entries.listAppend("Look for your sea horse in the Coral Corral." + sea_horse_details);
                string [int] banish_monsters;
                monster [int] monster_list = $location[the coral corral].get_monsters();
                foreach key in monster_list
                {
                    monster m = monster_list[key];
                    if (!m.is_banished() && m != $monster[wild seahorse])
                        banish_monsters.listAppend(m.to_string());
                }
                if (banish_monsters.count() > 0)
                    subentry.entries.listAppend("Banish " + banish_monsters.listJoinComponents(", ", "and") + " with separate banish sources to speed up area.");
            }
            else if (false)
            {
                //Ask grandpa about currents.
            }
            else if (false)
            {
                //Use trailmap.
            }
            else if (false)
            {
                //Then stash box. Mention monster source.
            }
            else if ($location[the mer-kin outpost].turnsAttemptedInLocation() > 0 || grandpa_ncs_remaining == 0)
            {
                //Find lockkey as well.
                if ($item[Mer-kin trailmap].available_amount() > 0)
                {
                    subentry.entries.listAppend("Use Mer-kin trailmap.");
                }
                else if ($item[Mer-kin lockkey].available_amount() == 0)
                {
                    subentry.entries.listAppend("Adventure in the Mer-Kin outpost, acquire a lockkey.");
                    subentry.entries.listAppend("Unless you unlocked the currents already, in which case go to the corral.");
                }
                else if ($item[Mer-kin stashbox].available_amount() == 0)
                {
                    string nc_details = "";
                    monster lockkey_monster = get_property("merkinLockkeyMonster").to_monster();
                    if (lockkey_monster == $monster[mer-kin burglar])
                    {
                        nc_details = "Stashbox is in the Sneaky Intent.";
                    }
                    else if (lockkey_monster == $monster[mer-kin raider])
                    {
                        nc_details = "Stashbox is in the Aggressive Intent.";
                    }
                    else if (lockkey_monster == $monster[mer-kin healer])
                    {
                        nc_details = "Stashbox is in the Mysterious Intent.";
                    }
                    
                    need_minus_combat_modifier = true;
                    subentry.entries.listAppend("Adventure in the Mer-Kin outpost, find non-combat.|" + nc_details);
                }
                else
                {
                    subentry.entries.listAppend("Open stashbox.");
                }
                
            }
            else if (monkees_quest_state.mafia_internal_step == 5 || class_grandpa_location.turnsAttemptedInLocation() > 0)
            {
                //Find grandpa in one of the three zones.
                need_minus_combat_modifier = true;
                subentry.entries.listAppend("Find grandpa sea monkee in " + class_grandpa_location + ".|" + pluralizeWordy(grandpa_ncs_remaining, "non-combat remains", "non-combat remain").capitalizeFirstLetter() + ".");
            }
            else if (monkees_quest_state.mafia_internal_step == 4)
            {
                //Talk to little brother.
                subentry.entries.listAppend("Talk to little brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step == 3)
            {
                //Talk to big brother.
                subentry.entries.listAppend("Talk to big brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step == 2 || $location[The Wreck of the Edgar Fitzsimmons].turnsAttemptedInLocation() > 0)
            {
                //Adventure in wreck, free big brother.
                need_minus_combat_modifier = true;
                subentry.entries.listAppend("Free big brother. Adventure in the wreck.|Then talk to him and little brother, find grandpa.");
            }
            else if (monkees_quest_state.mafia_internal_step == 1)
            {
                //Talk to little brother
                subentry.entries.listAppend("Talk to little brother.");
                url = "monkeycastle.php";
            }
            else if (monkees_quest_state.mafia_internal_step < 1)
            {
                //Octopus's garden, obtain wriggling flytrap pellet
                if ($item[wriggling flytrap pellet].available_amount() == 0)
                    subentry.entries.listAppend("Adventure in octopus's garden, find a wriggling flytrap pellet.|Or talk to little brother if you've done that already.");
                else
                {
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Open a wriggling flytrap pellet, talk to little brother.");
                }
            }
            
            //Find grandma IF they don't have a disguise/cloathing.
		}
		else
		{
            url = "seafloor.php?action=currents";
            StringHandle image_name_handle;
            image_name_handle.s = image_name;
            QSeaGenerateTempleEntry(subentry, image_name_handle);
            image_name = image_name_handle.s;
        }
	}
            
    if ($item[damp old boot].available_amount() > 0)
    {
        string [int] description;
        if ($item[fishy pipe].available_amount() == 0)
            description.listAppend("Choose the fishy pipe.");
        else if ($item[das boot].available_amount() == 0)
            description.listAppend("Choose the das boot.");
        else
            description.listAppend("Choose the damp old wallet.");
        
		optional_task_entries.listAppend(ChecklistEntryMake("__item damp old boot", "place.php?whichplace=sea_oldman", ChecklistSubentryMake("Return damp old boot to the old man", "", description)));
        
    }
    if ($items[Grandma's Map,Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].available_amount() > 0)
    {
        string line = "Optionally, rescue grandma.";
        if ($item[grandma's map].available_amount() > 0)
        {
            line += "|Adventure at the mer-kin outpost, find her.";
            need_minus_combat_modifier = true;
        }
        else
        {
            item [int] missing_items = $items[Grandma's Chartreuse Yarn,Grandma's Fuchsia Yarn,Grandma's Note].items_missing();
            
            if (missing_items.count() == 0)
            {
                line += "|Ask grandpa about the note.";
            }
            else
            {
                line += "|Adventure at the mer-kin outpost, find " + missing_items.listJoinComponents(", ", "and") + ".";
                need_minus_combat_modifier = true;
            }
        }
        subentry.entries.listAppend(line);
    }
    
    if (need_minus_combat_modifier)
        subentry.modifiers.listAppend("-combat");
	
	if (have_something_to_do_in_sea)
		optional_task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry, $locations[the brinier deepers, an octopus's garden,the wreck of the edgar fitzsimmons, the mer-kin outpost, madness reef,the marinara trench, the dive bar,anemone mine, the coral corral, mer-kin elementary school,mer-kin library,mer-kin gymnasium,mer-kin colosseum,the caliginous abyss]));
}