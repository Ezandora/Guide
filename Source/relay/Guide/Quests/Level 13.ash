Record TFWMInternalModifier
{
    string description;
    boolean have;
    boolean obtainable_now;
    boolean obtainable_theoretically;
    float bonus;
    
    boolean from_familiar_equipment;
};

boolean TFWMInternalModifierEquals(TFWMInternalModifier a, TFWMInternalModifier b)
{
    if (a.description != b.description)
        return false;
    if (a.have != b.have)
        return false;
    if (a.obtainable_now != b.obtainable_now)
        return false;
    if (a.obtainable_theoretically != b.obtainable_theoretically)
        return false;
    if (a.bonus != b.bonus)
        return false;
    if (a.from_familiar_equipment != b.from_familiar_equipment)
        return false;
    return true;
}

TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus, boolean from_familiar_equipment)
{
    TFWMInternalModifier result;
    result.description = description;
    result.have = have;
    result.obtainable_now = obtainable_now;
    result.obtainable_theoretically = obtainable_theoretically;
    result.bonus = bonus;
    result.from_familiar_equipment = from_familiar_equipment;
    
    return result;
}

TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus)
{
    return TFWMInternalModifierMake(description, have, obtainable_now, obtainable_theoretically, bonus, false);
}

TFWMInternalModifier TFWMInternalModifierMake()
{
    return TFWMInternalModifierMake("", false, false, false, 0);
}

TFWMInternalModifier TFWMInternalModifierMake(skill s)
{
    effect e = s.to_effect();
    string description = s;
    if (e != $effect[none] && e.have_effect() == 0)
        description += " (cast)";
    
    float weight_modifier = 0.0;
    if (e != $effect[none])
        weight_modifier = e.numeric_modifier("familiar weight");
    else
        weight_modifier = s.numeric_modifier("familiar weight");
    
    return TFWMInternalModifierMake(description, s.have_skill(), s.have_skill(), s.have_skill(), weight_modifier);
}

TFWMInternalModifier TFWMInternalModifierMake(item equippable_item)
{
    if (equippable_item.available_amount() == 0)
        return TFWMInternalModifierMake();
    float weight_modifier = equippable_item.numeric_modifier("familiar weight");
    
    if (equippable_item == $item[crown of thrones])
        weight_modifier = 5.0;
    
    
    string description = equippable_item;
    if (equippable_item.equipped_amount() == 0)
        description += " (equip)";
    
    TFWMInternalModifier result = TFWMInternalModifierMake(description, true, true, true, weight_modifier);
    
    if (equippable_item.to_slot() == $slot[familiar])
        result.from_familiar_equipment = true;
    return result;
}

