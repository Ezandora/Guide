
RegisterGenerationFunction("IOTMBackupCameraGenerate");
void IOTMBackupCameraGenerate(ChecklistCollection checklists)
{
	item camera = lookupItem("backup camera");
	if (!camera.have()) return;
	
    
    int times_backed_up = get_property_int("_backUpUses");
    int backup_limit = 11;
    if (my_path_id_legacy() == PATH_ROBOT) //from reports
    	backup_limit = 16;
    int backups_left = MAX(0, backup_limit - times_backed_up);
    if (backups_left > 0)
    {
		string [int] description;
        string url = "";
        
        monster lm = last_monster();
        string last_monster_description = lm;
        if (lm == $monster[none] || !lm.monsterCanBeCopied())
        	last_monster_description = "a monster";
        
        
        description.listAppend("Fight " + last_monster_description + " in another zone.|Burns delay.");
        description.listAppend("In combat, cast Back-Up to your Last Enemy.");
        
        
        if (!camera.equipped())
        {
            url = "inventory.php?which=2&ftext=backup+camera";
            description.listAppend("Equip the backup camera first.");
        }
        string title = pluralise(backups_left, "camera backup", "camera backups");
    	checklists.add(C_RESOURCES, ChecklistEntryMake(616, "__item backup camera", url, ChecklistSubentryMake(title, "", description), 1)).ChecklistEntryTag("backup camera").ChecklistEntrySetAbridgedHeader(title);
    }
	
	if (true)
	{
		string [int] description;
        string url = "";
        if (!camera.equipped())
            url = "inventory.php?which=2&ftext=backup+camera";
        else
        	url = "inventory.php?which=2";
            
        string camera_mode = get_property("backupCameraMode"); //meat,
        
        string [string] camera_mode_descriptions =
        {
        	"meat":"+50% meat",
            "init":"+100% init",
            "ml":"+" + min(50, my_level() * 3) + " ML",
        };
        
        
        if (camera_mode_descriptions contains camera_mode)
        	description.listAppend(camera_mode_descriptions[camera_mode] + " enchantment.");
         
        string [int] other_options;
        foreach mode_name, mode_description in camera_mode_descriptions
        {
        	if (mode_name == camera_mode) continue;
            other_options.listAppend(mode_description);
        }
        description.listAppend("Could switch to " + other_options.listJoinComponents(", ", "or") + ".");
        
        if (!get_property_boolean("backupCameraReverserEnabled"))
        	description.listAppend("You may want to enable the reverser in the mode settings.");
        
        checklists.add(C_RESOURCES, ChecklistEntryMake(617, "__item backup camera", url, ChecklistSubentryMake("Backup Camera", "", description), 1)).ChecklistEntryTag("backup camera");
    }
    
}
