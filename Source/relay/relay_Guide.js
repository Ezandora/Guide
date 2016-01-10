//This script is in the public domain.

//Auto-reload code:
var __guide_last_reload_api_response; //saved API response from the last time we reloaded
var __guide_ash_url;
var __guide_last_reload_time; //Date.now(), milliseconds since epoch
var __guide_default_window_size;
var __guide_active_timer;
var __guide_timer_interval = 2000;

var __guide_importance_bar_visible = false;

var __guide_colset_type = -1; //1 for long, 2 for short

var __guide_colset_long_kol_default = "200,3*,*";
var __guide_colset_long_kol_default_regex = /([0-9][0-9]*),(3\*|[0-9][0-9]*%),[\*0123456789][0-9]*/; //firefox generic matching
var __guide_colset_long_2 = ",3*,25%,20%";
var __guide_colset_long_3_chatpane_slightly_visible = ",3*,30%,0%";
var __guide_colset_long_3_chatpane_invisible = ",3*,30%";

var __guide_colset_long_2_regex = /[0-9][0-9]*,3\*,25%,20%/;
var __guide_colset_long_3_chatpane_slightly_visible_regex = /[0-9][0-9]*,3\*,30%,0%/;
var __guide_colset_long_3_chatpane_invisible_regex = /[0-9][0-9]*,3\*,30%/;
var __guide_observed_long_charpane_size = 200;


var __guide_colset_short_kol_default = "4*,*";
var __guide_colset_short_kol_default_regex = /(4\*|[0-9][0-9]*%),[\*0123456789][0-9]*/; //firefox generic matching
var __guide_colset_short_2 = "*,25%,20%";
var __guide_colset_short_3_chatpane_slightly_visible = "*,30%,0%";
var __guide_colset_short_3_chatpane_invisible = "*,30%";

function timeInMilliseconds()
{
    if (Date.now == undefined) //IE8 compatibility
        return Number(new Date);
    return Date.now();
}

function mainWindow()
{
	var overall_window = window;
    var breakout = 100; //prevent loops, if somehow that happened
	while (overall_window.parent != undefined && overall_window.parent != overall_window && breakout > 0)
    {
		overall_window = overall_window.parent;
        breakout--;
    }
	return overall_window;
}

function removeInstalledFrame()
{
    try
    {
        var overall_window = mainWindow();
        var rootset = overall_window.frames["rootset"];
        if (rootset == undefined)
            return;
        
        var saved_colset = undefined;
        try
        {
            //storage API requires try
            saved_colset = sessionStorage.getItem("Guide initial colset");
        }
        catch (e)
        {
        }
        
        if (overall_window.frames["Guide Frame"] == undefined)
            return;
        rootset.removeChild(rootset.children["Guide Frame"]);
        
        
        if (saved_colset != undefined)
            rootset.cols = saved_colset;
        else if (__guide_colset_type == 2)
            rootset.cols = __guide_colset_short_kol_default;
        else
            rootset.cols = __guide_colset_long_kol_default;
    }
    catch (e)
    {
    }
}


function getChatIsCurrentlyActive()
{
    var rootset = mainWindow().frames["rootset"];
	if (rootset == undefined)
		return false;
    try
    {
        //Test the URL of the chatpane:
        var url = rootset.children["chatpane"].contentDocument.URL;
        if (url.indexOf("chatlaunch.php") != -1)
            return false;
        if (url.indexOf("mchat.php") != -1) //Modern chat
            return true;
        if (url.indexOf("chat.html") != -1) //Older Chat
            return true;
        if (url.indexOf("chat.php") != -1) //Ancient Chat
            return true;
        //Will miss any chat URLs we don't know about.
    }
    catch (e)
    {
    }
    return false;
}

function getCurrentlyInsideMainpane()
{
	return (window.self != window.top && window.name == "mainpane");
}

function verifyKOLPageIsUnaltered()
{
    try
    {
        //if (mainWindow().frames["rootset"].cols != "4*,*")
        __guide_colset_type = -1;
        var rootset_cols = mainWindow().frames["rootset"].cols;
        var long_matches = rootset_cols.match(__guide_colset_long_kol_default_regex);
        if (long_matches)
        {
            __guide_colset_type = 1;
            if (long_matches.length >= 2)
            {
                __guide_observed_long_charpane_size = long_matches[1];
            }
        }
        else if (rootset_cols.match(__guide_colset_short_kol_default_regex))
            __guide_colset_type = 2;
        else if (rootset_cols === __guide_colset_long_kol_default)
            __guide_colset_type = 1;
        else if (rootset_cols === __guide_colset_short_kol_default)
            __guide_colset_type = 2;
        
        if (__guide_colset_type === -1)
            return false;
        
        if (document.getElementById("button_close_box") == undefined)
            return false;
        
        return true;
    }
    catch (e)
    {
    }
    return false;
}

