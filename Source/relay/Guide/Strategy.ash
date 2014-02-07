void generateStrategy(Checklist [int] checklists)
{
	ChecklistEntry [int] entries;
    
    if (!__misc_state["In run"])
        return;
    
    
    //What familiar to run. spleen items
    //Turn generation.
    //How to handle combat.
    //How to restore HP.
    //Where to get MP...?
    
    
	checklists.listAppend(ChecklistMake("Strategy", entries));
}