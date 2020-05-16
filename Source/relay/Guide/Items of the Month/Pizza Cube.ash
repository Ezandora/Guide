RegisterResourceGenerationFunction("IOTMPizzaCube");
void IOTMPizzaCube(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getQuestItems() {
        // Title
        string main_title = "Make Pizza";

        // Subtitle
        string subtitle = "Some ingredients give useful items";

        // Entries
        string [int] description;

        if (fullness_limit() - my_fullness() >= 3) {
            description.listAppend(HTMLGenerateSpanOfClass("cheese/milk:", "r_bold") + " 3 goat cheese");
            description.listAppend(HTMLGenerateSpanOfClass("lucky:", "r_bold") + " clover");
            description.listAppend(HTMLGenerateSpanOfClass("warlike:", "r_bold") + " 3 of sonar-in-a-biscuit, Duskwalker syringe, cocktail napkin, unnamed cocktail, cigarette lighter, glark cable, short writ of habeas corpus");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    ChecklistSubentry getBuffs() {
        // Title
        string main_title = "Buffs";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;

        if (fullness_limit() - my_fullness() >= 3) {
            description.listAppend("Get any wishable buff");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    if (!__iotms_usable[lookupItem("diabolic pizza cube")]) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__item diabolic pizza";
    entry.url = "campground.php?action=workshed";

    ChecklistSubentry questItems = getQuestItems();
    if (questItems.entries.count() > 0) {
        entry.subentries.listAppend(questItems);
    }

    ChecklistSubentry buffs = getBuffs();
    if (buffs.entries.count() > 0) {
        entry.subentries.listAppend(buffs);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}
