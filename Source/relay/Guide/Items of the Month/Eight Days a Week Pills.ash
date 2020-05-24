RegisterResourceGenerationFunction("IOTMEightDaysAWeekPillsGenerateResource");
void IOTMEightDaysAWeekPillsGenerateResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getPills() {
        // Title
        string main_title = "Take a pill";

        // Subtitle
        string subtitle = "First is Free!";
        if (get_property_boolean("_freePillKeeperUsed")) {
            subtitle = "-3 Spleen";
        }

        // Entries
        string [int] description;
        description.listAppend(HTMLGenerateSpanOfClass("Monday:", "r_bold") + " Yellow ray (30 turns)");
        description.listAppend(HTMLGenerateSpanOfClass("Tuesday:", "r_bold") + " Double potion length");
        description.listAppend(HTMLGenerateSpanOfClass("Wednesday:", "r_bold") + " Force Non-Combat");
        description.listAppend(HTMLGenerateSpanOfClass("Thursday:", "r_bold") + " +4 all res (30 turns)");
        description.listAppend(HTMLGenerateSpanOfClass("Friday:", "r_bold") + " +100% all stats (30 turns)");
        description.listAppend(HTMLGenerateSpanOfClass("Saturday:", "r_bold") + " Familiars 20 pounds (30 turns)");
        description.listAppend(HTMLGenerateSpanOfClass("Sunday:", "r_bold") + " Force semi-rare");
        description.listAppend(HTMLGenerateSpanOfClass("Funday:", "r_bold") + " Random adventures (30 turns)");

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupItem("Eight Days a Week Pill Keeper").have()) return;
    if (spleen_limit() - my_spleen_use() < 3) return; 
	
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Eight Days a Week Pill Keeper";
    entry.url = "main.php?eowkeeper=1";

    ChecklistSubentry pills = getPills();
    if (pills.entries.count() > 0) {
        entry.subentries.listAppend(pills);
    }
    
    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}