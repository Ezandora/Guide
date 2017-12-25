//The idea behind this file was to allow modifier name -> effect mapping.
//But that's very difficult, because you need to parse string_modifier.
//And string modifier doesn't use numeric_modifier syntax. For instance, for Blue Swayed, it returns:
//Experience (familiar): [ceil(min(T,50)/5)], Familiar Weight: [ceil(min(T,50)/10)]
//Which means we need to convert that so I am giving up for now.

static
{
}
void initialiseModifiers()
{
	foreach e in $effects[]
	{
		string string_modifiers = e.string_modifier("Modifiers");
        if (string_modifiers == "") continue;
        string [int] first_level_split = string_modifiers.split_string(", ");
        
	}
}
initialiseModifiers();
