import "relay/Guide/Support/Holiday.ash";

void SHolidayGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    boolean [string] todays_holidays = getHolidaysToday();
    boolean [string] all_tomorrows_parties = getHolidaysTomorrow();
    
    if (todays_holidays["Halloween"])
    {
        if (__misc_state["in run"])
        {
            string [int] description;
            description.listAppend("Free stats/items from monsters on the first block.");
            if (knoll_available() && !have_outfit_components("Filthy Hippy Disguise"))
            {
                item [int] missing_components = missing_outfit_components("Bugbear Costume");
                if (missing_components.count() > 0)
                    description.listAppend("If you need an outfit, buy a " + missing_components.listJoinComponents(", ", "and") + " from the knoll.");
            }
            optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "place.php?whichplace=town&action=town_trickortreat", ChecklistSubentryMake("Trick or treat for one block", "+" + my_primestat().to_lower_case(), description), $locations[trick-or-treating]));
        }
        else
        {
            string [int] description;
            description.listAppend("Wear an outfit, go from house to house.");
            description.listAppend("Remember you can trick-or-treat while drunk.");
            optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "place.php?whichplace=town&action=town_trickortreat", ChecklistSubentryMake("Trick or treat", "", description), $locations[trick-or-treating]));
        }
    }
    if (all_tomorrows_parties["Halloween"] && !__misc_state["in run"])
        optional_task_entries.listAppend(ChecklistEntryMake("__item plastic pumpkin bucket", "", ChecklistSubentryMake("Save turns for Halloween tomorrow", "", ""), 8));
    
    if (todays_holidays["Arrrbor Day"])
    {
        string [int] description;
        boolean [item] outfit_pieces_needed;
        foreach it in $items[crotchety pants,Saccharine Maple pendant,willowy bonnet]
        {
            if (!it.haveAtLeastXOfItemEverywhere(1))
                outfit_pieces_needed[it] = true;
        }
        //FIXME detect collecting reward?
        if ($items[bag of Crotchety Pine saplings,bag of Saccharine Maple saplings,bag of Laughing Willow saplings].available_amount() == 0)
        {
            description.listAppend("Choose a sapling type.");
            string [int] suggestions;
            if (outfit_pieces_needed[$item[crotchety pants]])
                suggestions.listAppend("Crotchety Pine");
            if (outfit_pieces_needed[$item[Saccharine Maple pendant]])
                suggestions.listAppend("Saccharine Maple");
            if (outfit_pieces_needed[$item[willowy bonnet]])
                suggestions.listAppend("Laughing Willow");
            if (suggestions.count() > 0)
                description.listAppend("Could try " + suggestions.listJoinComponents(", ", "or") + " for the reward item" + (suggestions.count() > 1 ? "s" : "") + ".");
        }
        else
        {
            item [int] bag_types;
            boolean have_a_bag_equipped = false;
            foreach it in $items[bag of Crotchety Pine saplings,bag of Saccharine Maple saplings,bag of Laughing Willow saplings]
            {
                if (it.available_amount() > 0)
                    bag_types.listAppend(it);
                if (it.equipped_amount() > 0)
                    have_a_bag_equipped = true;
            }
            if (!have_a_bag_equipped)
            {
                description.listAppend("Equip your " + bag_types.listJoinComponents(", ", "or") + ".");
            }
            else if (outfit_pieces_needed.count() > 0)
            {
                description.listAppend("Adventure for at least one hundred adventures to collect the outfit piece next holiday.");
            }
            else
            {
                description.listAppend("Adventure for at least two adventures to collect the potion reward next holiday.");
            }
        }
        optional_task_entries.listAppend(ChecklistEntryMake("__item spooky sapling", "place.php?whichplace=woods", ChecklistSubentryMake("Plant trees", "", description), 8, $locations[The Arrrboretum]));
    }
}