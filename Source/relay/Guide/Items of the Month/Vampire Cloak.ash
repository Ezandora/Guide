
RegisterResourceGenerationFunction("IOTMVampireCloakGenerateResource");
void IOTMVampireCloakGenerateResource(ChecklistEntry [int] resource_entries)
{
	if (!$item[vampyric cloake].have())
		return;
    if (!(__misc_state["in run"] && in_ronin())) return;
    
    int uses_left = clampi(10 - get_property_int("_vampyreCloakeFormUses"), 0, 10);
    if (uses_left > 0 && my_path_id() != PATH_POCKET_FAMILIARS)
	{
		string [int] skills;
        skills.listAppend("Wolf: +50% muscle, +50% meat");
        skills.listAppend("Mist: +2 all res");
        skills.listAppend("Bat: +50% item");
        
		string [int] description;
        description.listAppend("In-combat cast one of the Become skills, to gain a buff for that fight:|*" + skills.listJoinComponents("|*"));
        resource_entries.listAppend(ChecklistEntryMake("__item vampyric cloake", "", ChecklistSubentryMake(pluralise(uses_left, "vampyric skill use", "vampyric skill uses"), "", description), 5));
    }
}
