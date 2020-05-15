//Runtime variables:
location __last_adventure_location;


//Runtime call functions:

//Init functions happen after state and quest initialisation, so they can be referred to safely.
string [int] __init_functions;

void RegisterInitFunction(string function_name)
{
    __init_functions.listAppend(function_name);
}

string [int] __checklist_generation_function_names;

//Call function registration:
void RegisterChecklistGenerationFunction(string function_name)
{
    __checklist_generation_function_names.listAppend(function_name);
}

string [string][int] __specific_checklist_1_generation_function_names;
void RegisterSpecificChecklistGenerationFunction1(string function_name, string checklist_name_1)
{
    if (!(__specific_checklist_1_generation_function_names contains checklist_name_1)) {
        __specific_checklist_1_generation_function_names[checklist_name_1] = listMakeBlankString();
    }
    __specific_checklist_1_generation_function_names[checklist_name_1].listAppend(function_name);
}

Record ChecklistGenerationFunctionRequest
{
    string function_name;
    string [int] checklist_names;
};

void listAppend(ChecklistGenerationFunctionRequest [int] list, ChecklistGenerationFunctionRequest entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

ChecklistGenerationFunctionRequest [int] __specific_checklist_generation_requests;

void RegisterSpecificChecklistGenerationFunction3(string function_name, string checklist_name_1, string checklist_name_2, string checklist_name_3)
{
    ChecklistGenerationFunctionRequest request;
    request.function_name = function_name;
    //Hardcoded to match call structure:
    request.checklist_names[0] = checklist_name_1;
    request.checklist_names[1] = checklist_name_2;
    request.checklist_names[2] = checklist_name_3;
    __specific_checklist_generation_requests.listAppend(request);
}

void RegisterTaskGenerationFunction(string function_name) {
    RegisterSpecificChecklistGenerationFunction3(function_name, "Tasks", "Optional Tasks", "Future Tasks");
}

void RegisterResourceGenerationFunction(string function_name) {
    RegisterSpecificChecklistGenerationFunction1(function_name, "Resources");
}

void RegisterBannishGenerationFunction(string function_name) {
    RegisterSpecificChecklistGenerationFunction1(function_name, "Banishes");
}