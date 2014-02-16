Record COTSuggestion
{
    string reason;
    familiar [int] familiars;
};


COTSuggestion COTSuggestionMake(string reason, familiar [int] familiars)
{
    COTSuggestion suggestion;
    suggestion.reason = reason;
    suggestion.familiars = familiars;
    
    return suggestion;
}

COTSuggestion COTSuggestionMake(string reason, familiar f)
{
    familiar [int] familiar_list;
    familiar_list.listAppend(f);
    return COTSuggestionMake(reason, familiar_list);
}

COTSuggestion COTSuggestionMake(string reason, boolean [familiar] familiars_in)
{
    familiar [int] familiars_out;
    foreach f in familiars_in
        familiars_out.listAppend(f);
    return COTSuggestionMake(reason, familiars_out);
}

void listAppend(COTSuggestion [int] list, COTSuggestion entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


//Follows in order. If we can't find one in the first set, we check the second, then third, etc.
//This allows for supporting +25% meat, then falling back on +20%, etc.
Record COTSuggestionSet
{
    COTSuggestion [int] suggestions;
};

COTSuggestionSet COTSuggestionSetMake(COTSuggestion [int] suggestions)
{
    COTSuggestionSet suggestion_set;
    suggestion_set.suggestions = suggestions;
    
    return suggestion_set;
}

COTSuggestionSet COTSuggestionSetMake(COTSuggestion suggestion)
{
    COTSuggestionSet suggestion_set;
    suggestion_set.suggestions.listAppend(suggestion);
    
    return suggestion_set;
}

void listAppend(COTSuggestionSet [int] list, COTSuggestionSet entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}


void SCOTGenerateSuggestions(string [int] description)
{
    familiar enthroned_familiar = my_enthroned_familiar();
    //Suggest what it offers:
    COTSuggestionSet [int] suggestion_sets;
    
    boolean have_two_available = false;
    if ($item[crown of thrones].available_amount() > 0 && lookupItem("Buddy Bjorn").available_amount() > 0)
        have_two_available = true;

    //Relevant:
    //+10ML
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+10 ML and +MP regen", $familiar[el vibrato megadrone])));
    //+15% item drops, or +10%
    if (true)
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+15% items", $familiars[li'l xenomorph, feral kobold]));
        suggestions.listAppend(COTSuggestionMake("+10% items", $familiars[Reassembled Blackbird,Reconstituted Crow,Oily Woim]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }
    //+2 moxie/muscle/mysticality stats/fight
    if (__misc_state["Need to level"])
    {
        if (my_primestat() == $stat[moxie])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[blood-faced volleyball,jill-o-lantern, nervous tick,mariachi chihuahua, cymbal-playing monkey,hovering skull])));
        }
        else if (my_primestat() == $stat[mysticality])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[reanimated reanimator,dramatic hedgehog,cheshire bat,pygmy bugbear shaman,hovering sombrero,sugar fruit fairy, uniclops])));
        }
        else if (my_primestat() == $stat[muscle])
        {
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 mainstat/fight", $familiars[hunchbacked minion, killer bee, grinning turtle,chauvinist pig, baby mutant rattlesnake])));
        }
    }
    //+25% / +20% meat from monsters
    if (true)
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+25% meat", $familiars[Knob Goblin Organ Grinder,Happy Medium,Hobo Monkey]));
        suggestions.listAppend(COTSuggestionMake("+20% meat", $familiars[Dancing Frog,Psychedelic Bear,Hippo Ballerina,Attention-Deficit Demon,Piano Cat,Coffee Pixie,Obtuse Angel,Hand Turkey,Leprechaun,Grouper Groupie,Mutant Cactus Bud,Jitterbug,Casagnova Gnome]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }
    //+5 to familiar weight
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+5 familiar weight", $familiars[Gelatinous Cubeling,Pair of Ragged Claws,Spooky Pirate Skeleton,Autonomous Disco Ball,Ghost Pickle on a Stick,Misshapen Animal Skeleton,Animated Macaroni Duck,Penguin Goodfella,Barrrnacle])));
    //+20% to combat init
    if (__misc_state["in run"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+20% init", $familiars[Teddy Bear,Emo Squid,Evil Teddy Bear,Syncopated Turtle,Untamed Turtle,Mini-Skulldozer,Cotton Candy Carnie,Origami Towel Crane,Feather Boa Constrictor,Levitating Potato,Temporal Riftlet,Squamous Gibberer,Cuddlefish,Teddy Borg])));
    //+15% to moxie/muscle/mysticality
    if (__misc_state["in run"])
    {
        if (true)
        {
            //Either scaling monster levelling, or the NS
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% moxie", $familiars[Ninja Snowflake,Nosy Nose,Clockwork Grapefruit,Sabre-Toothed Lime])));
        }
        if (my_primestat() == $stat[mysticality] && __misc_state["Need to level"])
        {
            //Scaling monster levelling
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% mysticality", $familiars[Ragamuffin Imp,Inflatable Dodecapede,Scary Death Orb,Snowy Owl,grue])));
        }
        else if (my_primestat() == $stat[muscle] && __misc_state["Need to level"])
        {
            //Scaling monster levelling
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+15% muscle", $familiars[MagiMechTech MicroMechaMech,Angry Goat,Wereturtle,Stab Bat,Wind-up Chattering Teeth,Imitation Crab])));
        }
    }
    //+20%/+15%/+10% to spell damage
    //Too marginal?
    /*if (__misc_state["in run"])
    {
        COTSuggestion [int] suggestions;
        suggestions.listAppend(COTSuggestionMake("+20% spell damage", $familiar[mechanical songbird]));
        suggestions.listAppend(COTSuggestionMake("+15% spell damage", $familiars[Magic Dragonfish,Pet Cheezling,Rock Lobster]));
        suggestions.listAppend(COTSuggestionMake("+10% spell damage", $familiars[Midget Clownfish,Star Starfish,Baby Yeti,Snow Angel,Wizard Action Figure,Dataspider,Underworld Bonsai,Whirling Maple Leaf,Rogue Program,Howling Balloon Monkey]));
        suggestion_sets.listAppend(COTSuggestionSetMake(suggestions));
    }*/
    //hot wings from reanimator
    if (true)
    {
        string [int] reanimator_reasons;
        
        if (!__quest_state["Level 13"].state_boolean["have relevant drum"] && $item[broken skull].available_amount() == 0)
        {
            reanimator_reasons.listAppend("broken skull (drum)");
        }
        if (__quest_state["Pirate Quest"].state_boolean["need more hot wings"])
            reanimator_reasons.listAppend("hot wings");
        
        if (reanimator_reasons.count() > 0)
            suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake(reanimator_reasons.listJoinComponents(", ").capitalizeFirstLetter(), $familiar[reanimated reanimator])));
    }
    if (__misc_state["in run"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("50% block", $familiar[Mariachi Chihuahua])));
    
    //knob mushrooms from badger
    if (__misc_state["in run"] && __misc_state["can eat just about anything"])
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Knob mushrooms", $familiar[astral badger])));
        
    boolean need_cold_res = false;
    boolean need_all_res = false;
    //At a-boo peak, but not finished with it:
    if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0 && __quest_state["Level 9"].state_boolean["bridge complete"])
        need_all_res = true;
    //Climbing the peak:
    if (__quest_state["Level 8"].state_boolean["Past mine"] && !__quest_state["Level 8"].state_boolean["Groar defeated"] && numeric_modifier("cold resistance") < 5.0)
        need_cold_res = true;
    
    if (__misc_state["in run"] && need_cold_res)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+3 cold res", $familiar[Flaming Face])));
    if (need_cold_res && !$familiar[flaming face].have_familiar_replacement())
        need_all_res = true;
    if (__misc_state["in run"] && need_all_res)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+2 all res", $familiars[Bulky Buddy Box,Exotic Parrot,Holiday Log,Pet Rock,Toothsome Rock])));
        
    if (__misc_state["in run"] && availableSpleen() >= 4)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Spleen items", lookupFamiliar("Grim Brother"))));
    
    //slightly powerful:
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("+combat", lookupFamiliar("Grim Brother"))));
    suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("-combat", lookupFamiliar("Grimstone Golem"))));
    
    if (get_property_int("_grimstoneMaskDropsCrown") == 0)
        suggestion_sets.listAppend(COTSuggestionSetMake(COTSuggestionMake("Grimstone mask", lookupFamiliar("Grimstone Golem"))));
    string [int][int] familiar_options;
    foreach key in suggestion_sets
    {
        boolean found_relevant = false;
        COTSuggestionSet suggestion_set = suggestion_sets[key];
        foreach key2 in suggestion_set.suggestions
        {
            //Suggest the familiar with the highest weight, under the assumption they're using it more.
            COTSuggestion suggestion = suggestion_set.suggestions[key2];
            familiar best_familiar_by_weight = $familiar[none];
            familiar second_best_familiar_by_weight = $familiar[none];
            foreach key3 in suggestion.familiars
            {
                familiar f = suggestion.familiars[key3];
                if (f == $familiar[none]) //didn't find it
                    continue;
                if (f.have_familiar_replacement())
                {
                    if ((best_familiar_by_weight != enthroned_familiar || enthroned_familiar == $familiar[none]) && (best_familiar_by_weight == $familiar[none] || f.familiar_weight() > best_familiar_by_weight.familiar_weight() || f == enthroned_familiar))
                    {
                        second_best_familiar_by_weight = best_familiar_by_weight;
                        best_familiar_by_weight = f;
                    }
                    else if (second_best_familiar_by_weight == $familiar[none] || f.familiar_weight() > second_best_familiar_by_weight.familiar_weight())
                    {
                        if (best_familiar_by_weight != f)
                            second_best_familiar_by_weight = f;
                    }
                }
            }
            if (best_familiar_by_weight != $familiar[none])
            {
                string familiar_string;
                
                familiar_string = best_familiar_by_weight;
                if (enthroned_familiar == best_familiar_by_weight && enthroned_familiar != $familiar[none])
                    familiar_string = HTMLGenerateSpanOfClass(best_familiar_by_weight, "r_bold");
                    
                if (second_best_familiar_by_weight != $familiar[none] && have_two_available)
                    familiar_string += "|" + second_best_familiar_by_weight;
                familiar_options.listAppend(listMake(suggestion.reason, familiar_string));
                break;
            }
        }
    }
    if (familiar_options.count() > 0)
        description.listAppend(HTMLGenerateSimpleTableLines(familiar_options));
}

