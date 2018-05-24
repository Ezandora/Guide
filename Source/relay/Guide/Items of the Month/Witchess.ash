RegisterResourceGenerationFunction("IOTMWitchessGenerateResource");
void IOTMWitchessGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[$item[Witchess Set]])
        return;
    if (!mafiaIsPastRevision(16813))
        return;
    
    string image_name = "";
    ChecklistSubentry [int] subentries;
    if (get_property_int("_witchessFights") < 5)
    {
        string [int] description;
        int fights_remaining = clampi(5 - get_property_int("_witchessFights"), 0, 5);
        
        string [int][int] fight_descriptions;
        //fight_descriptions.listAppend(listMake(HTMLGenerateSpanOfClass("Piece", "r_bold"), HTMLGenerateSpanOfClass("Drop", "r_bold")));
        if (__misc_state["in run"])
        {
            //√pawn - +50% init potion for moderns
            if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"] && $item[armored prawn].available_amount() == 0 && $item[armored prawn].to_effect().have_effect() == 0 && my_path_id() != PATH_G_LOVER)
            {
                fight_descriptions.listAppend(listMake("Pawn", "+50% init spleen potion."));
            }
            //rook - +ML / +stat potion
            if (my_path_id() != PATH_G_LOVER)
	            fight_descriptions.listAppend(listMake("Rook", "+25 ML/+statgain potion. (25 turns)"));
            //ox - shield
            if ($item[ox-head shield].available_amount() == 0 && my_path_id() != PATH_G_LOVER)
                fight_descriptions.listAppend(listMake("Ox", "+100HP, +2 all res, +8 PVP fights shield."));
            //king - club
            if ((my_path_id() == PATH_COMMUNITY_SERVICE || my_primestat() == $stat[muscle]) && $item[dented scepter].available_amount() == 0 && my_path_id() != PATH_G_LOVER)
                fight_descriptions.listAppend(listMake("King", "+5 muscle stats/fight, +50% muscle, +50% weapon damage club."));
            //queen - -combat hat
            if ($item[very pointy crown].available_amount() == 0 && my_path_id() != PATH_G_LOVER)
                fight_descriptions.listAppend(listMake("Queen", "-combat, +5 adventures, +50% moxie, +5 moxie stats/fight hat.|Queen is exceptionally difficult to defeat, probably requiring deleveling via items" + ($skill[tricky knifework].have_skill() ? ", or maybe knife tricks" : "") + "."));
            //witch - myst broom
            if ((my_path_id() == PATH_COMMUNITY_SERVICE || my_primestat() == $stat[mysticality]) && $item[battle broom].available_amount() == 0)
                fight_descriptions.listAppend(listMake("Witch", "+5 myst stats/fight, +50% myst, +100% spell damage accessory.|Immune to spells, but not skills."));
        }
        //knight - epic food, +meat drop
        if (__misc_state["can eat just about anything"])
        {
            fight_descriptions.listAppend(listMake("Knight", "+100% meat epic food."));
        }
        //bishop - epic drink, +50% item
        if (__misc_state["can drink just about anything"] && my_path_id() != PATH_G_LOVER)
        {
            fight_descriptions.listAppend(listMake("Bishop", "+50% item epic drink."));
        }
        
        if (fight_descriptions.count() > 0)
        {
            //Bold the piece names:
            foreach key in fight_descriptions
            {
                fight_descriptions[key][0] = HTMLGenerateSpanOfClass(fight_descriptions[key][0], "r_bold");
            }
            description.listAppend(HTMLGenerateSimpleTableLines(fight_descriptions));
        }
        
        image_name = "__itemsize __monster Witchess Pawn";
        subentries.listAppend(ChecklistSubentryMake(pluralise(fights_remaining, "witchess fight", "witchess fights"), "", description));
        //resource_entries.listAppend(ChecklistEntryMake(, "campground.php?action=witchess", );
    }
    if (!get_property_boolean("_witchessBuff") && mafiaIsPastRevision(16879) && !__misc_state["familiars temporarily blocked"] && $effect[puzzle champ].effect_is_usable())
    {
        int familiar_weight_modifier = MAX(5, get_property_int("puzzleChampBonus"));
        if (image_name == "")
            image_name = "__effect Puzzle Champ";
        subentries.listAppend(ChecklistSubentryMake("Witchess buff", "", "+" + familiar_weight_modifier + " familiar weight. (25 turns)"));
        //resource_entries.listAppend(ChecklistEntryMake("__effect Puzzle Champ", "campground.php?action=witchess", ChecklistSubentryMake("Witchess buff", "", "+" + familiar_weight_modifier + " familiar weight. (25 turns)"), 4));
    }
    if (subentries.count() > 0)
        resource_entries.listAppend(ChecklistEntryMake(image_name, "campground.php?action=witchess", subentries, 4));
}
