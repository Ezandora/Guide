
RegisterResourceGenerationFunction("IOTMSaberGenerateResource");
void IOTMSaberGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (lookupItem("Fourth of May Cosplay Saber").available_amount() == 0) return;
	
    string saber_monster = get_property("_saberForceMonster");
    // Check count later
    int saber_monsterCount = clampi(get_property_int("_saberForceMonsterCount"), 0, 3);
	int saber_force_uses_remaining = clampi(5 - get_property_int("_saberForceUses"), 0, 5);
	int saber_mod_remaining = clampi(1 - get_property_int("_saberMod"), 0, 1);
    
    string url;
    boolean saber_needs_equipping = false;
    if (lookupItem("Fourth of May Cosplay Saber").equipped_amount() == 0)
    {
    	url = "inventory.php?which=2";
        saber_needs_equipping = true;
    }
    
    ChecklistEntry entry;
    entry.image_lookup_name = "__item Fourth of May Cosplay Saber";
    entry.url = "main.php?action=may4";
    

    // Force banish use
    if (saber_force_uses_remaining > 0)
    {
    	string banish_url = url;
    	string [int] description;
     	description.listAppend("Free run/banish." + "|Use the Force, " + my_name().HTMLEscapeString() + "! in combat.");
        
        if (saber_needs_equipping)
        {
            description.listAppend("Equip the Fourth of May Cosplay Saber first.");
        }
        
        resource_entries.listAppend(ChecklistEntryMake("__item Fourth of May Cosplay Saber", banish_url, ChecklistSubentryMake(pluralise(saber_force_uses_remaining, "saber banish", "saber banishes"), "", description), 0).ChecklistEntryTagEntry("banish"));
    }
    
    // Saber upgradable
    if(saber_mod_remaining > 0)
    {

        string [int] description;
        description.listAppend("Saber can be upgraded for +15-20 mp regen, +20 ml, +3 all res, or +10 fam weight.");
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(saber_mod_remaining, "saber upgrade", "saber upgrades"), "", description));
    }
   
    
    // Saber pseudo copies
    if (saber_force_uses_remaining > 0)
    {
        string [int] description;
        description.listAppend("Use the Force, " + my_name().HTMLEscapeString() + "! in combat.");
        
        description.listAppend("Forces monster to appear in next three adventures in zone where monster exists.");
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(saber_force_uses_remaining, "saber force copy", "saber force copies"), "", description));
    }
    
    // Saber current copy
    if (saber_monster != "" && saber_monsterCount != 0)
    {
        string [int] description;
        // Add zone where monster comes from
        description.listAppend("Monster will appear " + pluralise(saber_monsterCount, "more time", "more times"));
        
        entry.subentries.listAppend(ChecklistSubentryMake("Current monster is " + saber_monster, description));

        
    }
    
    // Saber yellow ray (without cooldown)
    if (saber_force_uses_remaining > 0)
    {
        
        string [int] description;
        description.listAppend("Use the Force, " + my_name().HTMLEscapeString() + "! in combat.");
        
        description.listAppend("Force all non-conditional items to drop from monster. Does not count as combat victory.");
        entry.subentries.listAppend(ChecklistSubentryMake(pluralise(saber_force_uses_remaining, "saber force pseudo YR", "saber force pseudo YRs"), "", description));
  
    }
    
    if (entry.subentries.count() > 0)
    	resource_entries.listAppend(entry);
}