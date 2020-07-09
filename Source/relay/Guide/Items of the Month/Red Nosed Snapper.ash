RegisterResourceGenerationFunction("IOTMRedNosedSnapperResource");
void IOTMRedNosedSnapperResource(ChecklistEntry [int] resource_entries)
{
    ChecklistSubentry getPhylumRewards() {
        // Title
        string redSnapperPhylum = get_property("redSnapperPhylum");
        int redSnapperProgress = get_property_int("redSnapperProgress");
        string main_title = "Track monsters";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (redSnapperPhylum != "") {
            description.listAppend(HTMLGenerateSpanOfClass("Dudes:", "r_bold") + " Free banish item");
            description.listAppend(HTMLGenerateSpanOfClass("Goblins:", "r_bold") + " 3-size " + HTMLGenerateSpanOfClass("awesome", "r_element_awesome") + " food");
            description.listAppend(HTMLGenerateSpanOfClass("Orcs:", "r_bold") + " 3-size " + HTMLGenerateSpanOfClass("awesome", "r_element_awesome") + " booze");
            description.listAppend(HTMLGenerateSpanOfClass("Undead:", "r_bold") + " +5 " + HTMLGenerateSpanOfClass("spooky", "r_element_spooky") + " res potion");
            description.listAppend(HTMLGenerateSpanOfClass("Constellations:", "r_bold") + " Yellow ray");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupFamiliar("Red Nosed Snapper").familiar_is_usable()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__familiar red-nosed snapper";

    ChecklistSubentry rewards = getPhylumRewards();
    if (rewards.entries.count() > 0) {
        entry.subentries.listAppend(rewards);
    }

    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}

RegisterTaskGenerationFunction("IOTMRedNosedSnapperTask");
void IOTMRedNosedSnapperTask(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    ChecklistSubentry getChoosePhylum() {
        // Title
        string redSnapperPhylum = get_property("redSnapperPhylum");
        int redSnapperProgress = get_property_int("redSnapperProgress");
        string main_title = "Track monsters";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (redSnapperPhylum == "" && my_familiar() == $familiar[Red-Nosed Snapper]) {
            description.listAppend(HTMLGenerateSpanOfClass("Choose a phylum", "r_element_important"));
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

	if (!lookupFamiliar("Red Nosed Snapper").familiar_is_usable()) return;

    ChecklistEntry entry;
    entry.image_lookup_name = "__familiar red-nosed snapper";
    entry.importance_level = -10;

    ChecklistSubentry choosePhylum = getChoosePhylum();
    if (choosePhylum.entries.count() > 0) {
        entry.subentries.listAppend(choosePhylum);
    }

    if (entry.subentries.count() > 0) {
        task_entries.listAppend(entry);
    }
}

RegisterResourceGenerationFunction("IOTMHumanMuskBanish");
void IOTMHumanMuskBanish(ChecklistEntry [int] resource_entries) {
    ChecklistSubentry gerResource() {
        int humanMuskUses = get_property_int("_humanMuskUses");
        int humanMuskUsesLeft = MAX(0, 3 - humanMuskUses);
        int availableHumanMusks = MIN(humanMuskUsesLeft, $item[human musk].available_amount());

        // Title
        string main_title = availableHumanMusks + " human musks";

        // Subtitle
        string subtitle = "";

        // Entries
        string [int] description;
        if (availableHumanMusks > 0) {
            description.listAppend("Free run/banish. Consumes item.");
        }

        return ChecklistSubentryMake(main_title, subtitle, description);
    }

    ChecklistEntry entry;
    entry.ChecklistEntryTagEntry("banish");
    entry.image_lookup_name = "__item human musk";

    ChecklistSubentry resource = gerResource();
    if (resource.entries.count() > 0) {
        entry.subentries.listAppend(resource);
    }

    if (entry.subentries.count() > 0) {
        resource_entries.listAppend(entry);
    }
}