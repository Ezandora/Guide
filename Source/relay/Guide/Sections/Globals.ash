//Runtime variables:
location __last_adventure_location;


//Runtime call functions:
string [int] __checklist_generation_function_names;

//Call function registration:
void RegisterChecklistGenerationFunction(string function_name)
{
    __checklist_generation_function_names.listAppend(function_name);
}