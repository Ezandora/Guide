import "relay/Guide/QuestState.ash"
import "relay/Guide/Quests.ash"
import "relay/Guide/Sets.ash"
import "relay/Guide/Pulls.ash"
import "relay/Guide/Plants.ash"

void setUpExampleState()
{
	__misc_state["in run"] = true;
    
	//Do a default reset of each quest:
	
	foreach quest_name in __quest_state
	{
		QuestState state = __quest_state[quest_name];
		
		
		QuestStateParseMafiaQuestPropertyValue(state, "started");
		
		
		__quest_state[quest_name] = state;
	}
	
	__misc_state_int["pulls available"] = 17;
}


//We call this twice - once at the start, once after __quest_state["Level 13"] becomes available. I would just call it once but that could break things? (very old code)
void computeFatLootTokens()
{
    int dd_tokens_and_keys_available = 0;
    int tokens_needed = 0;
    int keys_missing = 0;
    boolean need_boris_key = true;
    boolean need_jarlsberg_key = true;
    boolean need_sneaky_pete_key = true;
    
    if ($item[boris's key].available_amount() > 0)
        need_boris_key = false;
    if ($item[jarlsberg's key].available_amount() > 0)
        need_jarlsberg_key = false;
    if ($item[sneaky pete's key].available_amount() > 0)
        need_sneaky_pete_key = false;
        
    if (__quest_state["Level 13"].state_boolean["Sneaky Pete's key used"])
        need_sneaky_pete_key = false;
    if (__quest_state["Level 13"].state_boolean["Boris's key used"])
        need_boris_key = false;
    if (__quest_state["Level 13"].state_boolean["Jarlsberg's key used"])
        need_jarlsberg_key = false;
        
    if (need_boris_key)
        tokens_needed += 1;
    if (need_jarlsberg_key)
        tokens_needed += 1;
    if (need_sneaky_pete_key)
        tokens_needed += 1;
    
    keys_missing = tokens_needed;
    tokens_needed -= $item[fat loot token].available_amount();
    tokens_needed = MAX(0, tokens_needed);
    
    dd_tokens_and_keys_available += $item[fat loot token].available_amount();
    dd_tokens_and_keys_available += $item[boris's key].available_amount();
    dd_tokens_and_keys_available += $item[jarlsberg's key].available_amount();
    dd_tokens_and_keys_available += $item[sneaky pete's key].available_amount();

    __misc_state_int["fat loot tokens needed"] = MAX(0, tokens_needed);
    __misc_state_int["hero keys missing"] = keys_missing;
    
    __misc_state_int["DD Tokens and keys available"] = dd_tokens_and_keys_available;
}


void setUpState()
{
    __misc_state.listClear();
	__last_adventure_location = get_property_location("lastAdventure");
    if (__misc_state["Example mode"])
    {
        int wanted_index = random_safe($locations[].count());
        int i = 0;
        foreach l in $locations[]
        {
            if (i == wanted_index)
            {
                __last_adventure_location = l;
                break;
            }
            i += 1;
        }
    }	
	if (__setting_debug_mode && __setting_debug_enable_example_mode_in_aftercore && get_property_boolean("kingLiberated"))
	{
		__misc_state["Example mode"] = true;
	}
    
	__misc_state["in aftercore"] = get_property_boolean("kingLiberated");
    //if (get_property_ascension("lastKingLiberation") && my_ascensions() != 0)
        //__misc_state["in aftercore"] = true;
	__misc_state["in run"] = !__misc_state["in aftercore"];
    if (__misc_state["Example mode"])
        __misc_state["in run"] = true;
    __misc_state["In valhalla"] = (my_class().to_string() == "Astral Spirit");
    
    
	if (my_turncount() >= 30 && get_property_int("singleFamiliarRun") != -1)
		__misc_state["single familiar run"] = true;
	if ($item[Clan VIP Lounge key].available_amount() > 0 && !in_bad_moon())
		__misc_state["VIP available"] = true;
	boolean fax_available = false;
	if (__misc_state["VIP available"])
	{
		if (!get_property_boolean("_photocopyUsed"))
			fax_available = true;
		__misc_state["fax accessible"] = true;
	}
	
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_TRENDY)
	{
		__misc_state["fax accessible"] = false;
	}
    if (!$item[deluxe fax machine].is_unrestricted())
        __misc_state["fax accessible"] = false;
    
    if (!__misc_state["fax accessible"])
		fax_available = false;
	__misc_state["fax available"] = fax_available;
    
    __misc_state["fax equivalent accessible"] = __misc_state["fax available"];
    if (my_path_id() == PATH_HEAVY_RAINS && $skill[rain man].skill_is_usable())
        __misc_state["fax equivalent accessible"] = true;
	
    if (__misc_state["VIP available"])
    {
        int soaks_remaining = MAX(0, 5 - get_property_int("_hotTubSoaks"));
        __misc_state_int["hot tub soaks remaining"] = soaks_remaining;
    }
	
	__misc_state["can eat just about anything"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_ZOMBIE_SLAYER || fullness_limit() == 0 || my_path_id() == PATH_VAMPIRE)
	{
		__misc_state["can eat just about anything"] = false;
	}
	
	__misc_state["can drink just about anything"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_KOLHS || my_path_id() == PATH_LICENSE_TO_ADVENTURE || inebriety_limit() == 0 || my_path_id() == PATH_VAMPIRE)
	{
		__misc_state["can drink just about anything"] = false;
	}
	
	
	__misc_state["can equip just about any weapon"] = true;
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_WAY_OF_THE_SURPRISING_FIST)
	{
		__misc_state["can equip just about any weapon"] = false;
	}
	
	
	__misc_state["MMJs buyable"] = false;
	if (get_property_ascension("lastGuildStoreOpen"))
	{
		if (my_class() == $class[pastamancer] || my_class() == $class[sauceror] || (my_class() == $class[accordion thief] && my_level() >= 9))
            __misc_state["MMJs buyable"] = true;
	}
	
	//Check for moxie/mysticality/muscle combat skills:
	
	foreach s in $skills[]
	{
		if (!s.combat)
			continue;
		if (!s.skill_is_usable())
			continue;
		if (s.class == $class[accordion thief] || s.class == $class[disco bandit])
			__misc_state["have moxie class combat skill"] = true;
		if (s.class == $class[pastamancer] || s.class == $class[sauceror])
			__misc_state["have mysticality class combat skill"] = true;
		if (s.class == $class[seal clubber] || s.class == $class[turtle tamer])
			__misc_state["have muscle class combat skill"] = true;
	}
	
	
	
	boolean yellow_ray_available = false;
	string yellow_ray_source = "";
	string yellow_ray_image_name = "__effect everything looks yellow";
	boolean yellow_ray_potentially_available = false;
    
    foreach source in $items[4766,5229,6673,7013]
    {
        if (!(source.available_amount() > 0 || (source == $item[4766] && $item[4761].available_amount() > 0)))
            continue;
		yellow_ray_available = true;
		yellow_ray_source = source.to_string();
		yellow_ray_image_name = "__item " + source.to_string();
    }
    if ($item[viral video].available_amount() > 0)
    {
		yellow_ray_available = true;
		yellow_ray_source = "viral video";
		yellow_ray_image_name = "__item viral video";
    }
    
    if ($item[mayo lance].available_amount() > 0 && get_property_int("mayoLevel") > 0)
    {
        yellow_ray_available = true;
        yellow_ray_source = "Mayo Lance";
        yellow_ray_image_name = "__item mayo lance";
    }
    if ($skill[Unleash Cowrruption].have_skill())
    {
        yellow_ray_available = true;
        yellow_ray_source = "Unleash Cowrruption";
        yellow_ray_image_name = "__skill Unleash Cowrruption";
    }
    if ($familiar[Crimbo Shrub].familiar_is_usable() && get_property("shrubGifts") == "yellow" && !(my_daycount() == 1 && get_property("_shrubDecorated") == "false"))
    {
        yellow_ray_available = true;
        yellow_ray_source = "Crimbo Shrub";
        yellow_ray_image_name = "__item DNOTC Box"; //uncertain
    }
	if (familiar_is_usable($familiar[nanorhino]) && __misc_state["have moxie class combat skill"] && get_property_int("_nanorhinoCharge") == 100)
	{
		yellow_ray_available = true;
		yellow_ray_source = "Nanorhino";
		yellow_ray_image_name = "nanorhino";
		
	}
    if ($skill[Ball Lightning].skill_is_usable() && my_path_id() == PATH_HEAVY_RAINS && my_lightning() >= 5)
    {
        yellow_ray_available = true;
        yellow_ray_source = "Ball Lightning";
        yellow_ray_image_name = "__skill Ball Lightning";
    }
    if ($skill[wrath of ra].skill_is_usable() && my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
    {
        yellow_ray_available = true;
        yellow_ray_source = "Wrath of Ra";
        yellow_ray_image_name = "__skill wrath of ra";
    }
	if (familiar_is_usable($familiar[he-boulder]))
	{
		yellow_ray_available = true;
		yellow_ray_source = "He-Boulder";
		yellow_ray_image_name = "he-boulder";
	}
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && $skill[Flash Headlight].skill_is_usable() && get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb")
    {
		yellow_ray_available = true;
		yellow_ray_source = "Flash Headlight";
		yellow_ray_image_name = "__skill Easy Riding";
    }
    if (lookupSkill("disintegrate").have_skill() && my_maxmp() >= 150)
    {
		yellow_ray_available = true;
		yellow_ray_source = "Disintegrate";
		yellow_ray_image_name = "__skill Disintegrate";
    }
	
	if (yellow_ray_available)
		yellow_ray_potentially_available = true;
	
	if (my_path_id() == PATH_KOLHS)
		yellow_ray_potentially_available = true;
		
	
	if ($effect[Everything looks yellow].have_effect() > 0)
		yellow_ray_available = false;
	if (!yellow_ray_available)
		yellow_ray_source = "";
	__misc_state["yellow ray available"] = yellow_ray_available;
	__misc_state_string["yellow ray source"] = yellow_ray_source;
	__misc_state_string["yellow ray image name"] = yellow_ray_image_name;
	__misc_state["yellow ray potentially available"] = yellow_ray_potentially_available;
    
    
    if (in_bad_moon() && !__misc_state["yellow ray potentially available"] && !__misc_state["yellow ray available"])
    {
        __misc_state["yellow ray almost certainly impossible"] = true;
    }
    
    int [item] campground_items = get_campground();
    __misc_state["can cook for free"] = false;
    if (campground_items[$item[chef-in-the-box]] > 0 || campground_items[$item[clockwork chef-in-the-box]] > 0 || $effect[Inigo's Incantation of Inspiration].have_effect() >= 5)
        __misc_state["can cook for free"] = true;
    
    
    __misc_state["can bartend for free"] = false;
    if (campground_items[$item[bartender-in-the-box]] > 0 || campground_items[$item[clockwork bartender-in-the-box]] > 0 || $effect[Inigo's Incantation of Inspiration].have_effect() >= 5)
        __misc_state["can bartend for free"] = true;
    
    if ($skill[Rapid Prototyping].skill_is_usable() && get_property_int("_rapidPrototypingUsed") < 5)
    {
        __misc_state["can cook for free"] = true;
        __misc_state["can bartend for free"] = true;
    }
    if (lookupSkill("Expert Corner-Cutter").skill_is_usable() && get_property_int("_expertCornerCutterUsed") < 5)
    {
        __misc_state["can cook for free"] = true;
        __misc_state["can bartend for free"] = true;
    }
	
	boolean free_runs_usable = true;
	if (my_path_id() == PATH_BIG || my_path_id() == PATH_POCKET_FAMILIARS) //more like "combat items not usable" but
		free_runs_usable = false;
	__misc_state["free runs usable"] = free_runs_usable;
	
	boolean blank_outs_usable = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG)
		blank_outs_usable = false;
	if (!free_runs_usable)
		blank_outs_usable = false;
	__misc_state["blank outs usable"] = free_runs_usable;
	
	
	boolean free_runs_available = false;
	if (familiar_is_usable($familiar[pair of stomping boots]) || ($skill[the ode to booze].skill_is_usable() && familiar_is_usable($familiar[Frumious Bandersnatch])))
		free_runs_available = true;
	if ($item[goto].available_amount() > 0 || $item[tattered scrap of paper].available_amount() > 0)
		free_runs_available = true;
	if ($item[greatest american pants].available_amount() > 0 || $item[navel ring of navel gazing].available_amount() > 0 || $item[peppermint parasol].available_amount() > 0)
		free_runs_available = true;
	if ($item[divine champagne popper].available_amount() > 0 || 2371.to_item().available_amount() > 0 || 7014.to_item().available_amount() > 0 || $item[handful of Smithereens].available_amount() > 0)
		free_runs_available = true;
	if ($item[V for Vivala mask].available_amount() > 0 && !get_property_boolean("_vmaskBanisherUsed"))
		free_runs_available = true;
	if (blank_outs_usable)
	{
		if ($item[bottle of Blank-Out].available_amount() > 0 || get_property_int("blankOutUsed") > 0)
			free_runs_available = true;
	}
    if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE && $skill[Peel Out].skill_is_usable())
    {
        
        int total_free_peel_outs_available = 10;
        if (get_property("peteMotorbikeTires") == "Racing Slicks")
            total_free_peel_outs_available += 20;
        int free_peel_outs_available = MAX(0, total_free_peel_outs_available - get_property_int("_petePeeledOut"));
        if (free_peel_outs_available > 0)
            free_runs_available = true;
    }
    if (my_path_id() == PATH_HEAVY_RAINS && $skill[Lightning Strike].skill_is_usable())
        free_runs_available = true;
	if (!free_runs_usable)
		free_runs_available = false;
	__misc_state["free runs available"] = free_runs_available;
	
	
	string olfacted_monster = "";
	boolean some_olfact_available = false;
    boolean some_reusable_olfact_available = false;
	if ($skill[Transcendent Olfaction].skill_is_usable())
    {
		some_olfact_available = true;
        some_reusable_olfact_available = true;
        if ($effect[on the trail].have_effect() > 0)
            olfacted_monster = get_property("olfactedMonster");
    }
    if ($item[odor extractor].available_amount() > 0)
    {
        some_olfact_available = true;
    }
    if ($familiar[nosy nose].familiar_is_usable()) //weakened, but still relevant
    {
        some_olfact_available = true;
    }
    if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
    {
        some_olfact_available = true;
        some_reusable_olfact_available = true;
    }
	__misc_state["have olfaction equivalent"] = some_olfact_available;
    __misc_state_string["olfaction equivalent monster"] = olfacted_monster;
	__misc_state["have reusable olfaction equivalent"] = some_reusable_olfact_available;
	
    if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING || my_path_id() == PATH_NUCLEAR_AUTUMN)
        __misc_state["campground unavailable"] = true;
	
	boolean skills_temporarily_missing = false;
	boolean familiars_temporarily_blocked = false;
	boolean familiars_temporarily_missing = false;
	if (in_bad_moon())
	{
		skills_temporarily_missing = true;
		familiars_temporarily_missing = true;
	}
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING || my_path_id() == PATH_VAMPIRE)
	{
		skills_temporarily_missing = true;
		familiars_temporarily_missing = true;
		familiars_temporarily_blocked = true;
	}
	if (my_path_id() == PATH_ZOMBIE_SLAYER)
	{
		skills_temporarily_missing = true;
	}
	if (my_path_id() == PATH_CLASS_ACT || my_path_id() == PATH_CLASS_ACT_2)
	{
		//not sure how mafia interprets "have_skill" under class act
		skills_temporarily_missing = true;
	}
	if (my_path_id() == PATH_TRENDY)
	{
		//not sure if this is correct
		//skills_temporarily_missing = true;
		//familiars_temporarily_missing = true;
	}
    if (my_path_id() == PATH_AVATAR_OF_WEST_OF_LOATHING || my_path_id() == PATH_NUCLEAR_AUTUMN || my_path_id() == PATH_GELATINOUS_NOOB || my_path_id() == PATH_G_LOVER)
    {
        skills_temporarily_missing = true;
    }
    if (my_path_id() == PATH_LICENSE_TO_ADVENTURE || my_path_id() == PATH_POCKET_FAMILIARS)
        familiars_temporarily_blocked = true;
	__misc_state["skills temporarily missing"] = skills_temporarily_missing;
	__misc_state["familiars temporarily missing"] = familiars_temporarily_missing;
	__misc_state["familiars temporarily blocked"] = familiars_temporarily_blocked;
	
	
	__misc_state["AT skills available"] = true;
	if (my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_ZOMBIE_SLAYER || ((my_path_id() == PATH_CLASS_ACT || my_path_id() == PATH_CLASS_ACT_2) && my_class() != $class[accordion thief]))
		__misc_state["AT skills available"] = false;
	
	
    __misc_state_float["Non-combat statgain multiplier"] = 1.0;
	__misc_state_float["ML to mainstat multiplier"] = 1.0 / (2.0 * 3.0);
	/*if (my_path_id() == PATH_CLASS_ACT_2)
	{
		__misc_state_float["ML to mainstat multiplier"] = 1.0 / (2.0 * 2.0);
	}*/
    if (false)
    {
        //this does not seem to be the case? FIXME spade please
        __misc_state_float["Non-combat statgain multiplier"] = 0.5;
        __misc_state["Stat gain from NCs reduced"] = false;
    }
	
	int pulls_available = 0;
	pulls_available = pulls_remaining();
    if (__setting_debug_mode && in_ronin())
        pulls_available = MAX(pulls_available, 4);
	__misc_state_int["pulls available"] = pulls_available;
	
    //Calculate free rests available:
    int rests_used = get_property_int("timesRested");
    int total_rests_available = total_free_rests();
    
    __misc_state_int["total free rests possible"] = total_rests_available;
	__misc_state_int["free rests remaining"] = MAX(total_rests_available - rests_used, 0);
    
	
	//monster.monster_initiative() is usually what you need, but just in case:
    __misc_state_float["init ML penalty"] = monsterExtraInitForML(monster_level_adjustment_ignoring_plants());

	
	
	int ngs_needed = 0;
	
    //stats:
    
	if (my_level() < 13 && !__misc_state["in aftercore"])
	{
		__misc_state["need to level"] = true;
	}
    __misc_state["need to level muscle"] = false;
    __misc_state["need to level mysticality"] = false;
    __misc_state["need to level moxie"] = false;
    
    if (__misc_state["in run"])
    {
        //62 muscle for antique machete/hidden hospital
        //70 moxie, 70 mysticality for war outfits
        if (my_primestat() == $stat[muscle] && __misc_state["need to level"])
            __misc_state["need to level muscle"] = true;
        if (my_primestat() == $stat[mysticality] && __misc_state["need to level"])
            __misc_state["need to level mysticality"] = true;
        if (my_primestat() == $stat[moxie] && __misc_state["need to level"])
            __misc_state["need to level moxie"] = true;
        
        if (my_basestat($stat[muscle]) < 62)
            __misc_state["need to level muscle"] = true;
        if (my_basestat($stat[mysticality]) < 70)
            __misc_state["need to level mysticality"] = true;
        if (my_basestat($stat[moxie]) < 70)
            __misc_state["need to level moxie"] = true;
    }
	
	//wand
	
	boolean wand_of_nagamar_needed = true;
	if (my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || my_path_id() == PATH_BUGBEAR_INVASION || my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_KOLHS || my_path_id() == PATH_HEAVY_RAINS || my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING || my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_THE_SOURCE || my_path_id() == PATH_LICENSE_TO_ADVENTURE || my_path_id() == PATH_POCKET_FAMILIARS || my_path_id() == PATH_VAMPIRE)
		wand_of_nagamar_needed = false;
		
	int ruby_w_needed = 1;
	int metallic_a_needed = 1;
	int lowercase_n_needed = 1;
	int heavy_d_needed = 1;
	int [string] letters_needed;
	letters_needed["w"] = 1;
	letters_needed["a"] = 1;
	letters_needed["n"] = 1;
	letters_needed["d"] = 1;
	letters_needed["g"] = 0;
	
	int [string] letters_available;
	letters_available["w"] = $item[ruby w].available_amount() + $item[wa].available_amount();
	letters_available["a"] = $item[metallic a].available_amount() + $item[wa].available_amount();
	letters_available["n"] = $item[lowercase n].available_amount() + $item[nd].available_amount() + $item[ng].available_amount();
	letters_available["d"] = $item[heavy d].available_amount() + $item[nd].available_amount();
	letters_needed["n"] += ngs_needed;
	letters_needed["g"] += ngs_needed;
	
	if ($item[wand of nagamar].available_amount() > 0)
		wand_of_nagamar_needed = false;
		
		
		
	if (!wand_of_nagamar_needed)
	{
		letters_needed["w"] -= 1;
		letters_needed["a"] -= 1;
		letters_needed["n"] -= 1;
		letters_needed["d"] -= 1;
	}
	
	letters_needed["w"] = MAX(0, letters_needed["w"] - letters_available["w"]);
	letters_needed["a"] = MAX(0, letters_needed["a"] - letters_available["a"]);
	letters_needed["n"] = MAX(0, letters_needed["n"] - letters_available["n"]);
	letters_needed["d"] = MAX(0, letters_needed["d"] - letters_available["d"]);
		
	__misc_state["wand of nagamar needed"] = wand_of_nagamar_needed;
	__misc_state_int["ruby w needed"] = letters_needed["w"];
	__misc_state_int["metallic a needed"] = letters_needed["a"];
	__misc_state_int["lowercase n needed"] = letters_needed["n"];
	__misc_state_int["lowercase n available"] = letters_available["n"];
	__misc_state_int["heavy d needed"] = letters_needed["d"];
	__misc_state_int["original g needed"] = letters_needed["g"];
	
	
    computeFatLootTokens();
	
	boolean mysterious_island_unlocked = false;
	if ($items[dingy dinghy, skeletal skiff].available_amount() > 0) //junk junk requires completing the quest first
		mysterious_island_unlocked = true;
    
    if (get_property("peteMotorbikeGasTank") == "Extra-Buoyant Tank")
        mysterious_island_unlocked = true;
    if (get_property_ascension("lastIslandUnlock"))
        mysterious_island_unlocked = true;
    if (my_path_id() == PATH_EXPLOSION)
    	mysterious_island_unlocked = true; //kinda
            
    
        
    __misc_state["mysterious island available"] = mysterious_island_unlocked;
    
    
	
	__misc_state["desert beach available"] = false;
    if (get_property("peteMotorbikeGasTank") == "Large Capacity Tank")
        __misc_state["desert beach available"] = true;
    if (get_property_ascension("lastDesertUnlock"))
        __misc_state["desert beach available"] = true;
	if ($location[south of the border].locationAvailable())
		__misc_state["desert beach available"] = true;
	if ($locations[The Shore\, Inc. Travel Agency,the arid\, extra-dry desert,the oasis, south of the border].turnsAttemptedInLocation() > 0) //weird issues with detecting the beach. check if we've ever adventured there as a back-up
		__misc_state["desert beach available"] = true;
    if (my_path_id() == PATH_EXPLOSION)
        __misc_state["desert beach available"] = true;
	
	string ballroom_song = "";
	if (get_property_ascension("lastQuartetAscension"))
	{
		//1 and 3 are a guess
		if (get_property("lastQuartetRequest") == "1")
		{
			ballroom_song = "+ML";
		}
		else if (get_property("lastQuartetRequest") == "2")
		{
			ballroom_song = "-combat";
		}
		else if (get_property("lastQuartetRequest") == "3")
		{
			ballroom_song = "+item";
		}
	}
	__misc_state_string["ballroom song"] = ballroom_song;
	
	__misc_state["Torso aware"] = false;
    if ($skill[Torso Awaregness].skill_is_usable() || $skill[Best Dressed].skill_is_usable())
        __misc_state["Torso aware"] = true;
	
	int hipster_fights_used = get_property_int("_hipsterAdv");
	if (hipster_fights_used < 0) hipster_fights_used = 0;
	if (hipster_fights_used > 7) hipster_fights_used = 7;
	
	if (familiar_is_usable($familiar[artistic goth kid])) //goth kid has crayon shavings, which help survivability, though it has that weirdness with early runaways (have to defeat a monster first)
	{
		__misc_state_string["hipster name"] = "goth kid";
		__misc_state_int["hipster fights available"] = 7 - hipster_fights_used;
		__misc_state["have hipster"] = true;
	}
	else if (familiar_is_usable($familiar[Mini-Hipster]))
	{
		__misc_state_string["hipster name"] = "hipster";
		__misc_state_int["hipster fights available"] = 7 - hipster_fights_used;
		__misc_state["have hipster"] = true;
	}
	__misc_state_string["obtuse angel name"] = "";
	if (familiar_is_usable($familiar[reanimated reanimator]))
		__misc_state_string["obtuse angel name"] = "Reanimated Reanimator";
	else if (familiar_is_usable($familiar[obtuse angel]))
		__misc_state_string["obtuse angel name"] = "Obtuse Angel";
	
	if (get_property_ascension("lastPlusSignUnlock"))
		__misc_state["dungeons of doom unlocked"] = true;
	else
		__misc_state["dungeons of doom unlocked"] = false;
	
	__misc_state["can use clovers"] = true;
	if (in_bad_moon() && $items[ten-leaf clover, disassembled clover].available_amount() == 0)
		__misc_state["can use clovers"] = false;
		
		
	__misc_state["bookshelf accessible"] = true;
	if (my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
		__misc_state["bookshelf accessible"] = false;
        
    
	__misc_state["can pickpocket"] = false;
    if (my_class() == $class[disco bandit] || my_class() == $class[accordion thief] || my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE || $item[tiny black hole].equipped_amount() > 0 || $effect[Form of...Bird!].have_effect() > 0)
        __misc_state["can pickpocket"] = true;
    
    if (CounterLookup("Romantic Monster").CounterExists() || get_property_int("_romanticFightsLeft") > 0)
        __misc_state_string["Romantic Monster Name"] = get_property("romanticTarget").HTMLEscapeString();
        
        //Moxie Experience Percent
    float dance_card_average_stat_gain = MIN(2.25 * my_basestat($stat[moxie]), 300.0) * __misc_state_float["Non-combat statgain multiplier"] * (1.0 + numeric_modifier("Moxie Experience Percent") / 100.0);
    __misc_state_float["dance card average stats"] = dance_card_average_stat_gain;
    
    //don't know if there's any way to query this information directly, so indirectly calculate it from scaling monsters in the area:
    __misc_state_int["Basement Floor"] = MAX(1, round(powf(MAX(0.0, ($monster[Ghost of Fernswarthy's Grandfather].raw_defense - monster_level_adjustment()).to_float() / 2.0), 5.0 / 7.0)));
    
    if (true)
    {
        //calculate if we need -combat sources:
        int minus_combat_source_count = 0;
        int minus_combat_from_accessories = 0;
        
        foreach it in __minus_combat_equipment
        {
            if (!(it.can_equip() && it.available_amount() > 0))
                continue;
            if (it == $item[none])
                continue;
            if (it == $item[over-the-shoulder folder holder])
            {
            }
            int value = -it.numeric_modifier("combat rate");
            if ($slots[acc1,acc2,acc3] contains it.to_slot())
                minus_combat_from_accessories += value;
            else
                minus_combat_source_count += value;
        }
        if ($item[over-the-shoulder folder holder].available_amount() > 0)
        {
            //check if we have the -combat folder:
            boolean [item] equipped_folders;
            foreach s in $slots[folder1,folder2,folder3,folder4,folder5]
            {
                equipped_folders[s.equipped_item()] = true;
            }
            if (!(equipped_folders contains $item[folder (Ex-Files)]))
            {
                if (equipped_folders contains $item[folder (skull and crossbones)])
                {
                    minus_combat_from_accessories += 5;
                }
            }
        }
        
        minus_combat_source_count += MIN(3 * 5, minus_combat_from_accessories); //three at most
        
        if ($skill[smooth movement].skill_is_usable())
            minus_combat_source_count += 5;
        if ($skill[the sonata of sneakiness].skill_is_usable())
            minus_combat_source_count += 5;
        if ($items[crown of thrones,buddy bjorn].available_amount() > 0 && $familiar[grimstone golem].have_familiar() && !__misc_state["familiars temporarily blocked"])
            minus_combat_source_count += 5;
        if (my_path_id() == PATH_AVATAR_OF_BORIS && $skill[song of solitude].skill_is_usable())
            minus_combat_source_count += 5 * 4;
        if (my_path_id() == PATH_ZOMBIE_SLAYER && $skill[disquiet riot].skill_is_usable())
            minus_combat_source_count += 5 * 4;
        if (my_path_id() == PATH_AVATAR_OF_JARLSBERG && $skill[chocolatesphere].skill_is_usable())
            minus_combat_source_count += 5 * 3;
        if (__iotms_usable[lookupItem("Asdon Martin keyfob")])
            minus_combat_source_count += 10;
        if (my_path_id() == PATH_AVATAR_OF_SNEAKY_PETE)
        {
            if ($skill[Brood].skill_is_usable())
                minus_combat_source_count += 5 * 2;
            if (get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler" && $skill[Rev Engine].skill_is_usable())
                minus_combat_source_count += 5 * 3;
        }
        if (my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING)
        {
            if ($skill[Shelter of Shed].have_skill())
                minus_combat_source_count += 5 * 4;
        }
        if (minus_combat_source_count >= 25)
            __misc_state["can reasonably reach -25% combat"] = true;
    }
    if (my_path_id() == PATH_LIVE_ASCEND_REPEAT)
        __misc_state["can reasonably reach -25% combat"] = true;
    
    if (!in_bad_moon() && $item[hand turkey outline].is_unrestricted())
    {
        foreach s in $strings[spooky,sleaze,hot,cold,stench]
        {
            if (get_property_boolean(s + "AirportAlways") || get_property_boolean("_" + s + "AirportToday"))
                __misc_state[s + " airport available"] = true;
        }
    }
    
    if (get_property_boolean("chateauAvailable") && !in_bad_moon() && $item[Chateau Mantegna room key].is_unrestricted())
    {
        __misc_state["Chateau Mantegna available"] = true;
    }
    
    
    __misc_state_string["resting url"] = "campground.php";
    __misc_state_string["resting description"] = "your campsite";
    __misc_state["recommend resting at campsite"] = true;
    if (__misc_state["Chateau Mantegna available"])// && (my_level() < 13 || __misc_state["need to level"] || $item[pantsgiving].available_amount() == 0))
    {
        __misc_state_string["resting url"] = "place.php?whichplace=chateau";
        __misc_state_string["resting description"] = "Chateau Mantegna";
        __misc_state["recommend resting at campsite"] = false;
    }
    
    if ($classes[seal clubber,turtle tamer] contains my_class())
        __misc_state["guild open"] = QuestState("questG09Muscle").finished;
    else if ($classes[pastamancer,sauceror] contains my_class())
        __misc_state["guild open"] = QuestState("questG07Myst").finished;
    else if ($classes[disco bandit,accordion thief] contains my_class())
        __misc_state["guild open"] = QuestState("questG08Moxie").finished;
    if (guild_store_available())
        __misc_state["guild open"] = true;
    
    
    __misc_state["muscle guild store available"] = false;
    __misc_state["mysticality guild store available"] = false;
    __misc_state["moxie guild store available"] = false;
    if (guild_store_available())
    {
        if ($classes[seal clubber, turtle tamer] contains my_class())
            __misc_state["muscle guild store available"] = true;
        if ($classes[pastamancer, sauceror] contains my_class())
            __misc_state["mysticality guild store available"] = true;
        if ($classes[disco bandit,accordion thief] contains my_class())
            __misc_state["moxie guild store available"] = true;
        
        if (my_class() == $class[accordion thief] && my_level() >= 9)
        {
            __misc_state["muscle guild store available"] = true;
            __misc_state["mysticality guild store available"] = true;
        }
    }

    __misc_state["can purchase magical mystery juice"] = __misc_state["mysticality guild store available"];
    __misc_state["have some reasonable way of restoring MP"] = false;
    
    if (__misc_state["can purchase magical mystery juice"] || black_market_available() || dispensary_available() || true)
        __misc_state["have some reasonable way of restoring MP"] = true;
    
    if (my_path_id() == PATH_ONE_CRAZY_RANDOM_SUMMER)
        __misc_state["monsters can be nearly impossible to kill"] = true;
    
    int tonic_price = $item[Doc Galaktik's Invigorating Tonic].npc_price();
    if (tonic_price == 0)
        tonic_price = 90; //wrong, but w/e
    __misc_state_float["meat per MP"] = tonic_price.to_float() / 10.0;
    
    float soda_cost = -1.0;
    if (black_market_available())
        soda_cost = $item[black cherry soda].npc_price();
    else if (dispensary_available())
        soda_cost = $item[knob goblin seltzer].npc_price();
    else if (!in_ronin()) //can't buy from NPC, so have to use mall price:
        soda_cost = 100; //$item[knob goblin seltzer].mall_price(); //don't issue a mall search, we don't need it
    
    if (soda_cost > 0.0)
    {
        __misc_state_float["meat per MP"] = MIN(__misc_state_float["meat per MP"], soda_cost / 10.0);
    }
    
    if (__misc_state["can purchase magical mystery juice"])
    {
        float juice_cost = $item[magical mystery juice].npc_price();
        float mp_restored = 5.0 + my_level().to_float() * 1.5;
        
        if (juice_cost > 0.0)
            __misc_state_float["meat per MP"] = MIN(__misc_state_float["meat per MP"], juice_cost / mp_restored);
    }
    
    //FIXME all avatar paths:
    if (my_path_id() == PATH_GELATINOUS_NOOB || my_path_id() == PATH_ZOMBIE_SLAYER || my_path_id() == PATH_AVATAR_OF_BORIS || my_path_id() == PATH_AVATAR_OF_JARLSBERG || my_path_id() == PATH_KOLHS || my_path_id() == PATH_CLASS_ACT_2 || my_path_id() == PATH_ACTUALLY_ED_THE_UNDYING || my_path_id() == PATH_COMMUNITY_SERVICE || my_path_id() == PATH_THE_SOURCE || my_path_id() == PATH_EXPLOSIONS)
        __misc_state["sea access blocked"] = true;

}


void setUpQuestStateViaMafia()
{
	QuestsInit();
	SetsInit();
    
    foreach key, function_name in __init_functions
        call function_name();
	
	//Opening guild quest
	if (true)
	{
		//???
		QuestState state;
		state.startable = true;
	}
}


void finaliseSetUpState()
{
	//done after quest parsing
	
	if (__misc_state["Example mode"])
	{
		__misc_state["need to level"] = true;
        if (my_primestat() == $stat[muscle])
            __misc_state["need to level muscle"] = true;
        if (my_primestat() == $stat[mysticality])
            __misc_state["need to level mysticality"] = true;
        if (my_primestat() == $stat[moxie])
            __misc_state["need to level moxie"] = true;
	}
	
	if (__misc_state_int["pulls available"] > 0)
	{
		PullsInit();
	}
    computeFatLootTokens();
	
	finaliseSetUpFloristState();
}

void setUpQuestState()
{
    if (__misc_state["In valhalla"])
        return;
	setUpQuestStateViaMafia();
}
