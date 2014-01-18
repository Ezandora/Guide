//merkinQuestPath

void QSeaInit()
{
	if (!__misc_state["In aftercore"])
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
	
	//the entire sea quest is super complicated
    //FIXME implement the other half of this
	if (!temple_quest_state.finished)
	{
        if ($effect[fishy].have_effect() == 0)
        {
            string line = "Acquire fishy.|*Easy way: Semi-rare in the brinier deeps, 50 turns.";
            if ($item[fishy pipe].available_amount() > 0 && !get_property_boolean("_fishyPipeUsed"))
                line += "|*Use fishy pipe.";
            subentry.entries.listAppend(line);
        }
		if (get_property("seahorseName") == "")
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
                    subentry.entries.listAppend("Adventure in octopus's garden, find a wriggling flytrap pellet.");
                else
                {
                    url = "inventory.php?which=3";
                    subentry.entries.listAppend("Open your wriggling flytrap pellet, talk to little brother.");
                }
            }
            
            //Find grandma IF they don't have a disguise/cloathing.
		}
		else
		{
            url = "seafloor.php?action=currents";
            string path = get_property("merkinQuestPath");
            //merkinQuestPath merkinVocabularyMastery
			int loathing_completion = 0;
			foreach it in $items[Goggles of Loathing,Stick-Knife of Loathing,Scepter of Loathing,Jeans of Loathing,Treads of Loathing,Belt of Loathing,Pocket Square of Loathing]
				loathing_completion += MIN(1, it.available_amount());
			boolean can_fight_dad_sea_monkee = (loathing_completion >= 6);
			if (can_fight_dad_sea_monkee)
				image_name = "dad sea monkee";
            if (path == "gladiator")
            {
                subentry.entries.listAppend("Fight Shub-Jigguwatt.");
                image_name = "Shub-Jigguwatt";
            }
            else if (path == "scholar")
            {
                subentry.entries.listAppend("Fight Yog-Urt.");
                image_name = "Yog-Urt";
            }
			else
            {
                string [int] available_bosses = split_string_mutable("Shub-Jigguwatt,Yog-Urt", ",");
                if (can_fight_dad_sea_monkee)
                    available_bosses.listAppend("Dad Sea Monkee");
                subentry.entries.listAppend("Fight a temple boss.|*Either " + available_bosses.listJoinComponents(", ", "or"));
            }
            
            //Suggest acquiring a disguise if they lack it.
            //Suggest acquiring an outfit if they have none of the three.
            //Then details for each side. so complicated
            
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
            
            if (path.length() == 0 || path == "none")
            {
                string line = "Can acquire " + scholar_item + " (scholar) or " + gladiator_item + " (gladiator)";
                if (can_fight_dad_sea_monkee)
                    line += " or " + $item[pocket square of loathing] + " (dad)";
                subentry.entries.listAppend(line);
            }
            else if (path == "gladiator")
                subentry.entries.listAppend("Will acquire " + gladiator_item + ".");
            else if (path == "scholar")
                subentry.entries.listAppend("Will acquire " + scholar_item + ".");
            
            //FIXME suggest per-side suggestions
            if (true)
            {
                //gladiator:
            }
            if (true)
            {
                //scholar:
            }
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