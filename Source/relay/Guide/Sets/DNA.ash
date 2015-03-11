//_dnaPotionsMade - int, count of potions made
//dnaSyringe - int, current phylum of syringe. seems to track if it's become empty? double check
//_dnaHybrid - boolean, true if you're become a human abomination today
//r13912 or higher


string [phylum] __dna_phylum_to_description;
string [phylum] __dna_phylum_to_description_colorless;
item [phylum] __dna_phylum_to_item;
effect [phylum] __dna_phylum_to_effect;
phylum [effect] __dna_effect_to_phylum;
string [int] __dna_intrinsic_ideas;

record DNASuggestion
{
    phylum [int] phylums;
    string relevant_effect_description;
    string reason;
    boolean always_show;
};


DNASuggestion DNASuggestionMake(phylum [int] phylums, string relevant_effect_description, string reason, boolean always_show)
{
    DNASuggestion result;
    result.phylums = phylums;
    result.relevant_effect_description = relevant_effect_description;
    result.reason = reason;
    result.always_show = always_show;
    return result;
}

DNASuggestion DNASuggestionMake(phylum p, string relevant_effect_description, string reason)
{
    phylum [int] phylums;
    phylums[0] = p;
    return DNASuggestionMake(phylums, relevant_effect_description, reason, false);
}

DNASuggestion DNASuggestionMake(phylum p, string relevant_effect_description, string reason, boolean always_show)
{
    phylum [int] phylums;
    phylums[0] = p;
    return DNASuggestionMake(phylums, relevant_effect_description, reason, always_show);
}


DNASuggestion DNASuggestionMake(boolean [phylum] phylums_in, string relevant_effect_description, string reason)
{
    phylum [int] phylums;
    foreach p in phylums_in
    {
        phylums.listAppend(p);
    }
    return DNASuggestionMake(phylums, relevant_effect_description, reason, false);
}

