
RegisterResourceGenerationFunction("IOTMLatteGenerateResource");
void IOTMLatteGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (lookupItem("latte lovers member's mug").available_amount() == 0) return;
	
	int refills_remaining = clampi(3 - get_property_int("_latteRefillsUsed"), 0, 3);
	boolean banish_used = get_property_boolean("_latteBanishUsed");
	boolean copy_used = get_property_boolean("_latteCopyUsed"); //more of an olfact than a copy
	boolean drink_used = get_property_boolean("_latteDrinkUsed");
	
	int banishes_available = refills_remaining + (!banish_used ? 1 : 0);
    int copies_available = refills_remaining + (!copy_used ? 1 : 0);
    
    string url;
    boolean latte_needs_equipping = false;
    if (lookupItem("latte lovers member's mug").equipped_amount() == 0)
    {
    	url = "inventory.php?which=2";
        latte_needs_equipping = true;
    }
    if (banishes_available > 0)
    {
    	string banish_url = url;
    	string [int] description;
     	description.listAppend("Free run/banish." + (latte_needs_equipping ? " Equip latte first." : "") + "|Throw Latte on Opponent in combat.");
         
        if (banish_used)
        {
        	banish_url = "main.php?latte=1";
        	description.listAppend(HTMLGenerateSpanFont("Must refill latte first.", "red"));
        }
        resource_entries.listAppend(ChecklistEntryMake("__item latte lovers member's mug", banish_url, ChecklistSubentryMake(pluralise(banishes_available, "latte banish", "latte banishes"), "", description), 0).ChecklistEntryTagEntry("banish"));
    }
    
    ChecklistEntry entry;
    entry.image_lookup_name = "__item latte lovers member's mug";
    entry.url = "main.php?latte=1";
    
    if (refills_remaining > 0)
    {
        string [int] description;
        if (!banish_used && __misc_state["in run"])
            description.listAppend(HTMLGenerateSpanFont("Use banish first.", "red"));
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(refills_remaining, "latte refill", "latte refills"), "", description));
    }
    if (copies_available > 0)
    {
        string [int] description;
        description.listAppend("Offer Latte to Opponent in combat.");
        if (copy_used)
        {
            description.listAppend(HTMLGenerateSpanFont("Must refill latte first.", "red"));
        }
        if ($skill[Transcendent Olfaction].have_skill())
        	description.listAppend("Stack with Transcendent Olfaction.");
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(copies_available, "latte olfaction", "latte olfactions"), "", description));
    }
    if (!drink_used)
    {
        entry.subentries.listAppend(ChecklistSubentryMake("Gulp Latte available", "", "Restores half your HP and MP. Cast in combat."));
    }
    if (entry.subentries.count() > 0)
    	resource_entries.listAppend(entry);
}
