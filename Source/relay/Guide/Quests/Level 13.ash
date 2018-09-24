import "relay/Guide/Support/Spell Damage.ash"
import "relay/Guide/Support/Passive Damage.ash"
import "relay/Guide/Support/Item Filter.ash"


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
    
    return TFWMInternalModifierMake(description, s.skill_is_usable(), s.skill_is_usable(), s.skill_is_usable(), weight_modifier);
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
//Example use:
/*
    string [int] how;
    string [int] immediately_obtainable;
    string [int] missing_potentials;
    FloatHandle missing_weight;
    return !generateTowerFamiliarWeightMethod(how, immediately_obtainable, missing_potentials, missing_weight);
*/
boolean generateTowerFamiliarWeightMethod(string [int] how, string [int] immediately_obtainable, string [int] missing_potentials, FloatHandle missing_weight)
{
    missing_weight.f = 0.0;
    if (__quest_state["Level 13"].finished) //no need
        return true;
    if (!__misc_state["in run"])
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
        if (get_property_int("_speakeasyDrinksDrunk") <3 && availableDrunkenness() >= 3 && $item[clan speakeasy].is_unrestricted())
        {
            boolean have_effect = $effect[1701].have_effect() > 0; //hip to the jive
            weight_modifiers.listAppend(TFWMInternalModifierMake("Speakeasy hot socks", have_effect, true, true, 10.0));
        }
        
    }
    //billiards
    if (__misc_state["VIP available"] && get_property_int("_poolGames") <3 && $item[Clan pool table].is_unrestricted() || $effect[Billiards Belligerence].have_effect() > 0)
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
    else if ($skill[summon resolutions].skill_is_usable() && __misc_state["bookshelf accessible"])
    {
        weight_modifiers.listAppend(TFWMInternalModifierMake("resolution: be kinder (summon)", false, false, true, 5.0));
    }
    //green candy heart
    skill candy_hearts = $skill[Summon Candy Heart];
    if ($item[green candy heart].available_amount() > 0 || $effect[Heart of Green].have_effect() > 0)
    {
        boolean have_effect = $effect[Heart of Green].have_effect() > 0;
        weight_modifiers.listAppend(TFWMInternalModifierMake("green candy heart", have_effect, true, true, 3.0));
    }
    else if (candy_hearts.skill_is_usable() && __misc_state["bookshelf accessible"] && candy_hearts != $skill[none])
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
        else if ($skill[Summon Sugar Sheets].skill_is_usable() && __misc_state["bookshelf accessible"])
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


            
string generatePotatoSuggestion()
{
    if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[swashbuckling pants].available_amount() > 0)
        return "Run swashbuckling pants on scarecrow. (2x potato)";
    else if (familiar_is_usable($familiar[fancypants scarecrow]) && $item[spangly mariachi pants].available_amount() > 0)
        return "Run spangly mariachi pants on scarecrow. (2x potato)";
    else if (familiar_is_usable($familiar[mad hatrack]) && $item[spangly sombrero].available_amount() > 0)
        return "Run spangly sombrero on mad hatrack. (2x potato)";
    else
        return "Run a potato familiar if you can.";
}


