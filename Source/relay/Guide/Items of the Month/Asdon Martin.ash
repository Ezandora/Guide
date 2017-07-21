
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
    if (__misc_state["in run"])
    {
        item [int] fuelables = asdonMartinGenerateListOfFuelables();
        if (fuelables.count() > 0)
        {
            string [int] fuelables_extended;
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
                fuelables_extended.listAppend(line);
                if (key >= 5 && true)
                {
                    fuelables_extended.listAppend("(...)");
                    break;
                }
            }
            string [int] description;
            description.listAppend("Could fuel with:|*" + fuelables_extended.listJoinComponents("|*", ""));//|Total of " + total_fuelable + " fuelable.");
            if ($item[loaf of soda bread].creatable_amount() > 0)
                description.listAppend("Or create and feed loaf of soda breads.");
            resource_entries.listAppend(ChecklistEntryMake("__item Asdon Martin keyfob", "campground.php?action=fuelconvertor", ChecklistSubentryMake("Fuel", "", description), 8));
        }
    }
}