function getCurrentInstalledFramePosition()
{
    try
    {
        if (mainWindow().frames["Guide Frame"] === undefined)
            return
        //Bit hacky, examine what we've done to cols:
        var rootset = mainWindow().frames["rootset"];
        if (rootset.cols.match(__guide_colset_long_2_regex))
        {
            __guide_colset_type = 1;
            return 2;
        }
        else if (rootset.cols.match(__guide_colset_long_3_chatpane_slightly_visible_regex) || rootset.cols.match(__guide_colset_long_3_chatpane_invisible_regex))
        {
            __guide_colset_type = 1;
            return 3;
        }
        
        if (rootset.cols === __guide_colset_short_2)
        {
            __guide_colset_type = 2;
            return 2;
        }
        else if (rootset.cols == __guide_colset_short_3_chatpane_slightly_visible || rootset.cols == __guide_colset_short_3_chatpane_invisible)
        {
            __guide_colset_type = 2;
            return 3;
        }
    }
	catch (e)
    {
    }
	return -1;
}

function installFrame(position)
{
    try
    {
        if (__guide_colset_type != 1 && __guide_colset_type != 2)
            return;
        var overall_window = mainWindow();
        var rootset = overall_window.frames["rootset"];
        if (rootset == undefined)
            return;

        if (position == getCurrentInstalledFramePosition())
            return;
        
        var chat_active = getChatIsCurrentlyActive();
        var avoid_storing_session_data = false;
        if (overall_window.frames["Guide Frame"] != undefined)
        {
            removeInstalledFrame();
            avoid_storing_session_data = true;
        }

        
        //Positions:
        //-1 - Unknown
        //1 - Left of everything. Disabled for now.
        //2 - Left of chat pane, chat pane visible
        //3 - Left of chat pane, chat pane invisible
        //4 - Right of everything. Disabled for now.
        if (!avoid_storing_session_data)
        {
            try
            {
                //the storage API does not seem to have a way to detect if this method throws an exception, so specifically catch it:
                sessionStorage.setItem("Guide initial colset", rootset.cols);
            }
            catch (e)
            {
            }
        }
        
        var new_frame = overall_window.document.createElement("frame");
        new_frame.name = "Guide Frame";
        new_frame.id = "Guide Frame";
        new_frame.src = __guide_ash_url;
        if (position == 2)
        {
            rootset.insertBefore(new_frame, rootset.children["chatpane"]);
            if (__guide_colset_type === 1)
                rootset.cols = __guide_observed_long_charpane_size + __guide_colset_long_2;
            else if (__guide_colset_type === 2)
                rootset.cols = __guide_colset_short_2;
            //rootset.cols = "*,25%,20%";
        }
        else if (position == 3)
        {
            rootset.insertBefore(new_frame, rootset.children["chatpane"]);
            if (chat_active)
            {
                if (__guide_colset_type === 1)
                    rootset.cols = __guide_observed_long_charpane_size + __guide_colset_long_3_chatpane_slightly_visible;
                else if (__guide_colset_type === 2)
                    rootset.cols = __guide_colset_short_3_chatpane_slightly_visible;
            }
            else
            {
                if (__guide_colset_type === 1)
                    rootset.cols = __guide_observed_long_charpane_size + __guide_colset_long_3_chatpane_invisible;
                else if (__guide_colset_type === 2)
                    rootset.cols = __guide_colset_short_3_chatpane_invisible;
            }
            /*if (chat_active)
                rootset.cols = "*,30%,0%";
            else
                rootset.cols = "*,30%";*/
        }
    }
    catch (e)
    {
    }
}

function buttonCloseClicked(event)
{
	removeInstalledFrame();
}

function buttonNewWindowClicked(event)
{
    openInNewWindow(event,false);
    buttonCloseClicked(event);
}

function buttonRightLeftClicked(event)
{
    if (getCurrentInstalledFramePosition() != 3)
        return;
    installFrame(2);
}