void listAppend(DNASuggestion [int] list, DNASuggestion entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

boolean DNAHavePhylum(phylum p)
{
    if (__dna_phylum_to_effect[p].have_effect() > 0)
        return true;
    
    if (__dna_phylum_to_item[p].available_amount() > 0)
        return true;
    
    return false;
}

string DNABoldPhylumIfCurrentMonster(phylum p)
{
    if (monster_phylum() == p)
        return HTMLGenerateSpanOfClass(p.to_string(), "r_bold");
    else
        return p.to_string();
}

DNASuggestion [int] __phylum_potion_suggestions;
DNASuggestion [int] __phylum_potion_reminder_suggestions;
effect __current_dna_intrinsic = $effect[none];

void SDNAInit()
{
    if (!mafiaIsPastRevision(13918)) //minimum supported version
        return;
    if (get_campground()[$item[Little Geneticist DNA-Splicing Lab]] == 0)
        return;


    //this is not a particulary good idea:
    __dna_phylum_to_description[$phylum[beast]] = "+30 weapon damage";
	__dna_phylum_to_description[$phylum[bug]] = "+25% init";
	__dna_phylum_to_description[$phylum[constellation]] = "+50% meat";
	__dna_phylum_to_description[$phylum[construct]] = "+5 familiar weight, +50 DA, +5 DR";
	__dna_phylum_to_description[$phylum[dude]] = "+10% item, +10 muscle/mysticality/moxie";
	__dna_phylum_to_description[$phylum[elemental]] = "+3 resistances";
	__dna_phylum_to_description[$phylum[elf]] = "+100% spell damage, +50% candy drops";
	__dna_phylum_to_description[$phylum[fish]] = "+10 familiar weight";
	__dna_phylum_to_description[$phylum[goblin]] = "+20% pickpocket, +50% food drops";
	__dna_phylum_to_description[$phylum[hippy]] = "+1 stat/fight, +20 max MP";
	__dna_phylum_to_description[$phylum[humanoid]] = "+20% meat, +10% muscle/mysticality/moxie";
	__dna_phylum_to_description[$phylum[horror]] = "+10% critical hit, +10% critical spell hit";
	__dna_phylum_to_description[$phylum[mer-kin]] = "+25 ML";
	__dna_phylum_to_description[$phylum[orc]] = "+1 stat/fight, +40 max HP";
	__dna_phylum_to_description[$phylum[penguin]] = "+25% item";
	__dna_phylum_to_description[$phylum[pirate]] = "+50% gear drops, +50% booze drops";
    
    
	__dna_phylum_to_description_colorless[$phylum[demon]] = "+20 hot damage / hot spell damage";
	__dna_phylum_to_description_colorless[$phylum[hobo]] = "+20 stench damage / stench spell damage";
	__dna_phylum_to_description_colorless[$phylum[plant]] = "+20 cold damage / cold spell damage";
	__dna_phylum_to_description_colorless[$phylum[slime]] = "+20 sleaze damage / sleaze spell damage";
	__dna_phylum_to_description_colorless[$phylum[undead]] = "+20 spooky damage / spooky spell damage";
    
	__dna_phylum_to_description[$phylum[demon]] = HTMLGenerateSpanOfClass(__dna_phylum_to_description_colorless[$phylum[demon]], "r_element_hot_desaturated");
	__dna_phylum_to_description[$phylum[hobo]] = HTMLGenerateSpanOfClass(__dna_phylum_to_description_colorless[$phylum[hobo]], "r_element_stench_desaturated");
	__dna_phylum_to_description[$phylum[plant]] = HTMLGenerateSpanOfClass(__dna_phylum_to_description_colorless[$phylum[plant]], "r_element_cold_desaturated");
	__dna_phylum_to_description[$phylum[slime]] = HTMLGenerateSpanOfClass(__dna_phylum_to_description_colorless[$phylum[slime]], "r_element_sleaze_desaturated");
	__dna_phylum_to_description[$phylum[undead]] = HTMLGenerateSpanOfClass(__dna_phylum_to_description_colorless[$phylum[undead]], "r_element_spooky_desaturated");
    
	__dna_phylum_to_description[$phylum[weird]] = "+4 stats/fight";
    
    foreach p in __dna_phylum_to_description
    {
        if (__dna_phylum_to_description_colorless contains p)
            continue;
        __dna_phylum_to_description_colorless[p] = __dna_phylum_to_description[p];
    }
    
    __dna_phylum_to_item[$phylum[beast]] = lookupItem("Gene Tonic: Beast");
    __dna_phylum_to_item[$phylum[bug]] = lookupItem("Gene Tonic: Insect");
    __dna_phylum_to_item[$phylum[constellation]] = lookupItem("Gene Tonic: Constellation");
    __dna_phylum_to_item[$phylum[construct]] = lookupItem("Gene Tonic: Construct");
    __dna_phylum_to_item[$phylum[demon]] = lookupItem("Gene Tonic: Demon");
    __dna_phylum_to_item[$phylum[dude]] = lookupItem("Gene Tonic: Dude");
    __dna_phylum_to_item[$phylum[elemental]] = lookupItem("Gene Tonic: Elemental");
    __dna_phylum_to_item[$phylum[elf]] = lookupItem("Gene Tonic: Elf");
    __dna_phylum_to_item[$phylum[fish]] = lookupItem("Gene Tonic: Fish");
    __dna_phylum_to_item[$phylum[goblin]] = lookupItem("Gene Tonic: Goblin");
    __dna_phylum_to_item[$phylum[hippy]] = lookupItem("Gene Tonic: Hippy");
    __dna_phylum_to_item[$phylum[hobo]] = lookupItem("Gene Tonic: Hobo");
    __dna_phylum_to_item[$phylum[horror]] = lookupItem("Gene Tonic: Horror");
    __dna_phylum_to_item[$phylum[humanoid]] = lookupItem("Gene Tonic: Humanoid");
    __dna_phylum_to_item[$phylum[mer-kin]] = lookupItem("Gene Tonic: Mer-kin");
    __dna_phylum_to_item[$phylum[orc]] = lookupItem("Gene Tonic: Orc");
    __dna_phylum_to_item[$phylum[penguin]] = lookupItem("Gene Tonic: Penguin");
    __dna_phylum_to_item[$phylum[pirate]] = lookupItem("Gene Tonic: Pirate");
    __dna_phylum_to_item[$phylum[plant]] = lookupItem("Gene Tonic: Plant");
    __dna_phylum_to_item[$phylum[slime]] = lookupItem("Gene Tonic: Slime");
    __dna_phylum_to_item[$phylum[undead]] = lookupItem("Gene Tonic: Undead");
    __dna_phylum_to_item[$phylum[weird]] = lookupItem("Gene Tonic: Weird");
    
    __dna_phylum_to_effect[$phylum[beast]] = lookupEffect("Human-Beast Hybrid");
    __dna_phylum_to_effect[$phylum[bug]] = lookupEffect("Human-Insect Hybrid");
    __dna_phylum_to_effect[$phylum[constellation]] = lookupEffect("Human-Constellation Hybrid");
    __dna_phylum_to_effect[$phylum[construct]] = lookupEffect("Human-Machine Hybrid");
    __dna_phylum_to_effect[$phylum[demon]] = lookupEffect("Human-Demon Hybrid");
    __dna_phylum_to_effect[$phylum[dude]] = lookupEffect("Human-Human Hybrid");
    __dna_phylum_to_effect[$phylum[elemental]] = lookupEffect("Human-Elemental Hybrid");
    __dna_phylum_to_effect[$phylum[elf]] = lookupEffect("Human-Elf Hybrid");
    __dna_phylum_to_effect[$phylum[fish]] = lookupEffect("Human-Fish Hybrid");
    __dna_phylum_to_effect[$phylum[goblin]] = lookupEffect("Human-Goblin Hybrid");
    __dna_phylum_to_effect[$phylum[hippy]] = lookupEffect("Human-Hippy Hybrid");
    __dna_phylum_to_effect[$phylum[hobo]] = lookupEffect("Human-Hobo Hybrid");
    __dna_phylum_to_effect[$phylum[horror]] = lookupEffect("Human-Horror Hybrid");
    __dna_phylum_to_effect[$phylum[humanoid]] = lookupEffect("Human-Humanoid Hybrid");
    __dna_phylum_to_effect[$phylum[mer-kin]] = lookupEffect("Human-Mer-kin Hybrid");
    __dna_phylum_to_effect[$phylum[orc]] = lookupEffect("Human-Orc Hybrid");
    __dna_phylum_to_effect[$phylum[penguin]] = lookupEffect("Human-Penguin Hybrid");
    __dna_phylum_to_effect[$phylum[pirate]] = lookupEffect("Human-Pirate Hybrid");
    __dna_phylum_to_effect[$phylum[plant]] = lookupEffect("Human-Plant Hybrid");
    __dna_phylum_to_effect[$phylum[slime]] = lookupEffect("Human-Slime Hybrid");
    __dna_phylum_to_effect[$phylum[undead]] = lookupEffect("Human-Undead Hybrid");
    __dna_phylum_to_effect[$phylum[weird]] = lookupEffect("Human-Weird Thing Hybrid");
    
    foreach p in __dna_phylum_to_effect
    {
        __dna_effect_to_phylum[__dna_phylum_to_effect[p]] = p;
    }
    
    
    foreach e in __dna_effect_to_phylum
    {
        if (e.have_effect() == 2147483647)
        {
            __current_dna_intrinsic = e;
            break;
        }
    }
    
    
    if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"])
    {
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[bug], "", "speed up defiled alcove"));
        __phylum_potion_reminder_suggestions.listAppend(DNASuggestionMake($phylum[bug], "", "speed up defiled alcove"));
    }
    
    if (!__quest_state["Level 12"].state_boolean["Nuns Finished"])
    {
        //FIXME only suggest constellation if they've not finished HITS?
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylums[constellation,humanoid], "+meat", "nuns"));
        __phylum_potion_reminder_suggestions.listAppend(DNASuggestionMake($phylum[constellation], "+meat", "nuns"));
        __phylum_potion_reminder_suggestions.listAppend(DNASuggestionMake($phylum[humanoid], "+meat", "nuns"));
        
    }
    if (!__quest_state["Level 3"].finished)
    {
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylums[demon,hobo,plant,undead], "+elemental damage", "tavern NC skipping"));
    }
    if (!__quest_state["Level 12"].finished && (!have_outfit_components("War Hippy Fatigues") && !have_outfit_components("Frat Warrior Fatigues")) && !__misc_state["yellow ray potentially available"])
    {
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[pirate], "+50% gear drop", "war outfit?"));
    }
    if (__quest_state["Level 11 Palindome"].mafia_internal_step < 5 && $item[mega gem].available_amount() == 0 && in_hardcore() && !($skill[Check Hair].skill_is_usable() && $skill[Natural Dancer].skill_is_usable())) //avatar of sneaky pete usually can cap this easily... usually
    {
        if ($item[wet stunt nut stew].available_amount() == 0 && !(($item[bird rib].available_amount() > 0 && $item[lion oil].available_amount() > 0 || $item[wet stew].available_amount() > 0)))
        {
            __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[goblin], "+50% food drop", "Wet stunt nut stew components"));
            __phylum_potion_reminder_suggestions.listAppend(DNASuggestionMake($phylum[goblin], "+50% food drop", "Wet stunt nut stew components")); //300% drop, very important
        }
    }
    
    if (true)
    {
        string [int] reasons;
        if (!__quest_state["Level 8"].finished && numeric_modifier("cold resistance") < 5.0)
            reasons.listAppend("icy peak");
        if (__quest_state["Level 9"].state_int["a-boo peak hauntedness"] > 0)
            reasons.listAppend("a-boo peak");
        
        if (reasons.count() > 0)
            __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[elemental], "+3 all resistance", reasons.listJoinComponents(", ", "and").capitalizeFirstLetter()));
    }
    
    if (__misc_state["In run"])
    {
        if (__current_dna_intrinsic != __dna_phylum_to_effect[$phylum[construct]] && !__misc_state["familiars temporarily blocked"])
            __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[construct], "+5 familiar weight, DR/DA", "", true));
        if (__current_dna_intrinsic != __dna_phylum_to_effect[$phylum[dude]])
            __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[dude], "+10% item", "", true));
        
        if (!__quest_state["Level 13"].state_boolean["Elemental damage race completed"])
        {
            string element_needed = __quest_state["Level 13"].state_string["Elemental damage race type"];
            DNASuggestion element_suggestion;
            string suggestion_effect = "+" + HTMLGenerateSpanOfClass(element_needed, "r_element_" + element_needed + "_desaturated") + " damage/spell damage";
            string suggestion_description = "Lair race";
            if (element_needed == "hot")
                element_suggestion = DNASuggestionMake($phylum[demon], suggestion_effect, suggestion_description, true);
            else if (element_needed == "cold")
                element_suggestion = DNASuggestionMake($phylum[plant], suggestion_effect, suggestion_description, true);
            else if (element_needed == "sleaze")
                element_suggestion = DNASuggestionMake($phylum[slime], suggestion_effect, suggestion_description, true);
            else if (element_needed == "spooky")
                element_suggestion = DNASuggestionMake($phylum[undead], suggestion_effect, suggestion_description, true);
            else if (element_needed == "stench")
                element_suggestion = DNASuggestionMake($phylum[hobo], suggestion_effect, suggestion_description, true);
            if (element_suggestion.phylums.count() > 0 && element_needed.length() > 0)
            {
                __phylum_potion_suggestions.listAppend(element_suggestion);
                __phylum_potion_reminder_suggestions.listAppend(element_suggestion);
            }
        }
    }
    else
    {
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[penguin], "", "", true));
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[fish], "", "", true));
        __phylum_potion_suggestions.listAppend(DNASuggestionMake($phylum[constellation], "", "", true));
    }
    
    
    if (__current_dna_intrinsic == $effect[none])
    {
        if (!__misc_state["familiars temporarily blocked"])
        {
            if (!__misc_state["In run"] || my_path_id() == PATH_HEAVY_RAINS)
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[fish]) + " (+10 familiar weight)");
            else if ($item[grimstone mask].available_amount() > 0)
            {
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[fish]) + " (+10 familiar weight, via grimstone mask candy witch's lake)");
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[construct]) + " (+5 familiar weight)");
            }
            else
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[construct]) + " (+5 familiar weight)");
        }
        if (__misc_state["need to level"])
        {
            if ($familiar[astral badger].familiar_is_usable() || $item[astral mushroom].available_amount() > 0 || $effect[Half-Astral].have_effect() > 0 || __misc_state_int["pulls available"] > 0)
            {
                string method = "astral badger";
                if (!$familiar[astral badger].familiar_is_usable() || $item[astral mushroom].available_amount() > 0)
                    method = "astral mushroom";
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[weird]) + " (+4 stats/fight, via " + method + ")");
            }
            else if (__misc_state["sleaze airport available"])
            {
                __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[weird]) + " (+4 stats/fight, via sloppy seconds diner)");
            }
        }
        __dna_intrinsic_ideas.listAppend(DNABoldPhylumIfCurrentMonster($phylum[dude]) + " (+10% item)");
        
    }
}

void SDNAGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if (!mafiaIsPastRevision(13918)) //minimum supported version
        return;
    if (__misc_state["campground unavailable"])
        return;
    if (get_campground()[lookupItem("Little Geneticist DNA-Splicing Lab")] == 0)
        return;
    
    //Player has a genetic engineering lab installed. Let's play with our DNA!
    
    phylum syringe_phylum = get_property("dnaSyringe").to_phylum();
    int potions_made = get_property_int("_dnaPotionsMade");
    int potions_left = MAX(0, 3 - potions_made);
    boolean became_a_genetic_monstrosity_today = get_property_boolean("_dnaHybrid");
    
    
    //Some ideas:
    //Intrinsics:
    //√constructs - +5 familiar weight - also a potion option
    //√weird - +4 stats/fight - hard to find without badger
    //√dudes - +10% items
    
    //fish - +10 familiar weight - HCO only? possible with agua de vida, but takes at least two turns? 70% NC base, 2 NCs, need two of an NC. this is versus zero-turn +5 familiar weight...
    //mer-kin - +25 ML - fax only. even with sea access, requires wreck access
    //orcs/hippies - +1 stat/fight... ??? marginal?
    //penguins - +25% item - nowhere to be found in-run before level 11
    
    //Potions:
    //√bug - +25% init - modern zmobies, potion, if we can find bugs
    //√elemental - +3 all res - icy peak, a-boo, stench for twin/bats
    //√constellation - +50% meat - nuns, potion
    //√humanoid - +20% meat - more nuns?
    //√demon - +20 hot damage - skipping tavern NC
    //√hobo - +20 stench damage - skipping tavern NCs, but isn't there a better source? (the pool)
    //√plant - +20 cold damage - tavern skipping, somewhat silly, song of north exists
    //√undead - +20 spooky damage - tavern skipping...?
    //pirate - +50% gear drops - not sure. potion? seems like it'd be useful in a handful of places
    
    
    
    
    
    ChecklistSubentry [int] subentries;
    
    string syringe_description = "";
    boolean syringe_description_output = false;
    if (syringe_phylum != $phylum[none])
    {
        string line = "Syringe has " + syringe_phylum + "." + " (" + __dna_phylum_to_description_colorless[syringe_phylum] + ")";
        syringe_description = line;
    }
    
    if (potions_left > 0)
    {
        string [int] description;
        
        if (syringe_description.length() > 0 && !syringe_description_output)
        {
            description.listAppend(syringe_description);
            syringe_description_output = true;
        }
        
        string [int] potion_suggestion_descriptions;
        foreach key in __phylum_potion_suggestions
        {
            DNASuggestion suggestion = __phylum_potion_suggestions[key];
            
            phylum [int] needed_phylums;
            
            foreach key2 in suggestion.phylums
            {
                phylum p = suggestion.phylums[key2];
                if (!DNAHavePhylum(p) || suggestion.always_show)
                {
                    needed_phylums.listAppend(p);
                }
            }
            
            if (needed_phylums.count() > 0)
            {
                string [int] phylum_descriptions;
                string [int] output_effect_description;
                
                foreach key in needed_phylums
                {
                    phylum p = needed_phylums[key];
                    
                    phylum_descriptions.listAppend(DNABoldPhylumIfCurrentMonster(p));
                    
                    if (suggestion.relevant_effect_description.length() == 0)
                        output_effect_description.listAppend(__dna_phylum_to_description_colorless[p]);
                }
                if (suggestion.relevant_effect_description.length() > 0)
                    output_effect_description.listAppend(suggestion.relevant_effect_description);
                
                string line;
                
                line = phylum_descriptions.listJoinComponents("/");
                line += ": " + output_effect_description.listJoinComponents("/");
                if (suggestion.reason.length() > 0)
                    line += " - " + suggestion.reason;
                
                potion_suggestion_descriptions.listAppend(line);
            }
        }
        //HTMLGenerateSimpleTableLines
        if (potion_suggestion_descriptions.count() > 0)
            description.listAppend("Tonic ideas:|*" + potion_suggestion_descriptions.listJoinComponents("<hr>|*"));
        subentries.listAppend(ChecklistSubentryMake(pluralize(potions_left, "gene tonic", "gene tonics") + " creatable", "", description));
    }
    if (!became_a_genetic_monstrosity_today)
    {
        string [int] description;
        if (syringe_description.length() > 0 && !syringe_description_output)
        {
            description.listAppend(syringe_description);
            syringe_description_output = true;
        }
        
        if (__current_dna_intrinsic != $effect[none] && (__dna_effect_to_phylum contains __current_dna_intrinsic))
            description.listAppend("Currently a " + __dna_effect_to_phylum[__current_dna_intrinsic] + ". (" + __dna_phylum_to_description_colorless[__dna_effect_to_phylum[__current_dna_intrinsic]] + ")");
        
        
        if (__current_dna_intrinsic == $effect[none])
        {
            if (__dna_intrinsic_ideas.count() > 0)
                description.listAppend("Could try " + __dna_intrinsic_ideas.listJoinComponents(", ", "or") + ".");
        }
        
        subentries.listAppend(ChecklistSubentryMake("Genetic intrinsic available", "", description));
    }
    
    int importance = 5;
    
    if (potions_left == 0 && __current_dna_intrinsic != $effect[none]) //no potions, already a hybrid
        importance = 8;
    
    string image_name = "__effect Human-Human Hybrid";
    
    if (__misc_state["In run"])
    {
        foreach p in __dna_phylum_to_item
        {
            item it = __dna_phylum_to_item[p];
            if (it.available_amount() == 0)
                continue;
            if (subentries.count() == 0)
                image_name = "__item Gene Tonic: Constellation";
            subentries.listAppend(ChecklistSubentryMake(it.pluralize(), "", __dna_phylum_to_description_colorless[p]));
            
        }
    }
    
    if (subentries.count() > 0)
        available_resources_entries.listAppend(ChecklistEntryMake(image_name, "campground.php?action=workshed", subentries, importance));
    
    
}

void SDNAGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (__misc_state["campground unavailable"])
        return;
    if (!(mafiaIsPastRevision(13918) && get_campground()[lookupItem("Little Geneticist DNA-Splicing Lab")] > 0))
        return;
    
    //Reminders:
    phylum syringe_phylum = get_property("dnaSyringe").to_phylum();
    
    
    if (get_property_int("_dnaPotionsMade") < 3)
    {
        if (syringe_phylum != $phylum[none] && !DNAHavePhylum(syringe_phylum))
        {
            //Make the resulting tonic:
            string suggestion_reason;
            
            string relevant_effect_description;
            
            
            foreach key in __phylum_potion_reminder_suggestions
            {
                DNASuggestion suggestion = __phylum_potion_reminder_suggestions[key];
                foreach key2 in suggestion.phylums
                {
                    phylum suggestion_phylum = suggestion.phylums[key2];
                    if (syringe_phylum == suggestion_phylum)
                    {
                        suggestion_reason = suggestion.reason;
                        relevant_effect_description = suggestion.relevant_effect_description;
                    }
                }
            }
            
            
            if (suggestion_reason.length() > 0)
            {
                string description = suggestion_reason.capitalizeFirstLetter() + ".";
                task_entries.listAppend(ChecklistEntryMake("__effect Human-Human Hybrid", "campground.php?action=workshed", ChecklistSubentryMake("Make gene tonic for " + syringe_phylum, "", description), -11));
            }
        }
        
        
        
        if (monster_phylum() != $phylum[none] && monster_phylum() != syringe_phylum && !DNAHavePhylum(monster_phylum()))
        {
            //Syringe a monster when we find it:
            phylum p = monster_phylum();
            
            string suggestion_reason;
            
            string relevant_effect_description;
            
            
            foreach key in __phylum_potion_reminder_suggestions
            {
                DNASuggestion suggestion = __phylum_potion_reminder_suggestions[key];
                foreach key2 in suggestion.phylums
                {
                    phylum suggestion_phylum = suggestion.phylums[key2];
                    if (p == suggestion_phylum)
                    {
                        suggestion_reason = suggestion.reason;
                        relevant_effect_description = suggestion.relevant_effect_description;
                    }
                }
            }
            
            if (suggestion_reason.length() > 0)
            {
                if (relevant_effect_description.length() == 0)
                    relevant_effect_description = __dna_phylum_to_description[p];
                string description = suggestion_reason.capitalizeFirstLetter() + ".";
                description += "|" + monster_phylum().to_string().capitalizeFirstLetter() + " (" + relevant_effect_description + ")";
                task_entries.listAppend(ChecklistEntryMake("__effect Human-Human Hybrid", "", ChecklistSubentryMake("Extract DNA from " + last_monster().to_string().HTMLEscapeString(), "", description), -11));
            }
        }
    }
    
    if (__current_dna_intrinsic == $effect[none] && !get_property_boolean("_dnaHybrid"))
    {
        string [int] description;
        if (__dna_intrinsic_ideas.count() > 0)
            description.listAppend("Could try " + __dna_intrinsic_ideas.listJoinComponents(", ", "or") + ".");
        optional_task_entries.listAppend(ChecklistEntryMake("__effect Human-Human Hybrid", "campground.php?action=workshed", ChecklistSubentryMake("Hybridize yourself", "", description), 5));
    }
}