void SPlasticVampireFangsGenerateResource(ChecklistEntry [int] available_resources_entries)
{
    if ($items[plastic vampire fangs,Interview With You (a Vampire)].available_amount() == 0)
        return;
    item fang_source = $item[plastic vampire fangs];
    string url = "";
    string separator = " " + __html_right_arrow_character + " ";
    if ($item[plastic vampire fangs].available_amount() == 0)
    {
        fang_source = $item[Interview With You (a Vampire)];
            url = "inventory.php?which=3";
    }
    else
    {
        url = "town.php";
        if ($item[plastic vampire fangs].equipped_amount() == 0)
        {
            url = "inventory.php?which=2";
        }
    }
    
    if (!get_property_boolean("_interviewIsabella") && __misc_state["In run"] && __misc_state["need to level"])
    {
        string [int] description;
        int stats_gained = MIN(500, 4 * my_basestat(my_primestat())) * (1.0 + numeric_modifier(my_primestat().to_string() + " Experience Percent") / 100.0);
        
        description.listAppend(stats_gained + " " + my_primestat().to_lower_case() + " gained, one adventure cost.");
        if ($item[plastic vampire fangs].available_amount() == 0)
        {
            description.listAppend("Vamp out via Interview With You (a Vampire).");
        }
        else
        {
            if ($item[plastic vampire fangs].equipped_amount() == 0)
            {
                description.listAppend("Equip plastic vampire fangs, then vamp out in Seaside Town.");
            }
            else
                description.listAppend("Vamp out in Seaside Town.");
        }
        
        if (my_primestat() == $stat[muscle])
            description.listAppend("Visit Isabella's" + separator + "Drain Her.");
        else if (my_primestat() == $stat[mysticality])
            description.listAppend("Visit Isabella's" + separator + "Tell Her How You Feel" + separator + "Find Other Prey.");
        else if (my_primestat() == $stat[moxie])
            description.listAppend("Visit Isabella's" + separator + "Redirect Your Desire" + separator + "Go to the Bar.");
        
        
        available_resources_entries.listAppend(ChecklistEntryMake("__item " + fang_source, url, ChecklistSubentryMake("Vampire stats", "", description), 5));
        
    }

    if (!__misc_state["In run"])
    {
        string [int] description;
        if ($item[plastic vampire fangs].available_amount() == 0)
        {
            description.listAppend("Vamp out via Interview With You (a Vampire).");
        }
        else
        {
            if ($item[plastic vampire fangs].equipped_amount() == 0)
            {
                description.listAppend("Equip plastic vampire fangs, then vamp out in Seaside Town.");
            }
            else
                description.listAppend("Vamp out in Seaside Town.");
        }
        
        int vamp_outs_remaining = 0;
        
        //Disabled, unless there's something useful about these to be reminded of in aftercore:
        /*if (!get_property_boolean("_interviewVlad"))
        {
            description.listAppend("Vlad's Boutique - DR or spell damage or weapon damage buff.");
            vamp_outs_remaining += 1;
        }
        if (!get_property_boolean("_interviewIsabella"))
        {
            description.listAppend("Isabella's - mainstat gain, meat.");
            vamp_outs_remaining += 1;
        }*/
        if (!get_property_boolean("_interviewMasquerade"))
        {
            string [int] masquerade_description;
            if ($item[Sword of the Brouhaha Prince].available_amount() == 0)
            {
                string [int] interview_questions = listMake("Warehouse", "Growl", "The Clash", "Motorcycle", "Lager");
                string [int] nomination = listMake("Malkovich", "Torremolinos", "Brouhaha", "Ventrilo");
                string item_name = "Sword of the Brouhaha Prince";
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            if ($item[Chalice of the Malkovich Prince].available_amount() == 0)
            {
                string [int] interview_questions = listMake("Laugh Factory", "Giggle", "Glass breaking", "Wheelbarrow", "Blood");
                string [int] nomination = listMake("Torremolinos", "Ventrilo", "Brouhaha", "Malkovich");
                string item_name = "Chalice of the Malkovich Prince";
                
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            if ($item[Sceptre of the Torremolinos Prince].available_amount() == 0)
            {
                string [int] interview_questions = listMake("Loft", "Flirty", "Mozart", "Carriage", "Absinthe");
                string [int] nomination = listMake("Malkovich", "Ventrilo", "Torremolinos", "Brouhaha");
                string item_name = "Sceptre of the Torremolinos Prince";
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            if ($item[Medallion of the Ventrilo Prince].available_amount() == 0)
            {
                string [int] interview_questions = listMake("Penthouse", "Terse", "No time", "Limo", "Espresso");
                string [int] nomination = listMake("Ventrilo", "Malkovich", "Brouhaha", "Torremolinos");
                string item_name = "Medallion of the Ventrilo Prince";
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            if (true)
            {
                string [int] interview_questions = listMake("Warehouse", "Growl", "The Clash", "Motorcycle", "Lager");
                string [int] nomination = listMake("Ventrilo", "Brouhaha", "Torremolinos", "Malkovich");
                string item_name = "Your own black heart (restores 100% HP/MP)";
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            if ($item[plastic vampire fangs].available_amount() > 0)
            {
                string [int] interview_questions = listMake("Warehouse", "Growl", "The Clash", "Motorcycle", "Lager");
                string [int] nomination = listMake("Ventrilo", "Malkovich", "Torremolinos", "Brouhaha");
                string item_name = "Interview With You (a Vampire)";
                masquerade_description.listAppend(item_name + "|*Interview: " + interview_questions.listJoinComponents(separator) + "<hr>|*Nomination order: " + nomination.listJoinComponents(separator));
            }
            //description.listAppend("The Masquerade." + HTMLGenerateIndentedText(masquerade_description));
            description.listAppendList(masquerade_description);
            vamp_outs_remaining += 1;
        }
        
        if (vamp_outs_remaining > 0)
        {
            //available_resources_entries.listAppend(ChecklistEntryMake("__item " + fang_source, url, ChecklistSubentryMake(pluralize(vamp_outs_remaining, "vamp out", "vamp outs"), "", description), 8));
            available_resources_entries.listAppend(ChecklistEntryMake("__item " + fang_source, url, ChecklistSubentryMake("Vampire masquerade", "", description), 8));
        }
    }
}