function buttonRightRightClicked(event)
{
    if (getCurrentInstalledFramePosition() != 2)
        return;
    installFrame(3);
}

function installFrameDefault(event)
{
    if (getChatIsCurrentlyActive())
        installFrame(2);
    else
        installFrame(3);
}

function recalculateImportanceBarVisibility(test_position, relevant_container, initial)
{
    var scroll_position = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
    var desired_visibility = false;
    if (scroll_position > test_position)
        desired_visibility = true;
    if (__guide_importance_bar_visible != desired_visibility)
    {
        if (relevant_container == undefined)
            return;
        
        var gradient_container = document.getElementById("importance_bar_gradient");
        var saved_class_name;
        if (initial && gradient_container != undefined)
        {
            saved_class_name = gradient_container.className;
            gradient_container.className += "r_no_css_transition"; //don't fade in if we have already
        }
        if (!desired_visibility)
        {
            relevant_container.style.visibility = "hidden";
            //relevant_container.style.pointerEvents = "none";
            if (gradient_container != undefined)
                gradient_container.style.opacity = "0.0";
        }
        else
        {
            relevant_container.style.visibility = "visible";
            //relevant_container.style.pointerEvents = "auto";
            if (gradient_container != undefined)
                gradient_container.style.opacity = "0.75";
        }
        if (initial && gradient_container != undefined)
        {
            gradient_container.offsetHeight; //browser hack to make no_css_transition apply
            gradient_container.className = saved_class_name;
        }
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
	var editable_area_top = document.getElementById("extra_words_at_top");
	var did_output_install_to_window_link = false;
    
    var page_unaltered = verifyKOLPageIsUnaltered();
    if (getCurrentlyInsideMainpane() && page_unaltered)
    {
        //auto install:
        installFrameDefault();
        //we considered using window.history.back(), but what if it's adventure.php?
        window.location = "main.php"; //visit the map
    }
    else
    {
        if (page_unaltered && getCurrentlyInsideMainpane() && getCurrentInstalledFramePosition() == -1)
        {
            editable_area_top.innerHTML += "<br><span style=\"font-weight:bold;font-size:1.2em;\"><a href=\"main.php\" onclick=\"installFrameDefault(event);\">Install into window</a></span>";
            did_output_install_to_window_link = true;
        }
        
        if (getCurrentlyInsideMainpane())
        {
            //just loaded
            if (did_output_install_to_window_link)
                editable_area_top.innerHTML += "<br>";
            editable_area_top.innerHTML += "<br><span style=\"font-weight:bold;font-size:1.2em;\"><a href=\"" + __guide_ash_url + "\" onclick=\"openInNewWindow(event,true);\">Open in a new window</a></span>"; //large, friendly letters
        }
    }
    var frame_id = "";
    if (window.frameElement != undefined)
        frame_id = window.frameElement.id;
    if (frame_id == "Guide Frame")
	{
		//in frame
        try
        {
            document.getElementById("button_close_box").style.visibility = "visible";
            
            document.getElementById("button_new_window").style.visibility = "visible";
            
            document.getElementById("button_refresh").style.visibility = "visible";
            
            var current_position = getCurrentInstalledFramePosition();
            
            if (current_position == 3)
            {
                document.getElementById("button_arrow_right_left").style.visibility = "visible";
            }
            if (current_position == 2)
            {
                document.getElementById("button_arrow_right_right").style.visibility = "visible";
            }
        }
        catch (e) //buttons may not be there
        {
        }
	}
    var refresh_status = document.getElementById("refresh_status");
    refresh_status.innerHTML = ""; //clear out disabled message
    
    var importance_container = document.getElementById("importance_bar");
    if (importance_container != undefined)
    {
        __guide_importance_bar_visible = false;
        var tasks_position = elementGetGlobalOffsetTop(document.getElementById("Tasks_checklist_container")) + 1;
        
        recalculateImportanceBarVisibility(tasks_position, importance_container, true)
        
        window.onscroll = function (event) { recalculateImportanceBarVisibility(tasks_position, importance_container, false); };
    }
    else
        window.onscroll = undefined;
}

function updatePageHTML(body_response_string)
{
	if (body_response_string.length < 11)
		return;
	//Somewhat hacky way of reloading the page:
    
    //Save display style for two tags:
    //r_location_popup_blackout r_location_popup_box
    var elements_to_save_properties_of = ["r_location_popup_blackout", "r_location_popup_box"];
    var saved_opacity_of_element = [];
    var saved_bottom_of_element = [];
    var saved_visibility_of_element = [];
    
    for (var i = 0; i < elements_to_save_properties_of.length; i++)
    {
        var element_id = elements_to_save_properties_of[i];
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        saved_opacity_of_element[element_id] = element.style.opacity;
        saved_bottom_of_element[element_id] = element.style.bottom;
        saved_visibility_of_element[element_id] = element.style.visibility;
    }
    
    window.onscroll = undefined;
    
    document.body.innerHTML = body_response_string;
    
    
    //Restore style tag:
    for (var element_id in saved_opacity_of_element)
    {
        if (!saved_opacity_of_element.hasOwnProperty(element_id))
            continue;
        
        var opacity = saved_opacity_of_element[element_id];
        var bottom = saved_bottom_of_element[element_id];
        
        if (opacity == undefined || bottom == undefined)
            continue;
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        
        var saved_transition = element.style.transition;
        element.style.transition = "";
        
        element.style.opacity = opacity;
        element.style.visibility = saved_visibility_of_element[element_id];
        if (element_id === "r_location_popup_box" && !(bottom === "4.59em"))
        {
            element.style.bottom = "-" + element.clientHeight + "px";
        }
        else
            element.style.bottom = bottom;
        
        element.offsetHeight; //force movement
        element.style.transition = saved_transition;
    }
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
    	__guide_timer_interval = 1250;
    else if (seconds_since_last_reload < 60 * 5) //off for a cup of tea
    	__guide_timer_interval = 2500;
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
                if (!response.hasOwnProperty(property_name))
                    continue;
                if (response[property_name] != __guide_last_reload_api_response[property_name])
                    should_update = true;
            }
        }
    }
    //should_update = true; //continually refresh for testing
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

