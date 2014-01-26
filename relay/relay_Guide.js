//This script is in the public domain.

//Auto-reload code:
var __guide_last_reload_api_response; //saved API response from the last time we reloaded
var __guide_ash_url;
var __guide_last_reload_time; //Date.now(), milliseconds since epoch
var __guide_default_window_size;
var __guide_active_timer;
var __guide_timer_interval = 2000;

var __guide_importance_bar_visible = false;

function timeInMilliseconds()
{
    if (Date.now == undefined) //IE8 compatibility
        return Number(new Date);
    return Date.now();
}

function recalculateImportanceBarVisibility(test_position, relevant_container)
{
    var scroll_position = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
    var desired_visibility = false;
    if (scroll_position >= test_position)
        desired_visibility = true;
    if (__guide_importance_bar_visible != desired_visibility)
    {
        if (relevant_container == undefined)
            return;
        if (!desired_visibility)
            relevant_container.style.visibility = "hidden";
        else
            relevant_container.style.visibility = "visible";
        __guide_importance_bar_visible = desired_visibility;
    }
}

function elementGetGlobalOffsetTop(element)
{
    if (element == undefined)
        return 0.0;
    //Recurse upward:
    var offset = 0.0;
    var breakout = 100; //prevent loops, if somehow that happened
    while (breakout > 0 && element != undefined)
    {
        offset += element.offsetTop;
        element = element.parentElement;
        breakout--;
    }
    return offset;
}

function writePageExtras()
{
    if (window.self != window.top && window.name == "mainpane")
    {
        //in frame
        var editable_area_top = document.getElementById("extra_words_at_top");
        
        editable_area_top.innerHTML = "<br><span style=\"font-weight:bold;font-size:1.2em;\"><a href=\"" + __guide_ash_url + "\" onclick=\"openInNewWindow(event);\">Open in a new window</a></span>"; //large, friendly letters
    }
    var refresh_status = document.getElementById("refresh_status");
    refresh_status.innerHTML = ""; //clear out disabled message
    
    var importance_container = document.getElementById("importance_bar");
    if (importance_container != undefined)
    {
        __guide_importance_bar_visible = false;
        var tasks_position = elementGetGlobalOffsetTop(document.getElementById("Tasks_checklist_container")) + 1;
        
        recalculateImportanceBarVisibility(tasks_position, importance_container)
        
        window.onscroll = function (event) { recalculateImportanceBarVisibility(tasks_position, importance_container); };
    }
    else
        window.onscroll = undefined;
}

function updatePageHTML(body_response_string)
{
	if (body_response_string.length < 11)
		return;
	//Somewhat hacky way of reloading the page:
    window.onscroll = undefined;
	document.body.innerHTML = body_response_string;
    writePageExtras();
}

function issueTimer()
{
    if (__guide_active_timer != undefined) //one is potentially already active, cancel it
        clearTimeout(__guide_active_timer);
    __guide_active_timer = setTimeout(function() {checkForUpdate()}, __guide_timer_interval);
}

function recalculateTimerInterval()
{
    __guide_timer_interval = 2000; //absolute base
    
    //Scaling timer:
    //We check the last time we needed to reload. If it's been a while, we slow down our timer to limit wake-ups on laptops, as well as KoLmafia load.
    //This may have consistency problems - if so, go back to using a fixed setInterval.
    if (__guide_last_reload_time == undefined)
    	__guide_last_reload_time = timeInMilliseconds();
    
    var seconds_since_last_reload = (timeInMilliseconds() - __guide_last_reload_time) / 1000.0;
    if (seconds_since_last_reload < 11) //clicking
    	__guide_timer_interval = 500;
    else if (seconds_since_last_reload < 60) //thinking
    	__guide_timer_interval = 1000;
    else if (seconds_since_last_reload < 60 * 5) //off for a cup of tea
    	__guide_timer_interval = 2000;
    else //huddled in the corner afraid of ascension
    	__guide_timer_interval = 4000;
}

function updatePageAndFireTimer()
{
	__guide_last_reload_time = timeInMilliseconds();
	//We issue a special form request for only the body tag's contents, which we then change.
	var request = new XMLHttpRequest();
	request.onerror = function() { issueTimer(); }
	request.onabort = function() { issueTimer(); }
	request.ontimeout = function() { issueTimer(); }
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { updatePageHTML(request.responseText);} issueTimer(); } }
	var form_data = "body tag only=true";
	
	request.open("POST", __guide_ash_url);
	request.send(form_data);
}

