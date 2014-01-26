import "relay/Guide/Support/Library.ash"
import "relay/Guide/QuestLog.ash"

//Quest status stores all/most of our quest information in an internal format that's easier to understand.
record QuestState
{
	string quest_name;
	string image_name;
	
	boolean startable; //can be started, but hasn't yet
	boolean started;
	boolean in_progress;
	boolean finished;
	
	int mafia_internal_step; //0 for not started. INT32_MAX for finished. This is +1 versus mafia's "step1/step2/stepX" system. "step1" is represented as 2, "step2" as 3, etc.
	
	boolean [string] state_boolean;
	string [string] state_string;
	int [string] state_int;
	float [string] state_float;
	
	boolean council_quest;
};

QuestState [string] __quest_state;
boolean [string] __misc_state;
string [string] __misc_state_string;
int [string] __misc_state_int;
float [string] __misc_state_float;

boolean safeToLoadQuestLog()
{
    int current_time = getMillisecondsOfToday();
    int last_reloaded_time = get_property_int("__relay_guide_last_quest_log_reload_time");
    int minimum_time_between_quest_log_reloads = 10000; //ten seconds, seems reasonable
    if (abs(current_time - last_reloaded_time) < minimum_time_between_quest_log_reloads)
        return false;
    return true;
}

string shrinkQuestLog(string html)
{
    int body_position = html.index_of("<body>");
    if (body_position != -1)
        return html.substring(body_position);
    return html;
}

boolean __loaded_quest_log = false;
void requestQuestLogLoad(string property_name)
{
    if (true) //disabled, remove later
        return;
    if (__loaded_quest_log)
        return;
    
    boolean [string] whitelist = $strings[questF01Primordial,questF02Hyboria,questF03Future,questI02Beat];
    //questF01Primordial questF02Hyboria questF03Future - minor tracking
    //questG02Whitecastle - tracked, but updates only started, finished, step1, step5?
    //questG03Ego - tracked, but not updated
    //questG04Nemesis questG05Dark - minor tracking
    //questI02Beat - need to know professor jacking being defeated
    
    if (!(whitelist contains property_name))
        return;
    
    __loaded_quest_log = true;
    
    
    
    boolean safe_to_load_again = safeToLoadQuestLog();
    int current_time = getMillisecondsOfToday();
    
    //Rate limit:
    //A load of both quest logs can be around 9 KiB, or less.
    //That's quite a bit of data. So, we want to prevent requesting this too much.
    //We rate limit - quest log loads can only happen every ten seconds.
    //We have a javascript mechanism in place to reload at a later time, if we skip the check. This insures stale data won't be visible beyond the limit interval.
    
    
    if (safe_to_load_again)
    {
        boolean stale = false;
        string quest_log_2 = "";//visit_url("questlog.php?which=2");
        string quest_log_1 = "";//visit_url("questlog.php?which=1");
        if (quest_log_2.contains_text("Your Quest Log"))
            set_property("__relay_guide_last_quest_log_2", shrinkQuestLog(quest_log_2));
        else
            stale = true;
        if (quest_log_1.contains_text("Your Quest Log"))
            set_property("__relay_guide_last_quest_log_1", shrinkQuestLog(quest_log_1));
        else
            stale = true;
        set_property("__relay_guide_last_quest_log_reload_time", current_time.to_string());
        set_property("__relay_guide_stale_quest_data", stale.to_string());
    }
    else
    {
        set_property("__relay_guide_stale_quest_data", true.to_string());
    }
}

int QuestStateConvertQuestPropertyValueToNumber(string property_value)
{
	int result = 0;
	if (property_value == "")
		return -1;
	if (property_value == "started")
	{
		result = 1;
	}
	else if (property_value == "finished")
	{
		result = INT32_MAX;
	}
	else if (property_value.contains_text("step"))
	{
		//let's see...
		//lazy:
		string theoretical_int = property_value.replace_string("step", "");
		int step_value = theoretical_int.to_int_silent();
		
		result = step_value + 1;
		
		if (result < 0)
			result = 0;
	}
	else
	{
		//unknown
	}
	return result;
}


void QuestStateParseMafiaQuestPropertyValue(QuestState state, string property_value)
{
	state.started = false;
	state.finished = false;
    state.in_progress = false;
	state.mafia_internal_step = QuestStateConvertQuestPropertyValueToNumber(property_value);
	
	if (state.mafia_internal_step > 0)
		state.started = true;
	if (state.mafia_internal_step == INT32_MAX)
		state.finished = true;
	if (state.started && !state.finished)
		state.in_progress = true;
}

boolean QuestStateEquals(QuestState q1, QuestState q2)
{
	//not sure how to do record equality otherwise
	if (q1.quest_name != q2.quest_name)
		return false;
	if (q1.image_name != q2.image_name)
		return false;
	if (q1.startable != q2.startable)
		return false;
	if (q1.started != q2.started)
		return false;
	if (q1.in_progress != q2.in_progress)
		return false;
	if (q1.finished != q2.finished)
		return false;
	if (q1.mafia_internal_step != q2.mafia_internal_step)
		return false;
		
	if (q1.state_boolean != q2.state_boolean)
		return false;
	if (q1.state_string != q2.state_string)
		return false;
	if (q1.state_int != q2.state_int)
		return false;
	return true;
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name, boolean allow_quest_log_load)
{
	state.QuestStateParseMafiaQuestPropertyValue(get_property(property_name));
    
    boolean should_load_anyways = false;
    if (!state.finished)
    {
        if (QuestLogTracksProperty(property_name))
            should_load_anyways = true;
    }
    
    if ((should_load_anyways || state.in_progress) && allow_quest_log_load)
    {
        requestQuestLogLoad(property_name);
        state.QuestStateParseMafiaQuestPropertyValue(get_property(property_name));
    }
    if (QuestLogTracksProperty(property_name) && !state.finished)
        state.QuestStateParseMafiaQuestPropertyValue(QuestLogLookupProperty(property_name));
}

void QuestStateParseMafiaQuestProperty(QuestState state, string property_name)
{
    QuestStateParseMafiaQuestProperty(state, property_name, true);
}

boolean needTowerMonsterItem(string in_item_name)
{
	if (in_item_name.to_item().available_amount() > 0)
		return false;
	for i from 1 to 6
	{
		string item_name = __misc_state_string["Tower monster item " + i];
		if (__quest_state["Level 13"].state_boolean["Past tower monster " + i])
			continue;
		if (in_item_name == item_name)
			return true;
	}
	return false;		
}