function openInNewWindow(event, go_back)
{
    //Kind of hacky.
    if (event.button == 0) //regular click. not middle click or anything else.
    {
        //Open new window, go to main.php
        //If we did this with target=_blank, we couldn't control how the window looks.
        window.open(__guide_ash_url,'Guide','width=' + __guide_default_window_size + ',height=65536,left=0,resizable,scrollbars,status=no,toolbar=no,fullscreen=no,channelmode=no,location=no');
        if (go_back)
        {
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

var __tested_pointer_events = false;
var __browser_probably_supports_pointer_events = false;
function browserProbablySupportsPointerEvents()
{
    if (!__tested_pointer_events)
    {
        var testing_element = document.createElement("pointerEventsTest");
        testing_element.style.cssText='pointer-events:auto';
        __browser_probably_supports_pointer_events = (testing_element.style.pointerEvents === 'auto');
        __tested_pointer_events = true;
    }
    return __browser_probably_supports_pointer_events;
}

function alterLocationPopupBarVisibility(event, visibility)
{
    var popup_box = document.getElementById('r_location_popup_box');
    var blackout_box = document.getElementById('r_location_popup_blackout');
    if (document.getElementById('location_bar_inner_container') != event.target && event.target != undefined) //I... think what is happening here is that we're receiving mouseleave events for the last innerHTML, and that causes a re-pop-up, so only listen to events from current inner containers
        return;
    
    if (popup_box == undefined)
        return;
    
    if (visibility)
    {
        blackout_box.style.visibility = "visible";
        blackout_box.style.transition = "opacity 1.0s";
        
        popup_box.style.opacity = 1.0;
        blackout_box.style.opacity = 1.0;
        
        //scroll up from proper position:
        if (!(popup_box.style.bottom === "4.59em"))
        {
            var saved_transition = popup_box.style.transition;
            popup_box.style.transition = "";
            popup_box.style.bottom = "-" + popup_box.clientHeight + "px";
            popup_box.offsetHeight; //force movement
            popup_box.style.transition = saved_transition;
            
            popup_box.style.bottom = "4.59em"; //supposed to be 4.6em, but temporarily renders one pixel off in chromium otherwise
        }
    }
    else
    {
        if (!browserProbablySupportsPointerEvents()) //disable animation, but allow clicks
            blackout_box.style.visibility = "hidden";
        blackout_box.style.transition = "opacity 0.25s";
        blackout_box.style.opacity = 0.0;
        popup_box.style.bottom = "-" + popup_box.clientHeight + "px";
    }
}
