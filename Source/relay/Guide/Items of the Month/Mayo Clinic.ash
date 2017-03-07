RegisterResourceGenerationFunction("IOTMMayoClinicGenerateResource");
void IOTMMayoClinicGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (__misc_state["campground unavailable"])
        return;
    if (get_campground()[$item[portable Mayo Clinic]] == 0 || in_bad_moon())
        return;
    
    //mayoLevel
    int mayo_level = get_property_int("mayoLevel");
    
    if (availableFullness() > 0)
    {
        //stuff:
        //Mayonex - food adventures -> blood mayo (???)
        //Mayodiol -> one fullness becomes one drunkenness
        //Mayostat -> one-fullness same quality restore
        //Mayozapine -> increased stat gains
        //Mayoflex -> +1 adventure
        //Mayo Minder™ -> um... I guess it uses the above things for you. reminds me of buying the autorefueler in EV..
    }
    
    if (!get_property_boolean("_mayoDeviceRented"))
    {
        string [int] description;
        //sphygmayomanometer - +(20 + mayo_level)% stats
        //tomayohawk-style reflex hammer - reusable combat item. stagger, mayo-level sleaze damage
        //mayo lance - YR combat item, requires at least one blood mayo
        //miracle whip - nice day two/three equip. +50% init, +50% item, +100% meat, +100% wait, I only get one of these a run?
        
        string line = "Lasts the rest of the day. Can only choose one.";
        if (my_meat() < 2500)
            line += "|Need at least 2500 meat first.";
        description.listAppend(line);
        
        string [int][int] choices;
        
        choices.listAppend(listMake("Sphygmayomanometer", "+" + (20 + mayo_level) + "% all stats"));
        choices.listAppend(listMake("Tomayohawk-style reflex hammer", "Reusable combat item.|Staggers and deals mayo-level sleaze damage."));
        string lance_description = "Yellow ray. ";
        if (__misc_state["yellow ray available"])
            lance_description = "Shorter yellow ray. ";
        lance_description += HTMLGenerateDivOfClass("Uses up blood mayo.", "r_word_wrap_group");
        choices.listAppend(listMake("Mayo lance", lance_description));
        
        if (!get_property_boolean("mayoWhipRented") && !get_property_boolean("itemBoughtPerAscension8266") &&  my_path_id() != PATH_GELATINOUS_NOOB)
        {
            choices.listAppend(listMake("Miracle whip", "Weapon, usable " + HTMLGenerateSpanFont("once", "red") + " per run.|+50% item, +100% meat, +50% init."));
        }
        description.listAppend(HTMLGenerateSimpleTableLines(choices));
        resource_entries.listAppend(ChecklistEntryMake("__item sphygmayomanometer", "campground.php?action=workshed", ChecklistSubentryMake("Mayo Device Rental", "", description), 8));
    }
    if (!get_property_boolean("_mayoTankSoaked") && __misc_state["in run"])
    {
        string [int] description;
        string [int] benefits;
        if (my_path_id() != PATH_ACTUALLY_ED_THE_UNDYING)
            benefits.listAppend("HP restore");
        benefits.listAppend("+2 all resistance");
        description.listAppend("Gives " + benefits.listJoinComponents(", ", "and") + ".");
        resource_entries.listAppend(ChecklistEntryMake("__item bubblin' chemistry solution", "campground.php?action=workshed", ChecklistSubentryMake("Mayo Tank Soak", "", description), 8));
    }
    if ($item[mayo lance].available_amount() > 0)
    {
        string url = "";
        string [int] description;
        int turns_yellow_ray_will_be = clampi(150 - get_property_int("mayoLevel") * 5, 0, 150);
        if (get_property_int("mayoLevel") == 0)
        {
            string line = "Need blood mayo to yellow ray";
            if ($effect[everything looks yellow].have_effect() > 0)
                line += " later";
            line += ".";
            if (get_property("mayoInMouth") == "")
                line += "|Use a mayo packet.";
            description.listAppend(line);
            if (availableFullness() > 0)
                url = "campground.php?action=workshed";
        }
        else
        {
            string line = pluralise(turns_yellow_ray_will_be, "turn", "turns") + " yellow ray";
            if ($effect[everything looks yellow].have_effect() > 0)
                line += " later";
            line += ". Affected by mayo level.";
            description.listAppend(line);
        }
        resource_entries.listAppend(ChecklistEntryMake("__item mayo lance", url, ChecklistSubentryMake("Mayo lance", "", description), 8));
        
    }
}