void QLevel13Init()
{
	//questL13Final
    
	QuestState state;
	QuestStateParseMafiaQuestProperty(state, "questL13Final");
    if (my_path_id() == PATH_BUGBEAR_INVASION || __misc_state["in aftercore"] || (!state.in_progress && my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING) || my_path_id() == PATH_COMMUNITY_SERVICE) //FIXME mafia may track the ed L13 quest under this variable
        QuestStateParseMafiaQuestPropertyValue(state, "finished"); //never will start
	if (__misc_state["Example mode"])
        QuestStateParseMafiaQuestPropertyValue(state, "step6");
	state.quest_name = "Naughty Sorceress Quest";
	state.image_name = "naughty sorceress lair";
	state.council_quest = true;
	
    state.state_string["Stat race type"] = ""; //telescope1
    state.state_string["Elemental damage race type"] = ""; //telescope2
    
    //FIXME these all need checking:
    string [string] telescope1_messages_to_type;
    telescope1_messages_to_type["all wearing sunglasses and dancing"] = "moxie";
    telescope1_messages_to_type["standing around flexing their muscles and using grip exercisers"] = "muscle";
    telescope1_messages_to_type["sitting around playing chess and solving complicated-looking logic puzzles"] = "mysticality";
    
    string [string] telescope2_messages_to_type;
    telescope2_messages_to_type["greasy-looking people furtively skulking around"] = "sleaze";
    telescope2_messages_to_type["people, all of whom appear to be on fire"] = "hot"; //???
    telescope2_messages_to_type["people, clustered around a group of igloos"] = "cold";
    telescope2_messages_to_type["people, surrounded by a cloud of eldritch mist"] = "spooky"; //???
    telescope2_messages_to_type["people, surrounded by garbage and clouds of flies"] = "stench";
    
    string [string] telescope3_messages_to_type;
    string [string] telescope4_messages_to_type;
    string [string] telescope5_messages_to_type;
    
    telescope3_messages_to_type["creepy-looking black bushes on the outskirts of a hedge maze"] = "spooky";
    telescope3_messages_to_type["nasty-looking, dripping green bushes on the outskirts of a hedge maze"] = "stench"; //stench? sleaze?
    telescope3_messages_to_type["purplish, greasy-looking hedges"] = "sleaze"; //???
    telescope3_messages_to_type["smoldering bushes on the outskirts of a hedge maze"] = "hot"; //???
    telescope3_messages_to_type["frost-rimed bushes on the outskirts of a hedge maze"] = "cold";
    
    telescope4_messages_to_type["a greasy purple cloud hanging over the center of the maze"] = "sleaze";
    telescope4_messages_to_type["smoke rising from deeper within the maze"] = "hot"; //????
    telescope4_messages_to_type["a miasma of eldritch vapors rising from deeper within the maze"] = "spooky"; //????
    telescope4_messages_to_type["a cloud of green gas hovering over the maze"] = "stench"; //????
    telescope4_messages_to_type["wintry mists rising from deeper within the maze"] = "cold";
    
    telescope5_messages_to_type["occasionally disgorging a bunch of ice cubes"] = "cold";
    telescope5_messages_to_type["that occasionally vomits out a greasy ball of hair"] = "sleaze"; //???
    telescope5_messages_to_type["surrounded by creepy black mist"] = "spooky"; //???
    telescope5_messages_to_type["disgorging a really surprising amount of sewage"] = "stench"; //???
    telescope5_messages_to_type["with lava slowly oozing out of it"] = "hot"; //???
    
    state.state_string["Stat race type"] = get_property("nsChallenge1"); //telescope1_messages_to_type[get_property("telescope1")];
    if (state.state_string["Stat race type"] == "none")
        state.state_string["Stat race type"] = "";
    state.state_string["Elemental damage race type"] = get_property("nsChallenge2"); //telescope2_messages_to_type[get_property("telescope2")];
    if (state.state_string["Elemental damage race type"] == "none")
        state.state_string["Elemental damage race type"] = "";
    
    string [int] elements_needed = listMake(telescope3_messages_to_type[get_property("telescope3")], telescope4_messages_to_type[get_property("telescope4")], telescope5_messages_to_type[get_property("telescope5")]);
    
    boolean have_all_elements = true;
    foreach key, e in elements_needed
    {
        if (e.length() == 0)
        {
            have_all_elements = false;
            break;
        }
    }
    state.state_string["Hedge maze elements needed"] = "";
    if (have_all_elements)
        state.state_string["Hedge maze elements needed"] = elements_needed.listJoinComponents("|");
    
    state.state_boolean["past races"] = state.mafia_internal_step >= 4;
    
    state.state_boolean["Init race completed"] = get_property_int("nsContestants1") != -1;
    state.state_boolean["Stat race completed"] = get_property_int("nsContestants2") != -1;
    state.state_boolean["Elemental damage race completed"] = get_property_int("nsContestants3") != -1;
    if (state.finished || state.state_boolean["past races"])
    {
        state.state_boolean["Init race completed"] = true;
        state.state_boolean["Stat race completed"] = true;
        state.state_boolean["Elemental damage race completed"] = true;
    }
    
	state.state_boolean["past hedge maze"] = state.mafia_internal_step >= 6;
	state.state_boolean["past keys"] = state.mafia_internal_step >= 7;
    
    state.state_boolean["past tower level 1"] = state.mafia_internal_step >= 8;
    state.state_boolean["past tower level 2"] = state.mafia_internal_step >= 9;
    state.state_boolean["past tower level 3"] = state.mafia_internal_step >= 10;
    state.state_boolean["past tower level 4"] = state.mafia_internal_step >= 11;
    state.state_boolean["past tower level 5"] = state.mafia_internal_step >= 12;
    
	state.state_boolean["past tower monsters"] = state.state_boolean["past tower level 3"]; //5
	state.state_boolean["wall of skin will need to be defeated"] = !state.state_boolean["past tower level 1"];
	state.state_boolean["wall of meat will need to be defeated"] = !state.state_boolean["past tower level 2"];
	state.state_boolean["wall of bones will need to be defeated"] = !state.state_boolean["past tower level 3"];
	state.state_boolean["shadow will need to be defeated"] = !state.state_boolean["past tower level 5"];
    //FIXME what paths don't fight the shadow?
	state.state_boolean["king waiting to be freed"] = (state.mafia_internal_step >= 14 && !state.finished);
    
    
    boolean [string] known_key_names = $strings[Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key];
    foreach key_name in known_key_names
    {
        state.state_boolean[key_name + " used"] = state.state_boolean["past keys"];
    }
    
    if (!state.state_boolean["past keys"])
    {
        //nsTowerDoorKeysUsed
        //nsTowerDoorKeysUsed(user, now 'Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,digital key,skeleton key', default )
        
        string [int] keys_used = split_string_alternate(get_property("nsTowerDoorKeysUsed"), ",");
        
        foreach index, key_name in keys_used
        {
            //FIXME implement this
            //Boris's, Jarlsberg's, Sneaky Pete's, star, skeleton key, and digital
            if (!(known_key_names contains key_name))
            {
                continue;
            }
            state.state_boolean[key_name + " used"] = true;
        }
    }
    
    //Silent, Shell Up, Sauceshell
    
    boolean other_quests_completed = true;
    for i from 2 to 12
    {
        if (!__quest_state["Level " + i].finished)
        {
            other_quests_completed = false;
        }
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
    ChecklistSubentry [int] subentries;
    subentries.listAppend(subentry);
	subentry.header = base_quest_state.quest_name;
    string url = "place.php?whichplace=nstower";
	
	string image_name = base_quest_state.image_name;
    
	boolean should_output_main_entry = true;
    if (!base_quest_state.state_boolean["past races"] && (base_quest_state.state_string["Stat race type"].length() == 0 || base_quest_state.state_string["Elemental damage race type"].length() == 0))
    {
        subentry.header = "Visit the registration desk";
        subentry.entries.listAppend("Find out what the races are, first.");
        image_name = "lair registration desk";
    }
    else if (base_quest_state.mafia_internal_step == 3)
    {
        image_name = "lair registration desk";
        subentry.header = "Visit the registration desk";
        subentry.entries.listAppend("Claim your prize!");
        url = "place.php?whichplace=nstower&action=ns_01_contestbooth";
    }
    else if (!base_quest_state.state_boolean["past races"])
    {
        image_name = "lair registration desk";
        remove subentries[0];
        
        if (!base_quest_state.state_boolean["Init race completed"])
        {
            string [int] description;
            float current_value = numeric_modifier("initiative");
            
            description.listAppend("Currently " + current_value.floor() + "%.");
            
            if (current_value < 400.0)
            {
                description.listAppend("Need " + (400.0 - current_value).roundForOutput(1) + "% more initiative for #2.");
                
                if (!($familiars[oily woim,Xiblaxian Holo-Companion] contains my_familiar()) && !__misc_state["familiars temporarily blocked"])
                {
                    familiar [int] init_familiar_evaluation_order;
                    init_familiar_evaluation_order.listAppend($familiar[Xiblaxian Holo-Companion]);
                    init_familiar_evaluation_order.listAppend($familiar[oily woim]);
                    foreach key, f in init_familiar_evaluation_order
                    {
                        if (f.familiar_is_usable())
                        {
                            description.listAppend("Try switching to your " + f + ".");
                            break;
                        }
                    }
                }
                if (__misc_state_int["pulls available"] > 0)
                {
                    boolean [item] blacklist;// = $items[hare brush,freddie's blessing of mercury,ruby on canes];
                    item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Initiative", 30, blacklist);
                    string [int] relevant_potions_output;
                    foreach key, it in relevant_potions
                    {
                    	float initiative_modifier = it.to_effect().numeric_modifier("Initiative");
                        if ($effect[Bow-Legged Swagger].have_effect() > 0)
                        	initiative_modifier *= 2.0;
                        relevant_potions_output.listAppend(it + " (" + initiative_modifier.roundForOutput(0) + "%)");
                    }
                    
                    if (relevant_potions_output.count() > 0)
                        description.listAppend("Could try pulling " + relevant_potions_output.listJoinComponents(", ", "or") + ".");
                }
            }
            else
                description.listAppend("Take the test now, you should(?) make second place.");
            
            subentries.listAppend(ChecklistSubentryMake("Compete in the init race", "+init", description));
        }
        if (!base_quest_state.state_boolean["Stat race completed"])
        {
            stat stat_type = base_quest_state.state_string["Stat race type"].to_stat();
            string [int] description;
            float current_value = my_buffedstat(stat_type);
            
            
            //FIXME find this value; current is a guess
            //highest seen #3 is 577 moxie
            if (current_value < 600.0)
            {
                description.listAppend("Need " + (600.0 - current_value).roundForOutput(1) + " more " + stat_type.to_lower_case() + " for #2.");
            }
            else
                description.listAppend("Take the test now, you should(?) make second place.");
                
            if (stat_type != $stat[none] && current_value < 600.0)
            {
                if (__misc_state_int["pulls available"] > 0)
                {
                    float base_stat = MAX(1.0, my_basestat(stat_type));
                    
                    //R&uuml;mpelstiltz,gummi snake,handful of laughing willow bark,dennis's blessing of minerva,smart watch,mer-kin smartjuice,lump of saccharine maple sap,burt's blessing of bacchus,augmented-reality shades,mer-kin cooljuice,lobos mints,mariachi toothpaste,disco horoscope (virgo),pressurized potion of pulchritude,pressurized potion of perspicacity,pressurized potion of puissance,handful of crotchety pine needles,bruno's blessing of mars,fitness wristband,gummi salamander,bottle of fire,banana smoothie,banana supersucker,ennui-flavored potato chips,moonds,ultrasoldier serum,kumquat supersucker,mer-kin strongjuice,
                    boolean [item] blacklist = $items[snake,M-242,sparkler]; //limited/expensive/unusable content
                    item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier(stat_type, MIN(600 - current_value, 25), blacklist);
                    item [int] relevant_potions_source_2 = ItemFilterGetPotionsCouldPullToAddToNumericModifier(stat_type + " percent", 25.0 / base_stat * 100.0, blacklist);
                    
                    relevant_potions.listAppendList(relevant_potions_source_2);
                    
                    sort relevant_potions by -(value.to_effect().numeric_modifier(stat_type) + (value.to_effect().numeric_modifier(stat_type + " percent") / 100.0 * my_basestat(stat_type)));
                    
                    
                    string [int] relevant_potions_output;
                    foreach key, it in relevant_potions
                    {
                        float total = (it.to_effect().numeric_modifier(stat_type) + (it.to_effect().numeric_modifier(stat_type + " percent") / 100.0 * my_basestat(stat_type)));
                        string line = it + " (" + total.roundForOutput(1) + ")";
                        //if (it.mall_price() >= 15000) //for internal use, to fill out the blacklist
                            //line = HTMLGenerateSpanFont(line, "red", "");
                        relevant_potions_output.listAppend(line);
                    }
                    
                    if (relevant_potions_output.count() > 0)
                        description.listAppend("Could try pulling " + relevant_potions_output.listJoinComponents(", ", "or") + ".");
                }
            }
            
            subentries.listAppend(ChecklistSubentryMake("Compete in the " + stat_type + " race", "+" + stat_type.to_string().to_lower_case(), description));
        }
        if (!base_quest_state.state_boolean["Elemental damage race completed"])
        {
            element element_type = base_quest_state.state_string["Elemental damage race type"].to_element();
            
            string [int] description;
            
            string element_class = "r_element_" + element_type;
            string element_class_desaturated = element_class + "_desaturated";
            
            float current_value = numeric_modifier(element_type + " damage") + numeric_modifier(element_type + " spell damage");
            if (current_value < 100.0)
            {
                description.listAppend("Need " + (100.0 - current_value).roundForOutput(1) + " more " + HTMLGenerateSpanOfClass(element_type + " damage ", element_class) + " + " + HTMLGenerateSpanOfClass(element_type + " spell damage", element_class) + " for #2.");
                
                
                if (__misc_state_int["pulls available"] > 0)
                {
                    boolean [item] blacklist = $items[witch's brew,boiling seal blood];
                    item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier(listMake(element_type + " damage", element_type + " spell damage"), 30, blacklist);
                    string [int] relevant_potions_output;
                    foreach key, it in relevant_potions
                    {
                        relevant_potions_output.listAppend(it + " (" + (it.to_effect().numeric_modifier(element_type + " damage") + it.to_effect().numeric_modifier(element_type + " spell damage")).roundForOutput(0) + ")");
                    }
                    
                    if (relevant_potions_output.count() > 0)
                        description.listAppend("Could try pulling " + relevant_potions_output.listJoinComponents(", ", "or") + ".");
                }
            }
            else
                description.listAppend("Take the test now, you should(?) make second place.");
            description.listAppend("Currently " + current_value.roundForOutput(1) + ".");
            
            subentries.listAppend(ChecklistSubentryMake("Compete in the " + HTMLGenerateSpanOfClass(element_type + " damage", element_class) + " race", listMake("+" + HTMLGenerateSpanOfClass(element_type + " damage", element_class_desaturated), "+" + HTMLGenerateSpanOfClass(element_type + " spell damage", element_class_desaturated)), description));
        }
        
        int total_contestants_to_fight = 0;
        foreach s in $strings[nsContestants1,nsContestants2,nsContestants3]
        {
            if (get_property_int(s) > 0)
                total_contestants_to_fight += get_property_int(s);
        }
        if (total_contestants_to_fight > 0)
        {
            subentries.listAppend(ChecklistSubentryMake("Fight " + pluraliseWordy(total_contestants_to_fight, "more contestant", "more contestants"), "", ""));
        }
        else if (subentries.count() == 0)
        {
            //hmm...
            subentries.listAppend(ChecklistSubentryMake("Visit the registration desk", "", "Claim your prize!"));
            url = "place.php?whichplace=nstower&action=ns_01_contestbooth";
        }
        else if (total_contestants_to_fight == 0)
            url = "place.php?whichplace=nstower&action=ns_01_contestbooth";
        //nsContestants1 - default -1
        //nsContestants2 - default -1
        //nsContestants3 - default -1
    }
    else if (base_quest_state.mafia_internal_step == 4)
    {
        subentry.header = "Attend your coronation";
        image_name = "__item Snow Queen Crown";
    }
    else if (!base_quest_state.state_boolean["past hedge maze"])
    {
        //FIXME individualised room support
        //need X more hot resistance, Y more Z resistance to pass elemental tests
        subentry.header = "Find your way through the Hedge Maze";
        image_name = "__item hedge maze puzzle";
        int current_room = get_property_int("currentHedgeMazeRoom");
        if (current_room >= 9)
        {
            subentry.entries.listAppend("Almost there...");
        }
        else
        {
            int [element] elements_needed_to_pass;
            string [int] resists_needed_for_hedge_maze = base_quest_state.state_string["Hedge maze elements needed"].split_string_alternate("\\|");
            float total_damage_taken_from_resists = 0.0;
            if (resists_needed_for_hedge_maze.count() > 0)
            {
                foreach key, element_name in resists_needed_for_hedge_maze
                {
                    element e = element_name.to_element();
                    if (e == $element[none]) //wha?
                        continue;
                    elements_needed_to_pass[e] = 7;
                    float percentage = 0.0;
                    if (key == 0) percentage = 0.9;
                    if (key == 1) percentage = 0.8;
                    if (key == 2) percentage = 0.7;
                    float resist = e.elemental_resistance() / 100.0;
                    float damage_taken = my_maxhp() * percentage * (1.0 - resist);
                    total_damage_taken_from_resists += damage_taken;  
                }
            }
            else
            {
            	total_damage_taken_from_resists = 10000;
                elements_needed_to_pass[$element[hot]] = 7;
                elements_needed_to_pass[$element[stench]] = 7;
                elements_needed_to_pass[$element[spooky]] = 7;
                elements_needed_to_pass[$element[cold]] = 7;
                elements_needed_to_pass[$element[sleaze]] = 7;
            }
            
            int [element] amount_missing;
            foreach e, amount_needed in elements_needed_to_pass
            {
                subentry.modifiers.listAppend("+" + HTMLGenerateSpanOfClass(amount_needed + " " + e + " resistance", "r_element_" + e + "_desaturated"));
                float amount_have = numeric_modifier(e + " resistance");
                if (amount_have < amount_needed)
                {
                    amount_missing[e] = amount_needed - amount_have;
                }
            }
            if (amount_missing.count() > 0 && total_damage_taken_from_resists >= my_maxhp())
            {
                if ($familiar[exotic parrot].familiar_is_usable() && !__misc_state["familiars temporarily blocked"])
                    subentry.entries.listAppend("Potentially switch to the exotic parrot.");
                
                string [int] amount_missing_string;
                foreach e, amount in amount_missing
                {
                    amount_missing_string.listAppend(HTMLGenerateSpanOfClass(amount + " more " + e + " resistance", "r_element_" + e));
                }
                subentry.entries.listAppend("Need " + amount_missing_string.listJoinComponents(", ", "and") + " to safely make it through the maze quickly.");
            }
            else
            {
                subentry.modifiers.listClear();
                subentry.entries.listAppend("Choose the second option each time to save the most turns.");
            }
            if (my_hp() < my_maxhp() && current_room <= 1)
            {
                //FIXME only output this if we won't make it.
                subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
            }
        }
            
        //elemental tests are 1, 4, 7
        //9 is escape
        //subentry.entries.listAppend("currentHedgeMazeRoom = " + get_property_int("currentHedgeMazeRoom"));
    }
    else if (!base_quest_state.state_boolean["past keys"])
    {
        url = "place.php?whichplace=nstower_door";
        subentry.header = "Open the tower door";
        
        string [int] keys_to_use;
        item [int] missing_keys;
        boolean [string] known_key_names = $strings[Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key];
        foreach key_name in known_key_names
        {
            if (!base_quest_state.state_boolean[key_name + " used"])
            {
                item key_item = key_name.to_item();
                string key_name_output = key_name.replace_string(" key", "");
                if (key_item.available_amount() == 0)
                {
                    key_name_output = HTMLGenerateSpanFont(key_name_output, "grey");
                    missing_keys.listAppend(key_item);
                }
                keys_to_use.listAppend(key_name_output);
            }
        }
        
        if (keys_to_use.count() == 0)
        {
            subentry.entries.listAppend("Open the doorknob.");
        }
        else
        {
            subentry.entries.listAppend("Use " + pluraliseWordy(keys_to_use.count(), "more key", "more keys") + " on the perplexing door: " + keys_to_use.listJoinComponents(", ", "and") + ".");
        }
        if (missing_keys.count() > 0)
        {
            subentry.entries.listAppend("Find the " + missing_keys.listJoinComponents(", ", "and") + ".");
        }
    }
    else if (!base_quest_state.state_boolean["past tower level 1"])
    {
        //wall of skin
        subentry.header = "Defeat the Wall of Skin";
        if ($item[beehive].available_amount() > 0)
        {
            subentry.entries.listAppend("Use the beehive against it.");
        }
        else
        {
            subentry.entries.listAppend("Either find the beehive in the black forest (-combat), or towerkill.");
            subentry.entries.listAppend("Lots of passive damage sources.");
            subentry.entries.listAppend("This will be suggested in a future version, sorry...|Good luck!");
            //FIXME REST
            //adding passive damage sources, calculating their effect
            //possibly do it externally, such that we can reuse it for the sea and removing it for level three?
            if (my_hp() < my_maxhp())
            {
                //FIXME only output this if we won't make it.
                subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
            }
        }
    }
    else if (!base_quest_state.state_boolean["past tower level 2"])
    {
        //wall of meat
        //current assumption is it's a [160, 240] drop, and you need to clear one thousand (thousand slimy) meats
        subentry.header = "Defeat the Wall of Meat";
        subentry.modifiers.listAppend("+526% meat");
        
        float current_value = numeric_modifier("meat drop");
        if (current_value < 526.0)
        {
            subentry.entries.listAppend("Need " + (526.0 - current_value).roundForOutput(0) + "% more meat drop to always complete in a single turn.");
            
            float meat_multiplier = 1.0 + current_value / 100.0;
            float chance = 1.0 - TriangularDistributionCalculateCDF(1001.0, 160.0 * meat_multiplier, 240.0 * meat_multiplier);
            if (chance > 0.0)
                subentry.entries.listAppend((chance * 100.0).floor() + "% chance of completing in one turn.");
        }
        else
            subentry.entries.listAppend("Should take one turn.");
        
        if (__misc_state_int["pulls available"] > 0 && current_value < 526.0)
        {
            float delta = 526.0 - current_value;
            boolean [item] blacklist = $items[uncle greenspan's bathroom finance guide,black snowcone,sorority brain,blue grass,salt wages,perl necklace];
            item [int] relevant_potions = ItemFilterGetPotionsCouldPullToAddToNumericModifier("Meat Drop", MIN(25, delta), blacklist);
            string [int] relevant_potions_output;
            foreach key, it in relevant_potions
            {
                relevant_potions_output.listAppend(it + " (" + it.to_effect().numeric_modifier("meat drop").roundForOutput(0) + "%)");
            }
            
            if (relevant_potions_output.count() > 0)
                subentry.entries.listAppend("Could try pulling " + relevant_potions_output.listJoinComponents(", ", "or") + ".");
        }
        //FIXME does mafia have a tracking variable for meat dropped?
        //FIXME REST
        //estimated turns?
        if (my_hp() < my_maxhp())
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
        }
    }
    else if (!base_quest_state.state_boolean["past tower level 3"])
    {
        subentry.header = "Defeat the Wall of Bones";
        //wall of bones
        if ($item[electric boning knife].available_amount() > 0)
        {
            subentry.entries.listAppend("Use the electric boning knife against it.");
        }
        else
        {
            //suggest towerkilling methods
            //removing passive damage sources
            //support saucegeyser, intimidating mien, grease up, and future airport skills (or lack thereof)
            //strategy: saucegeyser three times, then either saucegeyser One More Time or unleash grease up/intimidating mien/future airport skills
            //FIXME REST
            subentry.entries.listAppend("Either find the electric boning knife on the ground floor of the castle in the clouds in the sky (-combat), or towerkill:");
            subentry.entries.listAppend("Make sure to remove all sources of passive damage.");
            
            string [int] passives_to_remove = PDSGenerateDescriptionToUneffectPassives();
            if (passives_to_remove.count() > 0)
                subentry.entries.listAppend(HTMLGenerateSpanFont(passives_to_remove.listJoinComponents("|"), "red"));
            //FIXME HACK USE A LIBRARY
            /*string [int] things_to_do;
            foreach it in $items[hand in glove,MagiMechTech NanoMechaMech,bottle opener belt buckle,old school calculator watch,ant hoe,ant pick,ant pitchfork,ant rake,ant sickle,fishy wand,moveable feast,oversized fish scaler,plastic pumpkin bucket,tiny bowler,cup of infinite pencils,double-ice box,smirking shrunken head,mr. haggis,stapler bear,dubious loincloth,muddy skirt,bottle of Goldschn&ouml;ckered,acid-squirting flower,ironic oversized sunglasses,hippy protest button,cannonball charrrm bracelet,groovy prism necklace,spiky turtle shoulderpads,double-ice cap,parasitic headgnawer,eelskin hat,balloon shield,hot plate,Ol' Scratch's stove door,Oscus's garbage can lid,eelskin shield,eelskin pants,buddy bjorn]
            {
                if (it.equipped_amount() > 0)
                    things_to_do.listAppend("unequip " + it);
            }
            foreach e in $effects[Skeletal Warrior,Skeletal Cleric,Skeletal Wizard,Bone Homie,Burning\, Man,Biologically Shocked,EVISCERATE!,Fangs and Pangs,Permanent Halloween,Curse of the Black Pearl Onion,Long Live GORF,Apoplectic with Rage,Dizzy with Rage,Quivering with Rage,Jaba&ntilde;ero Saucesphere,Psalm of Pointiness,Drenched With Filth,Stuck-Up Hair,It's Electric!,Smokin',Jalape&ntilde;o Saucesphere,Scarysauce,spiky shell]
            {
                if (e.have_effect() > 0)
                    things_to_do.listAppend("uneffect " + e);
            }
            if (things_to_do.count() > 0)
                subentry.entries.listAppend(HTMLGenerateSpanFont(things_to_do.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".", "red"));*/
            
            //FIXME Firegate - spade, etc
            
            //Firegate is 100% myst, +30-40 damage, but unaffected by spell damage % (and possibly spell damage?)
            //Garbage nova is 40% myst, etc, but affected by spell damage %/spell damage.
            //So, we have to calculate which one is better and suggest that. (garbage nova may be better, in fact)
            if ($skill[Garbage Nova].skill_is_usable())
            {
                //Special note on calculations:
                //Spell damage percent is multiplied before the group size multiplier, then floored.
                //I believe this means against a size 100 monster, garbage nova will always deal damage in multiples of 50
                //It also means estimation can be wildly off without taking that into account.
                //Also, stench spell damage counts double, maybe?
                float buffed_myst = my_buffedstat($stat[mysticality]);
                float spell_damage = numeric_modifier("spell damage");
                float stench_spell_damage = numeric_modifier("stench spell damage");
                float spell_damage_percent = numeric_modifier("spell damage percent");
                float monster_level = monster_level_adjustment_ignoring_plants();
                float spell_damage_multiplier = 1.0 + spell_damage_percent / 100.0;
                float monster_damage_multiplier = 1.0 - min(50.0, monster_level * 0.4) / 100.0;
                
                //Estimate: 62894
                //Actual: 63263
                
                //Current damage formulas:
                //min = floor((45.0 + floor(0.4 * buffed_myst) + spell_damage + stench_spell_damage * 2.0) * (1.0 + spell_damage_percent / 100.0)) * ceil(group_size * 0.5)
                //max = floor((50.0 + floor(0.4 * buffed_myst) + spell_damage + stench_spell_damage * 2.0) * (1.0 + spell_damage_percent / 100.0)) * ceil(group_size * 0.5)
                //group_size = 100
                //then apply damage resistance: damage_out = floor(damage_in * (1.0 - min(50.0, ml * 0.4)) / 100.0));
                //damage must be >= 5k
                
                string [int] tasks;
                
                int min_myst_needed = 1000;
                //5000 = floor(floor((45.0 + floor(0.4 * buffed_myst) + spell_damage + stench_spell_damage * 2.0) * spell_damage_multiplier) * 50.0 * monster_damage_multiplier)
                //approximation:
                //buffed_myst = 2.5 * (5000 / monster_damage_multiplier / 50.0 / spell_damage_multiplier - spell_damage - stench_spell_damage * 2.0 - 45.0)
                //hmm... 138 to 388 myst without anything else? yes
                //though -100 myst with 50 stench spell damage is also enough
                
                float divisor = monster_damage_multiplier * 50.0 * spell_damage_multiplier;
                if (divisor == 0.0)
                    divisor = 0.001;
                min_myst_needed = ceil(2.5 * (5000 / divisor - spell_damage - stench_spell_damage * 2.0 - 45.0));
                
                int per_round_damage = floor(floor((45.0 + floor(0.4 * buffed_myst) + spell_damage + stench_spell_damage * 2.0) * spell_damage_multiplier) * 50.0 * monster_damage_multiplier);
                
                
                int casts_needed = 4;
                if (per_round_damage != 0)
                    casts_needed = clampi(ceil(20000.0 / to_float(per_round_damage)), 1, 4);
                
                if (my_buffedstat($stat[mysticality]) < min_myst_needed)
                {
                    tasks.listAppend(HTMLGenerateSpanFont("buff up to " + min_myst_needed + " mysticality", "red"));
                    if (monster_level > 0)
                        tasks.listAppend("possibly reduce ML");
                }
                tasks.listAppend("cast garbage nova " + pluraliseWordy(casts_needed, "time", "times"));
                
                if (tasks.count() > 0)
                    subentry.entries.listAppend(tasks.listJoinComponents(", ", "then").capitaliseFirstLetter() + ".");
                
                subentry.entries.listAppend(per_round_damage + " damage/round.");
            }
            else if ($skill[saucegeyser].skill_is_usable())
            {
                boolean need_modifier_output = true;
                if (my_familiar() != $familiar[magic dragonfish] && $familiar[magic dragonfish].familiar_is_usable() && !__misc_state["familiars temporarily blocked"])
                    subentry.entries.listAppend("Potentially switch to the magic dragonfish.");
                    
                //Calculate saucegeyser damage:
                float expected_saucegeyser_damage = skillExpectedDamageRangeAlternate($monster[wall of bones], $skill[saucegeyser]).x;
                
                subentry.entries.listAppend("Expected saucegeyser minimum damage: " + expected_saucegeyser_damage.roundForOutput(0));
                if (expected_saucegeyser_damage >= 5000.0)
                {
                    subentry.entries.listAppend("Cast saucegeyser four times.");
                    need_modifier_output = false;
                }
                else
                {
                    float hp_remaining = 20000.0 - expected_saucegeyser_damage * 3.0;
                    
                    float [skill] airport_skill_per_turn_damage_multiplier;
                    float [skill] airport_skill_base_damage;
                    
                    airport_skill_per_turn_damage_multiplier[$skill[grease up]] = 5.0;
                    airport_skill_base_damage[$skill[grease up]] = 30.0;
                    
                    airport_skill_per_turn_damage_multiplier[$skill[Intimidating Mien]] = 2.0;
                    airport_skill_base_damage[$skill[Intimidating Mien]] = 15.0;
                    
                    string [skill] airport_skill_name_of_combat_skill;
                    
                    airport_skill_name_of_combat_skill[$skill[grease up]] = "Unleash the Greash";
                    airport_skill_name_of_combat_skill[$skill[Intimidating Mien]] = "Thousand-Yard Stare";
                    
                    
                    float ml_damage_multiplier = MLDamageMultiplier();
                    if (ml_damage_multiplier != 1.0)
                    {
                        //FIXME this is correct... right? hmm...
                        foreach s in airport_skill_base_damage
                        {
                            airport_skill_base_damage[s] *= ml_damage_multiplier;
                            airport_skill_per_turn_damage_multiplier[s] *= ml_damage_multiplier;
                        }
                    }
                    
                    skill chosen_skill = $skill[none];
                    int chosen_skill_total_mp_cost = 0;
                    int chosen_skill_turns_left_to_cast = 0;
                    foreach s in airport_skill_base_damage
                    {
                        if (!s.skill_is_usable())
                            continue;
                        float base_damage = airport_skill_base_damage[s];
                        float variable_damage = airport_skill_per_turn_damage_multiplier[s];
                        effect skill_effect = s.to_effect();
                        
                        if (variable_damage == 0.0)
                            continue;
                        int total_turns_needed_of_effect = ceil((hp_remaining - base_damage) / variable_damage);
                        int turns_to_cast = MAX(0, total_turns_needed_of_effect - skill_effect.have_effect());
                        
                        int mp_cost = MAX(0, s.mp_cost() * turns_to_cast / MAX(1.0, s.turns_per_cast().to_float()));
                        
                        if (chosen_skill == $skill[none] || chosen_skill_total_mp_cost > mp_cost)
                        {
                            chosen_skill = s;
                            chosen_skill_total_mp_cost = mp_cost;
                            chosen_skill_turns_left_to_cast = turns_to_cast;
                        }
                    }
                    if (chosen_skill != $skill[none])
                    {
                        if (chosen_skill_turns_left_to_cast > 0)
                        {
                            string expected_meat_cost = ceil(chosen_skill_total_mp_cost * __misc_state_float["meat per MP"]);
                            
                            //string line = "Acquire " + chosen_skill_turns_left_to_cast + " more turns of " + chosen_skill + ".|Expected meat cost: ";
                            string line = "Cast " + chosen_skill + " ";
                            int cast_amount = ceil(chosen_skill_turns_left_to_cast.to_float() / MAX(1.0, chosen_skill.turns_per_cast().to_float()));
                            
                            if (cast_amount == 1)
                                line += "One More Time.";
                            else
                                line += cast_amount + " more times.";
                            
                            line += "|Expected meat cost: ";
                            
                            if (expected_meat_cost > my_meat())
                                line += HTMLGenerateSpanFont(expected_meat_cost, "red");
                            else
                                line += expected_meat_cost;
                            subentry.modifiers.listAppend("-mana cost");
                            subentry.entries.listAppend(line);
                        }
                        else
                        {
                            subentry.entries.listAppend("Cast saucegeyser three times, then cast " + airport_skill_name_of_combat_skill[chosen_skill] + ".");
                            need_modifier_output = false;
                        }
                    }
                    else if ($item[hand turkey outline].is_unrestricted()) //FIXME test if we have an airport skill
                    {
                        subentry.entries.listAppend("Cast saucegeyser three times, then an airport skill?");
                    }
                }
                if (my_hp() < my_maxhp())
                {
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
                }
                if (my_mp() < $skill[saucegeyser].mp_cost() * 4.0)
                    subentry.entries.listAppend(HTMLGenerateSpanFont("Restore some MP first.", "red"));
                if (need_modifier_output)
                {
                    subentry.modifiers.listAppend("mysticality");
                    subentry.modifiers.listAppend("spell damage");
                    subentry.modifiers.listAppend("spell damage percent");
                    if (monster_level_adjustment() > 0)
                        subentry.modifiers.listAppend("-ML");
                }
            }
        }
    }
    else if (!base_quest_state.state_boolean["past tower level 4"])
    {
        //stare into the looking glass, or break it
        subentry.header = "Face the looking glass";
        subentry.entries.listAppend("Two options here.");
        subentry.entries.listAppend("Gazing upon the looking glass will cost a turn, but makes the naughty sorceress much easier.");
        subentry.entries.listAppend("Breaking the mirror will save a turn, but makes the NS fight much more difficult.");
    }
    else if (!base_quest_state.state_boolean["past tower level 5"])
    {
		//at top of tower (fight shadow??)
		//8 -> fight shadow
        int total_initiative_needed = $monster[Your Shadow].monster_initiative();
		subentry.modifiers.listAppend("+HP");
		subentry.modifiers.listAppend("+" + total_initiative_needed + "% init");
		subentry.header = "Fight your shadow";
        foreach it in $items[attorney's badge, navel ring of navel gazing]
        {
            if (it.available_amount() > 0 && it.equipped_amount() == 0)
                subentry.entries.listAppend("Possibly equip your " + it + ". (blocks shadow)");
        }
        
        string [int] healing_items_available;
        foreach it in $items[filthy poultice,gauze garter,red pixel potion,Dreadsylvanian seed pod,soggy used band-aid,Mer-kin healscroll,scented massage oil,extra-strength red potion,red potion]
        {
            if (it.item_amount() == 0)
                continue;
            if (!it.item_is_usable()) continue;
            if (it.item_amount() == 1)
                healing_items_available.listAppend(it.to_string());
            else
                healing_items_available.listAppend(it.pluralise());
        }
        if (healing_items_available.count() > 0)
            subentry.entries.listAppend("Healing items available: " + healing_items_available.listJoinComponents(", ", "and") + ".");
        else
            subentry.entries.listAppend("May want to go find some healing items.");
            
            
        int initiative_needed = total_initiative_needed - initiative_modifier();
        if (initiative_needed > 0 && !$skill[Ambidextrous Funkslinging].skill_is_usable())
            subentry.entries.listAppend("Need " + initiative_needed + "% more initiative.");
        if (my_hp() < my_maxhp())
        {
            //FIXME only output this if we won't make it.
            subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
        }
	}
    else if (!base_quest_state.state_boolean["king waiting to be freed"])
	{
		//At NS. Good luck, we're all counting on you.
        if (my_path_id() != PATH_HEAVY_RAINS)
        {
            subentry.modifiers.listAppend("+moxie, DA equipment");
            subentry.modifiers.listAppend("no buffs");
            if (!__misc_state["familiars temporarily blocked"])
                subentry.modifiers.listAppend("attack familiar");
        }
		image_name = "naughty sorceress";
		subentry.header = "She awaits";
        if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
        {
            subentry.header = "You await";
            image_name = "Disco Bandit";
        }
        if (my_path_id() == PATH_LICENSE_TO_ADVENTURE)
        {
            subentry.header = "\"Blofeld\" awaits";
            image_name = "__monster \"Blofeld\"";
        }
        //don't think blocking works anymore? not sure
        /*if (!__misc_state["familiars temporarily blocked"] && my_path_id() != PATH_HEAVY_RAINS)
        {
            string potato_suggestion = generatePotatoSuggestion();
            
            subentry.entries.listAppend(potato_suggestion);
        }*/
        
        if ($item[The Lot's engagement ring].equipped_amount() > 0)
        {
            subentry.entries.listAppend("You and her? Good luck!");
        }
        
        /*if ($item[The Lot's engagement ring].available_amount() > 0 && $item[The Lot's engagement ring].equipped_amount() == 0)
        {
            subentry.entries.listAppend("Potentially equip the lot's engagement ring for an alternate ending.|<small>(sigh... if only)<small>");
        }*/
        
        if (my_path_id() == PATH_HEAVY_RAINS)
        {
            subentry.modifiers.listAppend("many buffs");
            if ($familiar[warbear drone].have_familiar())
                subentry.entries.listAppend("Run a warbear drone if you can.");
                
            subentry.entries.listAppend("Try to run as many buffs as you can. (one removed per round, have " + my_effects().count() + ")");
            subentry.entries.listAppend("Try to have as many damage sources as possible. (40? damage cap per source)");
            subentry.entries.listAppend("Only your weapon, offhand, and familiar equipment(?) are relevant this fight.");
            if ($item[crayon shavings].available_amount() > 0)
                subentry.entries.listAppend("Try repeatedly using crayon shavings?");
            if ($skill[frigidalmatian].skill_is_usable() && my_maxmp() >= 300 && $effect[Frigidalmatian].have_effect() == 0)
                subentry.entries.listAppend("Try casting Frigidalmatian.");
        }
        if (my_hp() < my_maxhp() && !get_property("lastEncounter").contains_text("The Naughty Sorceress") && __last_adventure_location != $location[The Naughty Sorceress' Chamber] && my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Restore your HP first.", "red"));
        }
        
	}
	else if (base_quest_state.state_boolean["king waiting to be freed"])
	{
		//King is waiting in his prism.
        
        boolean trophies_are_possible = false;
        
        //ehh, disable displaying this, mostly because it's in the way
        //if (in_hardcore())
            //trophies_are_possible = true; //Gourdcore, Golden Meat Stack
        
        if (trophies_are_possible)
            task_entries.listAppend(ChecklistEntryMake("__item puzzling trophy", "trophy.php", ChecklistSubentryMake("Check for trophies", "10k meat, trophy requirements", "Certain trophies are missable after freeing the king")));
		should_output_main_entry = false;
        
        
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        {
            if (availableDrunkenness() > 0)
            {
                task_entries.listAppend(ChecklistEntryMake("__item gibson", "inventory.php?which=1", ChecklistSubentryMake("Drink " + availableDrunkenness() + " drunkenness", "", "Freeing the king reduces your liver capacity.")));
            }
        }
        
        if (my_path_id() == PATH_HEAVY_RAINS)
        {
            if ($skill[rain dance].skill_is_usable() && my_rain() >= 10)
            {
                int times = floor(my_rain().to_float() / 10.0);
                task_entries.listAppend(ChecklistEntryMake("__effect Rain Dancin'", "skills.php", ChecklistSubentryMake("Cast Rain Dance " + pluraliseWordy(times, "time", "times"), "", "+20% item buff for aftercore.")));
            }
        }
        
        if ($item[Yearbook Club Camera].available_amount() > 0 && $item[Yearbook Club Camera].equipped_amount() == 0)
        {
            task_entries.listAppend(ChecklistEntryMake("__item yearbook club camera", "inventory.php?which=2", ChecklistSubentryMake("Equip the yearbook club camera", "", "Before prism break. Otherwise, it'll disappear.")));
        }
		
	}
    //I need to delete this code, but I love it so much. Look at all that towerkilling suggestions! sob
	/*else if (base_quest_state.mafia_internal_step > 4 && base_quest_state.mafia_internal_step < 11)
	{
        //step4 through step9 - 5 - 10
		//at tower, time to kill monsters!
        
        
        int level = -1;
        
        if (base_quest_state.mafia_internal_step == 5)
            level = 1;
        else if (base_quest_state.mafia_internal_step == 6)
            level = 2;
        else if (base_quest_state.mafia_internal_step == 7)
            level = 3;
        else if (base_quest_state.mafia_internal_step == 8)
            level = 4;
        else if (base_quest_state.mafia_internal_step == 9)
            level = 5;
        else if (base_quest_state.mafia_internal_step == 10)
            level = 6;
        
        boolean output_tower_killing_ideas = false;
        item monster_item = __misc_state_string["Tower monster item " + level].to_item();
        
        subentry.entries.listAppend("Tower monster on floor " + level + ".");
        if (monster_item != $item[none])
        {
            if (monster_item.available_amount() > 0)
                subentry.entries.listAppend("Use " + HTMLGenerateSpanOfClass(monster_item, "r_bold") + ".");
            else
            {
                subentry.entries.listAppend(HTMLGenerateSpanFont("Need " + HTMLGenerateSpanOfClass(monster_item, "r_bold") + ".", "red"));
                output_tower_killing_ideas = true;
            }
        }
        else
        {
            subentry.entries.listAppend(HTMLGenerateSpanFont("Need unknown item.", "red"));
            output_tower_killing_ideas = true;
        }
        
        if (output_tower_killing_ideas)
        {
            string [int] tower_killing_ideas;
            
            if (my_path_id() == PATH_HEAVY_RAINS && $skill[thunder bird].skill_is_usable() && my_thunder() >= 5 && $skill[curse of weaksauce].skill_is_usable())
            {
                string [int] line;
                if ($skill[itchy curse finger].skill_is_usable())
                {
                    line.listAppend("cast curse of weaksauce");
                    line.listAppend("cast a stun");
                }
                else
                {
                    line.listAppend("cast a stun");
                    line.listAppend("cast curse of weaksauce");
                }
                line.listAppend("cast thunder bird/stun/staggers repeatedly under defense is below zero");
                line.listAppend("attack");
                tower_killing_ideas.listAppend(line.listJoinComponents(", ", "then").capitaliseFirstLetter());
            }
            else if ($skill[curse of weaksauce].skill_is_usable() && $item[crayon shavings].available_amount() >= 2) //currently disabled because while it'll work in theory, I haven't tested it
            {
                string [int] line;
                if ($skill[itchy curse finger].skill_is_usable())
                {
                    line.listAppend("cast curse of weaksauce");
                    line.listAppend("cast a stun");
                }
                else
                {
                    line.listAppend("cast a stun");
                    line.listAppend("cast curse of weaksauce");
                }
                line.listAppend("throw two crayon shavings");
                line.listAppend("stagger/stun until defense is below zero");
                
                line.listAppend("attack");
                tower_killing_ideas.listAppend(line.listJoinComponents(", ", "then").capitaliseFirstLetter());
            }
            
            //Familiar sources:
            if (!__misc_state["familiars temporarily blocked"])
            {
                string potato_suggestion = generatePotatoSuggestion();
                tower_killing_ideas.listAppend(potato_suggestion);
                
                
                //Bjorn:
                if ($familiar[mariachi chihuahua].have_familiar())
                {
                    if ($item[buddy bjorn].available_amount() > 0)
                    {
                        if (my_bjorned_familiar() != $familiar[mariachi chihuahua])
                            tower_killing_ideas.listAppend("Put your mariachi chihuahua in your buddy bjorn. (50% stagger)");
                    }
                    else if ($item[crown of thrones].available_amount() > 0)
                    {
                        if (my_enthroned_familiar() != $familiar[mariachi chihuahua])
                            tower_killing_ideas.listAppend("Put your mariachi chihuahua in your crown of thrones. (50% stagger)");
                    }
                }
            }
            
            if ($item[attorney's badge].available_amount() > 0 && $item[attorney's badge].equipped_amount() == 0)
                tower_killing_ideas.listAppend("Could equip attorney's badge for more blocking.");
            if ($item[navel ring of navel gazing].available_amount() > 0 && $item[navel ring of navel gazing].equipped_amount() == 0)
                tower_killing_ideas.listAppend("Could equip navel ring of navel gazing for more blocking.");
                
                
            
            string [int] stun_sources;
            string [int] stagger_sources;
            
            
            //Stun/stagger sources:
            //(this is not a comprehensive list)
            //√shadow noodles, √thunderstrike, √soul bubble
            //√potato, √bjorned chihuahua, √attorney's badge, √navel ring
            
            //√ply reality, √entangling noodles as not-pastamancer, √pantsgiving 2x, √deft hands, DNA...?, √3x disco dances...
            //√airblaster gun
            //√club foot IF seal clubber
            //√Break It On Down
            //√gob of wet hair, √gyroscope, √macrame net, √ornate picture frame, √palm-frond net(?), √Rain-Doh indigo cup, √superamplified boom box, √Throw Shield (OPS), √tongue depressor
            
            //√gas balloon, √brick of sand(?), √chloroform rag, naughty paper shuriken, √sausage bomb, √floorboard cruft
            //√dumb mud will insta if available
            //√finger cuffs (support acquiring)
            //√Rain-Doh blue balls
            //√CSA obedience grenade, √The Lost Comb
            //Accordion Bash if AT wearing an accordion FIXME do that
            //Shell Up(?)
            //sooooooul finger? does it work? 40 saucery...
            
            if ($item[Game Grid ticket].item_amount() > 0 && $item[Game Grid ticket].is_unrestricted())
                tower_killing_ideas.listAppend("Could acquire " + $item[Game Grid ticket].item_amount() + " finger cuffs. (stun)");
            if ($skill[shadow noodles].skill_is_usable())
                stun_sources.listAppend("shadow noodles");
            if ($skill[thunderstrike].skill_is_usable())
                stun_sources.listAppend("thunderstrike");
            if ($skill[soul saucery].skill_is_usable() && my_class() == $class[sauceror])
                stun_sources.listAppend("soul bubble");
                
            foreach it in $items[gas balloon,brick of sand,chloroform rag,sausage bomb,floorboard cruft,finger cuffs,CSA obedience grenade,The Lost Comb]
            {
                if (it.item_amount() == 0 || !it.is_unrestricted())
                    continue;
                stun_sources.listAppend(it.pluraliseWordy());
            }
            if ($item[naughty paper shuriken].available_amount() > 0)
                stun_sources.listAppend("naughty paper shuriken");
            if ($item[Rain-Doh blue balls].available_amount() > 0)
                stun_sources.listAppend("Rain-Doh blue balls");
                
            if ($skill[shell up].skill_is_usable() && ($effect[Blessing of the Storm Tortoise].have_effect() > 0 || $effect[Grand Blessing of the Storm Tortoise].have_effect() > 0 || $effect[Glorious Blessing of the Storm Tortoise].have_effect() > 0))
                stun_sources.listAppend("Shell Up");
            if ($skill[Accordion Bash].skill_is_usable())
            {
                string line = "Accordion Bash";
                if ($slot[weapon].equipped_item().item_type() != "accordion")
                    line = HTMLGenerateSpanFont(line + " (equip accordion)", "gray");
                stun_sources.listAppend(line);
            }
            
            if ($item[thor's pliers].equipped_amount() > 0)
                stagger_sources.listAppend("ply reality");
            if (my_class() != $class[pastamancer] && $skill[entangling noodles].skill_is_usable())
                stagger_sources.listAppend("entangling noodles");
            if ($item[pantsgiving].equipped_amount() > 0)
            {
                stagger_sources.listAppend("pocket crumbs");
                stagger_sources.listAppend("air dirty laundry");
            }
            if (my_class() == $class[disco bandit] && $skill[deft hands].skill_is_usable())
                stagger_sources.listAppend("first combat item thrown");
            if (my_class() == $class[disco bandit] && $skill[Disco State of Mind].skill_is_usable() && $skill[Flashy Dancer].skill_is_usable())
            {
                if ($skill[disco dance of doom].skill_is_usable())
                    stagger_sources.listAppend("disco dance");
                if ($skill[Disco Dance II: Electric Boogaloo].skill_is_usable())
                    stagger_sources.listAppend("disco dance II");
                if ($skill[Disco Dance 3: Back in the Habit].skill_is_usable())
                    stagger_sources.listAppend("disco dance 3");
            }
            if ($item[airblaster gun].equipped_amount() > 0)
                stagger_sources.listAppend("air blast");
            if (my_class() == $class[seal clubber] && $skill[club foot].skill_is_usable())
            {
                int stun_rounds = 0;
                
                stun_rounds = MIN(3, my_fury());
                if ($slot[weapon].equipped_item().item_type() == "club")
                    stun_rounds += 1;
                
                if (stun_rounds == 1)
                    stagger_sources.listAppend("club foot");
                else if (stun_rounds > 1)
                    stun_sources.listAppend("club foot");
            }
            if ($skill[Break It On Down].skill_is_usable())
                stagger_sources.listAppend("break it on down");
            
            foreach it in $items[gob of wet hair,gyroscope,macrame net,ornate picture frame,palm-frond net,superamplified boom box]
            {
                if (it.item_amount() == 0 || !it.is_unrestricted())
                    continue;
                stagger_sources.listAppend(it.pluraliseWordy());
            }
            if ($item[operation patriot shield].equipped_amount() > 0)
                stagger_sources.listAppend("throw shield");
            if ($item[Rain-Doh indigo cup].available_amount() > 0)
                stagger_sources.listAppend("Rain-Doh indigo cup");
            if ($item[tongue depressor].available_amount() > 0)
                stagger_sources.listAppend("tongue depressor");
                
            if (stun_sources.count() > 0)
                tower_killing_ideas.listAppend("Stuns: " + stun_sources.listJoinComponents(", ", "and"));
            if (stagger_sources.count() > 0)
                tower_killing_ideas.listAppend("Stagger sources: " + stagger_sources.listJoinComponents(", ", "and"));
            
            
            
            
            if ($item[small golem].available_amount() > 0)
            {
                if ($skill[Ambidextrous Funkslinging].skill_is_usable() && $item[slime stack].available_amount() > 0)
                    tower_killing_ideas.listAppend("Small golem available. Funksling early in combat with a slime stack for 3k damage/round.");
                else
                    tower_killing_ideas.listAppend("Small golem available. Use early in combat for 3k damage/round.");
            }
            if ($item[slime stack].available_amount() > 0)
                tower_killing_ideas.listAppend($item[slime stack].pluralise() + " available. (15% damage)");
                
            if ($skill[frigidalmatian].skill_is_usable() && my_maxmp() >= 300 && $effect[Frigidalmatian].have_effect() == 0)
                tower_killing_ideas.listAppend("Possibly cast Frigidalmatian.");
                
            if (monster_level_adjustment() > 0)
                tower_killing_ideas.listAppend(HTMLGenerateSpanFont("Try to reduce your ML", "red") + ", as it reduces damage done to them.");
                
            if ((my_path_id() == PATH_HEAVY_RAINS || $item[water wings for babies].available_amount() >= 3) && $item[water wings for babies].equipped_amount() <3)
                tower_killing_ideas.listAppend("Equip three water wings for babies to reduce ML. (increased damage)");
            
            if (tower_killing_ideas.count() > 0)
                subentry.entries.listAppend("Or towerkill (very difficult):" + HTMLGenerateIndentedText(tower_killing_ideas.listJoinComponents("<hr>")));
            else
                subentry.entries.listAppend("Or towerkill.");
                
            if ($item[dumb mud].available_amount() > 0)
                subentry.entries.listAppend("Or just use dumb mud, which will insta-kill a tower monster.");
        }
            
        if (level <= 3)
            url = "lair4.php";
        else
            url = "lair5.php";
	}*/

	if (should_output_main_entry)
		task_entries.listAppend(ChecklistEntryMake(image_name, url, subentries));
}
