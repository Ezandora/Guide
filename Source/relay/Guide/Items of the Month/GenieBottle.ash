RegisterResourceGenerationFunction("IOTMGenieBottleGenerateResource");
void IOTMGenieBottleGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (lookupItem("genie bottle").item_amount() + lookupItem("pocket wish").item_amount() == 0) return;
    
    int wishes_left = 0;
    if (__misc_state["in run"])
        wishes_left += lookupItem("pocket wish").item_amount();
    if (lookupItem("genie bottle").item_amount() > 0 && mafiaIsPastRevision(18219))
        wishes_left += clampi(3 - get_property_int("_genieWishesUsed"), 0, 3);
    string [int] description;
    
    if (wishes_left > 0)
    {
        string url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9529";
        if (lookupItem("genie bottle").item_amount() == 0 || get_property_int("_genieWishesUsed") >= 3)
            url = "inv_use.php?pwd=" + my_hash() + "&whichitem=9537";
        description.listAppend("Could fight a monster:<br>" + SFaxGeneratePotentialFaxes(true, $monsters[ninja snowman assassin,modern zmobie,giant swarm of ghuol whelps]).listJoinComponents("<hr>"));
        resource_entries.listAppend(ChecklistEntryMake("__item genie bottle", url, ChecklistSubentryMake(pluralise(wishes_left, "wish", "wishes"), "", description), 1));
    }
}
