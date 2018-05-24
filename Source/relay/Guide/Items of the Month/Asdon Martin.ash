
import "relay/Guide/Support/Library 2.ash"
import "relay/Guide/Support/Ingredients.ash"

RegisterTaskGenerationFunction("IOTMAsdonMartinGenerateTasks");
void IOTMAsdonMartinGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[lookupItem("Asdon martin keyfob")])
        return;
    //BanishIsActive
    //FIXME test get_fuel() in point release
    if (!BanishIsActive("Spring-Loaded Front Bumper") && __misc_state["in run"] && (my_path_id() != PATH_POCKET_FAMILIARS || (__iotms_usable[$item[source terminal]] && __iotms_usable[lookupItem("FantasyRealm membership packet")])))
    {
    	string description = "Banish" + (__misc_state["free runs usable"] ? "/free run" : "") + ", ";
     
     	string fuel = "costs 50 fuel.";
     	if (get_fuel() < 50)
        {
        	description += HTMLGenerateSpanFont(fuel, "red");
         	description += "|" + HTMLGenerateSpanFont("Fuel up to 50 first.", "red");   
        }
        else
            description += fuel;
		if (my_path_id() == PATH_POCKET_FAMILIARS)
			description += "|In FantasyRealm, where you can extract for consumables.";
        task_entries.listAppend(ChecklistEntryMake("__item Asdon Martin keyfob", "campground.php?action=fuelconvertor", ChecklistSubentryMake("Cast Spring-Loaded Front Bumper", "", description), -11));
    }
}

RegisterResourceGenerationFunction("IOTMAsdonMartinGenerateResource");
void IOTMAsdonMartinGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[lookupItem("Asdon martin keyfob")])
        return;
    ChecklistEntry entry;
    entry.importance_level = 0;
    if (__misc_state["in run"])
    {
        item [int] fuelables = asdonMartinGenerateListOfFuelables();
        if (fuelables.count() > 0)
        {
            string [int] fuelables_extended;
            string [int] fuelables_extended_part_2;
            foreach key, fuelable in fuelables
            {
                int creatable_amount = fuelable.creatable_amount();
                string line;
                line = " (";
                line += (fuelable.averageAdventuresForConsumable() * (creatable_amount + fuelable.item_amount())).round();
                if (fuelable.item_amount() == 0)
                {
                    if (fuelable.craft_type() == "Summon Clip Art") continue;
                    line += ", ";
                    boolean first = true;
                    foreach it, amount in fuelable.get_ingredients_fast()
                    {
                        if (first)
                            first = false;
                        else
                            line += " + ";
                        if (amount > 1)
                            line += amount + " ";
                        line += it;
                    }
                }
                line += ")";
                line = fuelable.to_string() + HTMLGenerateSpanOfClass(line, "r_cl_modifier_inline");
                
                string desired_colour = "";
                if (fuelable.quality == "EPIC")
                    desired_colour = "blueviolet";
                else if (fuelable.quality == "awesome")
                    desired_colour = "blue";
                else if (fuelable.quality == "good")
                    desired_colour = "green";
                else if (fuelable.quality == "crappy")
                    desired_colour = "#999999";
                boolean cannot_consume_anyways = false;
                if (!__misc_state["can eat just about anything"] && fuelable.fullness > 0)
                    cannot_consume_anyways = true;
                if (!__misc_state["can drink just about anything"] && fuelable.inebriety > 0 && !(my_path_id() == PATH_LICENSE_TO_ADVENTURE && fuelable.image == "martini.gif"))
                    cannot_consume_anyways = true;
                if (!fuelable.is_unrestricted())
                    cannot_consume_anyways = true;
                if (cannot_consume_anyways)
                    desired_colour = "#999999";
                if (desired_colour != "")
                    line = HTMLGenerateSpanFont(line, desired_colour);
                if (key >= 0 && true)
                {
                    fuelables_extended_part_2.listAppend(line);
                    //break;
                }
                else
                    fuelables_extended.listAppend(line);
            }
            string [int] description;
            if (fuelables_extended_part_2.count() > 0)
            {
                //fuelables_extended.listAppend("(...)");
                int estimated_margin = fuelables_extended_part_2.count() * 1.2;
                fuelables_extended.listAppend(HTMLGenerateSpanOfClass(HTMLGenerateTagWrap("span", fuelables_extended_part_2.listJoinComponents("<br>"), mapMake("class", "r_tooltip_inner_class r_tooltip_inner_class_margin", "style", "margin-top:-" + estimated_margin + "em;margin-left:-5em;")) + "Fuel list.", "r_tooltip_outer_class") + ($item[loaf of soda bread].creatable_amount() > 0 ? "|Or create and feed loaf of soda breads." : ""));
            }
            else if ($item[loaf of soda bread].creatable_amount() > 0)
                description.listAppend("Or create and feed loaf of soda breads.");
            //description.listAppend(HTMLGenerateSpanOfClass(HTMLGenerateTagWrap("span",HTMLGenerateSimpleTableLines(table, false), mapMake("class", "r_tooltip_inner_class  r_tooltip_inner_class_margin", "style", "margin-top:-" + estimated_margin + "em;margin-left:-5em;")) + "Costs one spleen and two candies.", "r_tooltip_outer_class"));
            //description.listAppend("Could fuel with:|*" + fuelables_extended.listJoinComponents("|*", ""));
            description.listAppend(fuelables_extended.listJoinComponents("|*", ""));
            entry.subentries.listAppend(ChecklistSubentryMake(get_fuel() + " Fuel", "", description));
            if (entry.url == "")
                entry.url = "campground.php?action=fuelconvertor";
            if (entry.image_lookup_name == "")
                entry.image_lookup_name = "__item Asdon Martin keyfob";
        }
    }
    if (!get_property_boolean("_missileLauncherUsed") && my_path_id() != PATH_POCKET_FAMILIARS && my_path_id() != PATH_G_LOVER)
    {
        if (entry.image_lookup_name == "")
            entry.image_lookup_name = "__skill asdon martin: missile launcher";
        if (entry.url == "")
            entry.url = "campground.php?action=workshed";
        entry.subentries.listAppend(ChecklistSubentryMake("Asdon Missile", "", "Costs 100 fuel, instakill + YR-equivalent."));
    }
    if (BanishIsActive("Spring-Loaded Front Bumper"))
    {
        Banish b = BanishByName("Spring-Loaded Front Bumper");
        int turns_left = b.banish_turn_length - (my_turncount() - b.turn_banished);
        
        if (turns_left > 0 && turns_left <= 30)
        {
            entry.subentries.listAppend(ChecklistSubentryMake(pluralise(turns_left, "turn", "turns") + " to next asdon bumper", "", "Banish/runaway."));
            if (entry.image_lookup_name == "")
                entry.image_lookup_name = "__item Asdon Martin keyfob";
        }
        if (entry.url == "")
            entry.url = "campground.php?action=workshed";
    }
    if (entry.subentries.count() > 0)
    {
        resource_entries.listAppend(entry);
    }
}
