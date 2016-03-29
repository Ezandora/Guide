RegisterResourceGenerationFunction("IOTMWitchessGenerateResource");
void IOTMWitchessGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (in_bad_moon() || get_campground()[lookupItem("Witchess Set")] == 0)
        return;
    if (!mafiaIsPastRevision(16813))
        return;
    
    if (get_property_int("_witchessFights") < 5)
    {
        string [int] description;
        int fights_remaining = clampi(5 - get_property_int("_witchessFights"), 0, 5);
        
        string [int][int] fight_descriptions;
        //fight_descriptions.listAppend(listMake(HTMLGenerateSpanOfClass("Piece", "r_bold"), HTMLGenerateSpanOfClass("Drop", "r_bold")));
        if (__misc_state["in run"])
        {
            //√pawn - +50% init potion for moderns
            if (__quest_state["Level 7"].state_boolean["alcove needs speed tricks"] && lookupItem("armored prawn").available_amount() == 0 && lookupItem("armored prawn").to_effect().have_effect() == 0)
            {
                fight_descriptions.listAppend(listMake("Pawn", "+50% init potion."));
            }
            //rook - +ML / +stat potion
            fight_descriptions.listAppend(listMake("Rook", "+25 ML/+statgain potion. (25 turns)"));
            //ox - shield
            if (lookupItem("ox-head shield").available_amount() == 0)
                fight_descriptions.listAppend(listMake("Ox", "+100HP, +2 all res, +8 PVP fights shield."));
            //king - club
            if ((my_path_id() == PATH_COMMUNITY_SERVICE || my_primestat() == $stat[muscle]) && lookupItem("dented scepter").available_amount() == 0)
                fight_descriptions.listAppend(listMake("King", "+5 muscle stats/fight, +50% muscle, +50% weapon damage club."));
            //queen - -combat hat
            if (lookupItem("very pointy crown").available_amount() == 0)
                fight_descriptions.listAppend(listMake("Queen", "-combat, +5 adventures, +50% moxie, +5 moxie stats/fight hat.|Queen is exceptionally difficult to defeat, probably requiring deleveling via items" + ($skill[tricky knifework].have_skill() ? ", or maybe knife tricks" : "") + "."));
            //witch - myst broom
            if ((my_path_id() == PATH_COMMUNITY_SERVICE || my_primestat() == $stat[mysticality]) && lookupItem("battle broom").available_amount() == 0)
                fight_descriptions.listAppend(listMake("Witch", "+5 myst stats/fight, +50% myst, +100% spell damage accessory.|Immune to spells, but not skills."));
        }
        //knight - epic food, +meat drop
        if (__misc_state["can eat just about anything"])
        {
            fight_descriptions.listAppend(listMake("Knight", "+100% meat epic food."));
        }
        //bishop - epic drink, +50% item
        if (__misc_state["can drink just about anything"])
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
        
        resource_entries.listAppend(ChecklistEntryMake("__itemsize __monster Witchess Pawn", "campground.php?action=witchess", ChecklistSubentryMake(pluralise(fights_remaining, "witchess fight", "witchess fights"), "", description), 4));
    }
}