void SCOTGenerateResource(ChecklistEntry [int] available_resources_entries)
{
	if ($item[crown of thrones].available_amount() == 0 && lookupItem("Buddy Bjorn").available_amount() == 0)
		return;
    if (__misc_state["familiars temporarily blocked"]) //avatar paths
        return;
	string [int] description;
    
    item crown_item = $item[crown of thrones];
    if (crown_item.equipped_amount() == 0 && lookupItem("Buddy Bjorn").available_amount() > 0)
        crown_item = lookupItem("Buddy Bjorn");
    
    string image_name = "__item " + crown_item;
    familiar enthroned_familiar = my_enthroned_familiar();
    
    if (($item[crown of thrones].equipped_amount() > 0 || lookupItem("Buddy Bjorn").equipped_amount() > 0) || __misc_state["in run"])
    {
        SCOTGenerateSuggestions(description);
    }
    
	if (enthroned_familiar != $familiar[none])
    {
		description.listAppend(enthroned_familiar + " enthroned.");
        //image_name = "__familiar " + enthroned_familiar.to_string();
    }
    
    string url = "familiar.php";
    if ($item[crown of thrones].equipped_amount() == 0 && lookupItem("Buddy Bjorn").equipped_amount() == 0)
        url = "inventory.php?which=2";
    if (description.count() > 0)
        available_resources_entries.listAppend(ChecklistEntryMake(image_name, url, ChecklistSubentryMake(crown_item, "", description), 8));
}