RegisterResourceGenerationFunction("PathNuclearAutumnGenerateResource");
void PathNuclearAutumnGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (my_path_id() != PATH_NUCLEAR_AUTUMN)
		return;
    
    item rad = lookupItem("rad");
    if (rad.available_amount() > 0)
    {
        string [int] description;
		resource_entries.listAppend(ChecklistEntryMake("__item rad", "shop.php?whichshop=mutate", ChecklistSubentryMake(pluralise(rad) + " available", "", description), 8));
    }
}