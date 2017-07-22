
import "relay/Guide/Support/Library 2.ash"

RegisterTaskGenerationFunction("IOTMAsdonMartinGenerateTasks");
void IOTMAsdonMartinGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (!__iotms_usable[lookupItem("Asdon martin keyfob")])
        return;
    //BanishIsActive
    //FIXME test get_fuel() in point release
    if (!BanishIsActive("Spring-Loaded Front Bumper") && __misc_state["in run"])
    {
        task_entries.listAppend(ChecklistEntryMake("__item Asdon Martin keyfob", "campground.php?action=fuelconvertor", ChecklistSubentryMake("Cast Spring-Loaded Front Bumper", "", "Banish/free run, costs 50 fuel."), -11));
    }
}

RegisterResourceGenerationFunction("IOTMAsdonMartinGenerateResource");
void IOTMAsdonMartinGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (!__iotms_usable[lookupItem("Asdon martin keyfob")])
        return;
    ChecklistEntry entry;
    entry.importance_level = 8;
    if (__misc_state["in run"])
    {
        item [int] fuelables = asdonMartinGenerateListOfFuelables();
        if (fuelables.count() > 0)
        {
            string [int] fuelables_extended;
            string [int] fuelables_extended_part_2;
            foreach key, fuelable in fuelables
            {
                string line;
                line = " (";
                line += fuelable.averageAdventuresForConsumable().round();
                if (fuelable.item_amount() == 0)
                {
                    line += ", ";
                    boolean first = true;
                    foreach it in fuelable.get_ingredients()
                    {
                        if (first)
                            first = false;
                        else
                            line += " + ";
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
                fuelables_extended.listAppend(HTMLGenerateSpanOfClass(HTMLGenerateTagWrap("span", fuelables_extended_part_2.listJoinComponents("<br>"), mapMake("class", "r_tooltip_inner_class", "style", "margin-top:-" + estimated_margin + "em;margin-left:-5em;")) + "Fuel list.", "r_tooltip_outer_class") + ($item[loaf of soda bread].creatable_amount() > 0 ? "|Or create and feed loaf of soda breads." : ""));
            }
            else if ($item[loaf of soda bread].creatable_amount() > 0)
                description.listAppend("Or create and feed loaf of soda breads.");
            //description.listAppend(HTMLGenerateSpanOfClass(HTMLGenerateTagWrap("span",HTMLGenerateSimpleTableLines(table, false), mapMake("class", "r_tooltip_inner_class", "style", "margin-top:-" + estimated_margin + "em;margin-left:-5em;")) + "Costs one spleen and two candies.", "r_tooltip_outer_class"));
            //description.listAppend("Could fuel with:|*" + fuelables_extended.listJoinComponents("|*", ""));
            description.listAppend(fuelables_extended.listJoinComponents("|*", ""));
            entry.subentries.listAppend(ChecklistSubentryMake("Fuel", "", description));
            if (entry.url == "")
                entry.url = "campground.php?action=fuelconvertor";
            if (entry.image_lookup_name == "")
                entry.image_lookup_name = "__item Asdon Martin keyfob";
        }
    }
    if (!get_property_boolean("_missileLauncherUsed"))
    {
        if (entry.image_lookup_name == "")
            entry.image_lookup_name = "__skill asdon martin: missile launcher";
        if (entry.url == "")
            entry.url = "campground.php?action=workshed";
        entry.subentries.listAppend(ChecklistSubentryMake("Asdon Missile", "", "Costs 100 fuel, instakill + YR-equivalent."));
    }
    if (entry.subentries.count() > 0)
    {
        resource_entries.listAppend(entry);
    }
}