void listAppend(TFWMInternalModifier [int] list, TFWMInternalModifier entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


//Returns TRUE if they currently have, or can easily have, enough to pass.
boolean generateTowerFamiliarWeightMethod(string [int] how, string [int] immediately_obtainable, string [int] missing_potentials, FloatHandle missing_weight)
{
    missing_weight.f = 0.0;
    if (__quest_state["Level 13"].mafia_internal_step > 9) //no need
        return true;
    if (!__misc_state["In run"])
        return true;
    if (__misc_state["familiars temporarily blocked"])
        return true;
    
    
    //Not the best of solutions, but...
    
    TFWMInternalModifier [int] weight_modifiers;
    
    //amphibian sympathy
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[amphibian sympathy]));
    //leash of linguini
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[leash of linguini]));
    //empathy of the newt
    weight_modifiers.listAppend(TFWMInternalModifierMake($skill[empathy of the newt]));
    //knob goblin pet-buffing spray
    if ($item[knob goblin pet-buffing spray].available_amount() > 0 || dispensary_available() || $effect[heavy petting].have_effect() > 0)
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("knob goblin pet-buffing spray", true, true, true, 5.0));
    }
    else if (__misc_state["can equip just about any weapon"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("knob goblin pet-buffing spray (unlock cobb's knob dispensary)", false, false, true, 5.0));
    }
    //hippy concert
    if (get_property("sidequestArenaCompleted") == "hippy" && !get_property_boolean("concertVisited") || $effect[Optimist Primal].have_effect() > 0)
    {
        boolean have_effect = $effect[Optimist Primal].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("Optimist Primal (hippy concert)", have_effect, have_effect || !get_property_boolean("concertVisited"), true, 5.0));
    }
    //irradiated pet snacks
    if ($item[irradiated pet snacks].available_amount() > 0 || $effect[healthy green glow].have_effect() > 0)
    {
        boolean have_effect = $effect[healthy green glow].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("irradiated pet snacks", have_effect, true, true, 10.0));
    }
    else if (__misc_state["can eat just about anything"] || (__misc_state["can drink just about anything"] && __misc_state["VIP available"]))
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("irradiated pet snacks (semi-rare, menagerie level 2)", false, false, true, 10.0));
    }
    if (__misc_state["VIP available"] && __misc_state["can drink just about anything"])
    {
        if (get_property_int("_speakeasyDrinksDrunk") <3 && availableDrunkenness() >= 3)
        {
            boolean have_effect = lookupEffect("Hip to the Jive").have_effect() > 0;
            weight_modifiers.listAppend(TFWMInternalModifierMake("Speakeasy hot socks", have_effect, true, true, 10.0));
        }
        
    }
    //billiards
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 && !__misc_state["type 69 restrictions active"] || $effect[Billiards Belligerence].have_effect() > 0)
    {
        boolean have_effect = $effect[Billiards Belligerence].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("VIP Pool (play aggressively)", have_effect, have_effect || (get_property_int("_poolGames") <3), true, 5.0));
    }
    //tea party
    if (($item[&quot;DRINK ME&quot; potion].available_amount() > 0 || $effect[Down the Rabbit Hole].have_effect() > 0) && (!get_property_boolean("_madTeaParty") || $effect[You Can Really Taste the Dormouse].have_effect() > 0))
    {
        boolean have_effect = $effect[You Can Really Taste the Dormouse].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("Mad hatter (reinforced beaded headband)", have_effect, have_effect, true, 5.0));
    }
    //beastly paste
    if ($item[beastly paste].available_amount() > 0 || $effect[Beastly Flavor].have_effect() > 0)
    {
        boolean have_effect = $effect[Beastly Flavor].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("beastly paste (4 spleen)", have_effect, true, true, 3.0));
    }
    else if ($familiar[pair of stomping boots].familiar_is_usable())
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("beastly paste (4 spleen, stomp beasts)", false, false, true, 3.0));
    }
    //resolution
    if ($item[resolution: be kinder].available_amount() > 0 || $effect[Kindly Resolve].have_effect() > 0)
    {
        boolean have_effect = $effect[Kindly Resolve].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("resolution: be kinder", have_effect, true, true, 5.0));
    }
    else if ($skill[summon resolutions].have_skill() && __misc_state["bookshelf accessible"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("resolution: be kinder (summon)", false, false, true, 5.0));
    }
    //green candy heart
    if ($item[green candy heart].available_amount() > 0 || $effect[Heart of Green].have_effect() > 0)
    {
        boolean have_effect = $effect[Heart of Green].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("green candy heart", have_effect, true, true, 3.0));
    }
    else if ($skill[Summon Candy Hearts].have_skill() && __misc_state["bookshelf accessible"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("green candy heart (summon)", false, false, true, 3.0));
    }
    
    //sugar sheet, sugar shield
    if ($item[astral pet sweater].available_amount() == 0 && ($item[snow suit].available_amount() == 0 || $item[snow suit].numeric_modifier("familiar weight") < 10.0))
    {
        if ($item[sugar shield].available_amount() > 0)
            weight_modifiers.listAppend(TFWMInternalModifierMake($item[sugar shield]));
        else if ($item[sugar sheet].available_amount() > 0)
        {
            weight_modifiers.listAppend(TFWMInternalModifierMake("sugar shield (use sugar sheet)", false, true, true, 10.0, true));
        }
        else if ($skill[Summon Sugar Sheets].have_skill() && __misc_state["bookshelf accessible"])
        {
            //TFWMInternalModifier TFWMInternalModifierMake(string description, boolean have, boolean obtainable_now, boolean obtainable_theoretically, float bonus)
            weight_modifiers.listAppend(TFWMInternalModifierMake("sugar shield (summon sugar sheet)", false, false, true, 10.0, true));
        }
    }
    //ittah bittah hookah
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[ittah bittah hookah]));
    //lead necklace
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[lead necklace]));
    //snow suit - numeric_modifier($item[snow suit], "familiar weight")
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[snow suit]));
    //astral pet sweater
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[astral pet sweater]));
    
    //greaves of the whatever
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[greaves of the murk lord]));
    //furry halo
    weight_modifiers.listAppend(TFWMInternalModifierMake($item[furry halo]));
    //CoT, if they have the right familiars
    if ($familiars[Animated Macaroni Duck, Autonomous Disco Ball, Barrrnacle, Gelatinous Cubeling, Ghost Pickle on a Stick, Misshapen Animal Skeleton, Pair of Ragged Claws, Penguin Goodfella, Spooky Pirate Skeleton].have_familiar_replacement())
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake($item[crown of thrones]));
    }
    
    
    //Find best familiar equipment:
    TFWMInternalModifier best_familiar_equipment;
    foreach key in weight_modifiers
    {
        TFWMInternalModifier modifier = weight_modifiers[key];
        if (modifier.have && modifier.from_familiar_equipment)
        {
            if (modifier.bonus > best_familiar_equipment.bonus)
                best_familiar_equipment = modifier;
        }
    }
    
    float total = 0.0;
    foreach key in weight_modifiers
    {
        TFWMInternalModifier modifier = weight_modifiers[key];
        string description = modifier.description;
        description += " (+" + modifier.bonus.floor() + ")";
        if (modifier.have)
        {
            if (best_familiar_equipment.have && modifier.from_familiar_equipment && !TFWMInternalModifierEquals(best_familiar_equipment, modifier)) //not our chosen familiar equipment
                continue;
            how.listAppend(description);
            total += modifier.bonus;
        }
        else if (modifier.obtainable_now)
        {
            immediately_obtainable.listAppend(description);
        }
        else if (modifier.obtainable_theoretically)
        {
            missing_potentials.listAppend(description);
        }
        
    }
    missing_weight.f = MAX(0, 19 - total);
    
    if (numeric_modifier("familiar weight") >= 19.0)
        return true;
    if (total >= 19.0)
        return true;
    else
        return false;
}