function parseAPIResponseAndFireTimer(response_string)
{
	//API provided, let's see if anything's changed:
	var should_update = false;
    var should_save = true;
	try
	{
		response = JSON.parse(response_string);
	}
	catch (exception)
	{
        issueTimer();
		return;
	}
	if (__guide_last_reload_api_response == undefined) //first update, just save
	{
		__guide_last_reload_api_response = response;
        issueTimer();
		return;
	}
    else
    {
        if (response["logged in"] === "false" && __guide_last_reload_api_response["logged in"] === "true")
            return;
        if (response["need to reload"] === "true")
        {
            should_update = true;
            should_save = false;
        }
        else
        {
            //Check if anything significant (i.e. worth a reload) has changed.
            //This is a bit tricky, because things like free runs or talking to the council can change state without changing turns played.
            //Detecting all of these is impossible. Detecting most of these, though...
            //It's safe to reload often, so we check a lot of these. The only server hit we incur is to the quest log, when a quest is in progress. We have internal rate-limiting code so that only happens once every so often. So, we want to err on providing accurate information, rather than reducing KoLmafia load.
            
            //if we aren't logged in but we were before, don't reload:
            
            for (var property_name in response)
            {
                if (response[property_name] != __guide_last_reload_api_response[property_name])
                    should_update = true;
            }
        }
    }
	if (should_update)
	{
        if (should_save)
            __guide_last_reload_api_response = response;
		updatePageAndFireTimer();
	}
    else
        issueTimer();
}

function checkForUpdate()
{
	//Ask our ash's API what our status is:
	var form_data = "API status=true";
    
    
    recalculateTimerInterval();
	
	var request = new XMLHttpRequest();
    //Issue our next timer on load/error/abort. That way, mafia won't be overloaded. Is this okay? Will they always re-issue? What about timeouts?
    //FIXME add in a backup timer in case this method doesn't work? Don't know.
    
    //If error/abort/timeout happens, simply reissue the timer:
	request.onerror = function() { issueTimer(); }
	request.onabort = function() { issueTimer(); }
	request.ontimeout = function() { issueTimer(); }
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { parseAPIResponseAndFireTimer(request.responseText); } else issueTimer(); } }
	request.open("POST", __guide_ash_url);
	request.send(form_data);
}

function openInNewWindow(event)
{
    //Kind of hacky.
    if (event.button == 0) //regular click. not middle click or anything else.
    {
        //Open new window, go to main.php
        //If we did this with target=_blank, we couldn't control how the window looks.
        window.open(__guide_ash_url,'Guide','width=' + __guide_default_window_size + ',height=65536,left=0,resizable,scrollbars,status=no,toolbar=no,fullscreen=no,channelmode=no,location=no');
        window.location = "main.php"; //visit the map
        try
        {
            event.preventDefault(); //href is to ourselves. Cancel that load, let's visit the map instead.
        }
        catch (exception)
        {
            //unsupported in IE8, just fall through
        }
        return false; //backup method to the cancel method above. Not sure if it works.
    }
    return true;
}

function GuideInit(ash_url, default_window_size)
{
    __guide_ash_url = ash_url;
    __guide_default_window_size = default_window_size;
    
    //var __active_timer_event = setInterval(function() {checkForUpdate()}, 2000);
    checkForUpdate(); //starts off the timer
    writePageExtras();
}

function navbarClick(event, checklist_div_id)
{
    //When the importance bar is visible, we need to adjust our scroll position to take it into account.
    //We also have a fallback in case javascript is disabled - plain anchor tags.
    try
    {
        var container_position = elementGetGlobalOffsetTop(document.getElementById(checklist_div_id)) + 1;
        var importance_container = document.getElementById("importance_bar");
        if (importance_container != undefined && checklist_div_id != "Tasks_checklist_container")
        {
            var importance_bar_height = importance_container.offsetHeight;
            container_position -= importance_bar_height;
        }
        
        window.scrollTo(0, container_position);
        event.preventDefault(); //cancel regular click, will cause an exception in IE8
    }
    catch (exception)
    {
    }
    return false; //cancel regular click
}