boolean needMoreFamiliarWeightForTower()
{
    string [int] how;
    string [int] immediately_obtainable;
    string [int] missing_potentials;
    FloatHandle missing_weight;
    return !generateTowerFamiliarWeightMethod(how, immediately_obtainable, missing_potentials, missing_weight);
}


void QLevel13Init()
{
	//questL13Final
    
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL13Final");
    if (my_path_id() == PATH_BUGBEAR_INVASION)
        QuestStateParseMafiaQuestPropertyValue(state, "finished"); //never will start
	state.quest_name = "Naughty Sorceress Quest";
	state.image_name = "naughty sorceress lair";
	state.council_quest = true;
	//alternate idea: gate, mirror, stone mariachis, courtyard, tower... hmm, no
	
	state.state_boolean["past gates"] = (state.mafia_internal_step > 1);
	state.state_boolean["past keys"] = (state.mafia_internal_step > 3);
	state.state_boolean["past hedge maze"] = (state.mafia_internal_step > 4);
	state.state_boolean["past tower"] = (state.mafia_internal_step > 5);
	state.state_boolean["shadow will need to be defeated"] = !(state.mafia_internal_step < 9);
    //FIXME what paths don't fight the shadow?
    
	state.state_boolean["king waiting to be freed"] = (state.mafia_internal_step == 17);
    
    
	state.state_boolean["have relevant guitar"] = $items[acoustic guitarrr,heavy metal thunderrr guitarrr,stone banjo,Disco Banjo,Shagadelic Disco Banjo,Seeger's Unstoppable Banjo,Massive sitar,4-dimensional guitar,plastic guitar,half-sized guitar,out-of-tune biwa,Zim Merman's guitar,dueling banjo].available_amount() > 0;
    
	state.state_boolean["have relevant accordion"] = $items[stolen accordion,calavera concertina,Rock and Roll Legend,Squeezebox of the Ages,The Trickster's Trikitixa,toy accordion].available_amount() > 0;
	state.state_boolean["have relevant drum"] = $items[tambourine, big bass drum, black kettle drum, bone rattle, hippy bongo, jungle drum].available_amount() > 0;
    
    if (state.state_boolean["past keys"])
    {
        state.state_boolean["have relevant guitar"] = true;
        
        state.state_boolean["have relevant accordion"] = true;
        state.state_boolean["have relevant drum"] = true;
    }
	state.state_boolean["digital key used"] = state.state_boolean["past keys"]; //FIXME be finer-grained?
    
    boolean other_quests_completed = true;
    for i from 2 to 12
    {
        if (!__quest_state["Level " + i].finished)
            other_quests_completed = false;
    }
    if (other_quests_completed && my_level() >= 13)
        state.startable = true;
    
	
	__quest_state["Level 13"] = state;
	__quest_state["Lair"] = state;
}


void QLevel13GenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
	if (!__quest_state["Level 13"].in_progress)
		return;
	QuestState base_quest_state = __quest_state["Level 13"];
	ChecklistSubentry subentry;
	subentry.header = base_quest_state.quest_name;
    string url = "lair.php";
	
	string image_name = base_quest_state.image_name;
    
	boolean should_output_main_entry = true;
	if (base_quest_state.mafia_internal_step == 1)
	{
		//at three gates
		subentry.entries.listAppend("At three gates.");
        if (__misc_state["can use clovers"] && (availableDrunkenness() >= 3 || inebriety_limit() == 0))
        {
            //FIXME be better
            if ($items[large box,blessed large box].available_amount() == 0 && $items[bubbly potion,cloudy potion,dark potion,effervescent potion,fizzy potion,milky potion,murky potion,smoky potion,swirly potion].items_missing().count() > 0)
            {
                if (in_hardcore())
                    subentry.entries.listAppend("For potions, acquire a large box (fax, dungeons of doom) and meatpaste with a clover.");
                else
                    subentry.entries.listAppend("For potions, pull a large box and meatpaste with a clover.");
            }
        }
        else
            subentry.entries.listAppend("For potions, visit the dungeons of doom.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 2)
	{
		//past three gates, at mirror
		subentry.entries.listAppend("At mirror.");
        url = "lair1.php";
	}
	else if (base_quest_state.mafia_internal_step == 3)
	{
		//past mirror, at six keys
		subentry.entries.listAppend("Six keys.");
        url = "lair2.php";
	}
	else if (base_quest_state.mafia_internal_step == 4)
	{
        url = "lair3.php";
		//at hedge maze
		subentry.modifiers.listAppend("+67% item");
		subentry.entries.listAppend("Hedge maze. Find puzzles.");
		if (item_drop_modifier() < 66.666666667)
			subentry.entries.listAppend("Need more +item.");
        if ($item[hedge maze key].available_amount() == 0)
			subentry.entries.listAppend("Find the key.");
        else
			subentry.entries.listAppend("Find the way out.");
            
            
        monster pickpocket_monster = $monster[Topiary Golem];
        if (__misc_state["can pickpocket"] && pickpocket_monster != $monster[none])
        {
            int total_initiative_needed = pickpocket_monster.base_initiative;
            int initiative_needed = total_initiative_needed - initiative_modifier();
            if (initiative_needed > 0)
                subentry.entries.listAppend("Need " + initiative_needed + "% more initiative to pickpocket every turn.");
        }
		
	}
	else if (base_quest_state.mafia_internal_step > 4 && base_quest_state.mafia_internal_step < 11)
	{
		//at tower, time to kill monsters!
		subentry.entries.listAppend("Tower monsters.");
        
        //extremely strange bug here - quest tracking is off for tower monsters. need testing
        
        
        /*int level = -1;
        
        if (base_quest_state.mafia_internal_step == 8)
            level = 1;
        else if (base_quest_state.mafia_internal_step == 9)
            level = 2;
        else if (base_quest_state.mafia_internal_step == 10)
            level = 3;
        else if (base_quest_state.mafia_internal_step == 11)
            level = 4;
        else if (base_quest_state.mafia_internal_step == 12)
            level = 5;
        else if (base_quest_state.mafia_internal_step == 13)
            level = 6;
        if (level != -1)
        {
            string monster_item = __misc_state_string["Tower monster item " + level];
            if (monster_item.length() > 0)
                subentry.entries.listAppend("Level " + level + ", use " + monster_item + ".");
            else
                subentry.entries.listAppend("Level " + level + ".");
            if (level <= 3)
                url = "lair4.php";
            else
                url = "lair5.php";
        }*/
		//FIXME show levels and... um... all that
	}
	else if (base_quest_state.mafia_internal_step == 11 || base_quest_state.mafia_internal_step == 12)
	{
        url = "lair6.php";
		//past tower, at some sort of door code
		subentry.entries.listAppend("Puzzles.");
		subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (to shadow)");
	}
	else if (base_quest_state.mafia_internal_step == 13)
	{
        url = "lair6.php";
		//at top of tower (fight shadow??)
		//8 -> fight shadow
        int total_initiative_needed = $monster[Your Shadow].monster_initiative();
		subentry.modifiers.listAppend("+HP");
		subentry.modifiers.listAppend("+" + total_initiative_needed + "% init");
		subentry.entries.listAppend("Fight your shadow.");
        foreach it in $items[attorney's badge, navel ring of navel gazing]
        {
            if (it.available_amount() > 0 && it.equipped_amount() == 0)
                subentry.entries.listAppend("Possibly equip your " + it + ". (blocks shadow)");
        }
        
        string [int] healing_items_available;
        foreach it in $items[filthy poultice,gauze garter,red pixel potion,Dreadsylvanian seed pod,soggy used band-aid,Mer-kin healscroll,scented massage oil,extra-strength red potion,red potion]
        {
            if (it.available_amount() == 0)
                continue;
            if (it.available_amount() == 1)
                healing_items_available.listAppend(it.to_string());
            else
                healing_items_available.listAppend(it.pluralize());
        }
        if (healing_items_available.count() > 0)
            subentry.entries.listAppend("Healing items available: " + healing_items_available.listJoinComponents(", ", "and") + ".");
        else
            subentry.entries.listAppend("Might want to go find some healing items.");
            
            
        int initiative_needed = total_initiative_needed - initiative_modifier();
        if (initiative_needed > 0 && !$skill[Ambidextrous Funkslinging].have_skill())
            subentry.entries.listAppend("Need " + initiative_needed + "% more initiative.");
	}
	else if (base_quest_state.mafia_internal_step == 14 || base_quest_state.mafia_internal_step == 15)
	{
        url = "lair6.php";
		//counter familiars
        
        if (!__misc_state["familiars temporarily blocked"])
        {
            subentry.modifiers.listAppend("+familiar weight");
            subentry.entries.listAppend("Counter familiars. Need 20-pound familiars.");
            subentry.entries.listAppend("Have mafia do it: Quests" + __html_right_arrow_character + "Tower (complete)");
            familiar [int] missing_familiars;
            foreach f in $familiars[Mosquito,Angry Goat,Barrrnacle,Sabre-Toothed Lime,Levitating Potato]
            {
                if (f.have_familiar_replacement())
                    continue;
                missing_familiars.listAppend(f);
            }
            if (missing_familiars.count() > 0)
            {
                string [item] where_to_find_hatchlings;
                where_to_find_hatchlings[$item[mosquito larva]] = "Spooky forest."; //should have it
                where_to_find_hatchlings[$item[goat]] = "Combine goat cheese (goatlet, dairy goat, 40% drop) with anti-cheese from the atomic testing house in the desert beach.";
                where_to_find_hatchlings[$item[barrrnacle]] = "Find from a crusty pirate in the f'c'le. (15% drop)";
                where_to_find_hatchlings[$item[sabre-toothed lime cub]] = "Combine saber teeth (goatlet, sabre-toothed goat, 5% drop, or stone age hippy camp, 20% drop) with a lime. (Menagerie level 1, fruit golem, 15% drop)";
                where_to_find_hatchlings[$item[potato sprout]] = "Complete the daily dungeon, visit vending machine.";
                if (in_bad_moon())
                    where_to_find_hatchlings[$item[potato sprout]] += " Alternatively, adventure in the haunted conservatory.";
                    
                string [int] missing_description;
                foreach key in missing_familiars
                {
                    familiar f = missing_familiars[key];
                    
                    string line;
                    if (missing_description.count() > 0)
                        line += "<hr>";
                    line += f.hatchling.capitalizeFirstLetter();
                    if (f.hatchling.available_amount() > 0)
                    {
                        line += "|*Use your " + f.hatchling + ".";
                    }
                    else
                    {
                        line += "|*" + where_to_find_hatchlings[f.hatchling];
                    }
                    missing_description.listAppend(line);
                }
                subentry.entries.listAppend("Missing familiars: " + HTMLGenerateIndentedText(missing_description));
            }
            
            FloatHandle missing_weight;
            string [int] familiar_weight_how;
            string [int] familiar_weight_immediately_obtainable;
            string [int] familiar_weight_missing_potentials;
            boolean have_familiar_weight_for_tower = generateTowerFamiliarWeightMethod(familiar_weight_how, familiar_weight_immediately_obtainable, familiar_weight_missing_potentials,missing_weight);
            if (!have_familiar_weight_for_tower)
            {
                string [int] description;
                description.listAppend("Need +" + missing_weight.f.floor() + " familiar weight.");
                if (familiar_weight_how.count() > 0)
                    description.listAppend("Have " + familiar_weight_how.listJoinComponents(", ", "and") + ".");
                if (familiar_weight_immediately_obtainable.count() > 0)
                    description.listAppend("Could use " + familiar_weight_immediately_obtainable.listJoinComponents(", ", "and") + ".");
                if (familiar_weight_missing_potentials.count() > 0 && missing_weight.f > 0.0)
                    description.listAppend("Could acquire " + familiar_weight_missing_potentials.listJoinComponents(", ", "or") + ".");
                
                subentry.entries.listAppend(description.listJoinComponents("|*"));
            }
        }
        else
            subentry.entries.listAppend("Counter familiars.");
	}
	else if (base_quest_state.mafia_internal_step == 16)
	{
        url = "lair6.php";
		//At NS. Good luck, we're all counting on you.
		subentry.modifiers.listAppend("+moxie equipment");
		subentry.modifiers.listAppend("no buffs");
		subentry.entries.listAppend("She awaits.");
        if (!__misc_state["familiars temporarily blocked"])
        {
            if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[swashbuckling pants].available_amount() > 0)
                subentry.entries.listAppend("Run swashbuckling pants on scarecrow. (2x potato)");
            else if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0)
                subentry.entries.listAppend("Run spangly mariachi pants on scarecrow. (2x potato)");
            else if (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0)
                subentry.entries.listAppend("Run spangly sombrero on mad hatrack. (2x potato)");
            else
                subentry.entries.listAppend("Run a potato familiar if you can.");
        }
		image_name = "naughty sorceress";
	}
	else if (base_quest_state.mafia_internal_step == 17)
	{
        url = "lair6.php";
		//King is waiting in his prism.
        
        boolean trophies_are_possible = false;
        
        //ehh, disable displaying this, mostly because it's in the way
        //if (in_hardcore())
            //trophies_are_possible = true; //Gourdcore, Golden Meat Stack
        
        if (trophies_are_possible)
            task_entries.listAppend(ChecklistEntryMake("__item puzzling trophy", "trophy.php", ChecklistSubentryMake("Check for trophies", "10k meat, trophy requirements", "Certain trophies are missable after freeing the king")));
		should_output_main_entry = false;
		
	}
	if (should_output_main_entry)
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentry));
}