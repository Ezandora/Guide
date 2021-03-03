//This script is in the public domain.


//Min, max inclusive.
function randomi(min, max)
{
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

//Matrix:
var __matrix_spinners = [];
var __matrix_spinner_counter = 0;
var __matrix_animation_interval = 16;
var __matrix_glyph_size = 16;
var __matrix_animating = false;
var __matrix_timer_id = 1;
var __matrix_last_event_time;

function matrixDrawGlyph(context, glyphs, glyph_index, x_index, y_index, alpha, colour)
{
	if (y_index < 0 || x_index < 0)
		return;
	var gx = glyph_index % 10;
	var gy = Math.floor(glyph_index / 10);
	
	context.globalCompositeOperation = "source-over";
	if (false)
	{
		context.globalAlpha = 1.0;
		context.fillStyle = "rgb(0,0,0)";
		context.fillRect(x_index * __matrix_glyph_size, y_index * __matrix_glyph_size, __matrix_glyph_size, __matrix_glyph_size);
	}
	//context.globalCompositeOperation = "lighter";
	context.globalAlpha = alpha;
	context.drawImage(glyphs, gx * __matrix_glyph_size, gy * __matrix_glyph_size, __matrix_glyph_size, __matrix_glyph_size, x_index * __matrix_glyph_size, y_index * __matrix_glyph_size, __matrix_glyph_size, __matrix_glyph_size);
	//context.globalCompositeOperation = "source-over";
	
	if (colour != "")
	{
		context.globalCompositeOperation = "multiply";
		context.fillStyle = colour; //"rgb(0,127,255)";
		context.fillRect(x_index * __matrix_glyph_size, y_index * __matrix_glyph_size, __matrix_glyph_size, __matrix_glyph_size);
		context.globalCompositeOperation = "source-over";
	}
}


function matrixTick(id)
{
    if (id < __matrix_timer_id) //out of line
        return;
	var context_width = window.innerWidth; //document.body.clientWidth;
	var context_height = window.innerHeight; //document.body.clientHeight;
	var canvas = document.getElementById("matrix_canvas");
    if (canvas == null)
        return;
	var canvas_holder = document.getElementById("matrix_canvas_holder");
    if (canvas_holder == null)
        return;
	var needs_resize = false;
	if (canvas.width != context_width)
		needs_resize = true;
	if (canvas.height != context_height)
		needs_resize = true;
	if (needs_resize)
	{
		var stored_data = undefined;
		try
		{
			//This is an invalid operation on file:// in chrome, so catch and fallback:
			stored_data = canvas.toDataURL();
			var previous_image = new Image;
			//Once the image has been parsed, resize and update:
			previous_image.onload = function()
			{
				canvas.width = context_width;
				canvas.height = context_height;
				canvas.getContext("2d").drawImage(previous_image, 0, 0);
				matrixTick(id);
			}
			previous_image.src = stored_data;
			return;
		}
		catch (exception)
		{
			canvas.width = context_width;
			canvas.height = context_height;
		}
	}
	
	var context = canvas.getContext("2d");
	
	var glyphs = document.getElementById("matrix_glyphs");
	if (glyphs == null)
        return;
	
	var maximum_glyphs_x = Math.ceil(context_width / __matrix_glyph_size);
	var maximum_glyphs_y = Math.ceil(context_height / __matrix_glyph_size);
	
	
	//Fade out:
	if (true)
	{
		//Subtraction method:
		context.globalCompositeOperation = "difference";
		context.fillStyle = "rgb(2, 2, 2)";
		context.globalAlpha = 1.0;
		context.fillRect(0, 0, context_width, context_height);
		context.globalCompositeOperation = "source-over";
	}
	else
	{
		//Alpha method:
		context.fillStyle = "rgb(0,0,0)";
		context.globalAlpha = 1.0 / __matrix_glyph_size; //1.0 / (60.0);
		context.fillRect(0, 0, context_width, context_height);
	}
	
	if (false)
	{
		//Fill the screen:
		for (var y = 0; y < maximum_glyphs_y; y++)
		{
			for (var x = 0; x < maximum_glyphs_x; x++)
			{
				var glyph_index = randomi(0, 102 - 1);
				var alpha = Math.random();
				matrixDrawGlyph(context, glyphs, glyph_index, x, y, alpha, "");
			}
		}
	}
	if (false)
	{
		//Random glyphs:
		for (var i = 0; i < 128; i++)
		{
			var x = randomi(0, maximum_glyphs_x);
			var y = randomi(0, maximum_glyphs_y);
			var glyph_index = randomi(0, 102 - 1);
			var alpha = Math.random();
			matrixDrawGlyph(context, glyphs, glyph_index, x, y, alpha, "");
		}
	}
	
	//Create spinners:
	var spinner_density = (context_width * context_height) / (__matrix_glyph_size * 256);
	while (__matrix_spinners.length < spinner_density)
	{
		var spinner = new Object();
		
		spinner.x_index = randomi(0, maximum_glyphs_x);
		spinner.y_index = randomi(-16, maximum_glyphs_y);
		spinner.alpha = Math.random(); //Math.random() * 0.25 + 0.75;
		spinner.counter = randomi(0, 11);
		spinner.glyph_index = randomi(0, 102 - 1);
		spinner.interval = randomi(1, 15);
		
		__matrix_spinners.push(spinner);
	}
	//Draw spinners:
	var spinners_next = [];
	for (var i = 0; i < __matrix_spinners.length; i++)
	{
		var spinner = __matrix_spinners[i];
		var should_delete = false;
		
		if (spinner.counter % spinner.interval == 0)
		{
			matrixDrawGlyph(context, glyphs, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, "");
			spinner.y_index++;
			spinner.glyph_index = randomi(0, 102 - 1);
			if (spinner.y_index > maximum_glyphs_y)
			{
				should_delete = true;
			}
		}
		if (Math.random() < 0.05 / 60.0)
			should_delete = true;
		if (spinner.interval > 1)
		{
			var percentage = ((spinner.counter % spinner.interval) + 1) / (spinner.interval);
			matrixDrawGlyph(context, glyphs, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha * percentage, "");
		}
		if (!should_delete)
			spinners_next.push(spinner);
		
		spinner.counter++;
	}
	__matrix_spinners = spinners_next;
	__matrix_spinner_counter++;
	
	setTimeout(function() {matrixTick(id)}, __matrix_animation_interval);
}

function matrixStartAnimation()
{
    if (__matrix_animating)
        return;
    __matrix_last_event_time = timeInMilliseconds();
	var canvas_holder = document.getElementById("matrix_canvas_holder");
    
    if (canvas_holder === null)
        return;
    
    __matrix_timer_id++;
	setTimeout(function() {matrixTick(__matrix_timer_id)}, __matrix_animation_interval);
    __matrix_animating = true;
    
    canvas_holder.style.display = "inline";
    canvas_holder.style.visibility = "visible";
    canvas_holder.style.opacity = 0.0;
    canvas_holder.style.transition = "opacity 1.0s";
    canvas_holder.style.opacity = 1.0;
}

function matrixStopAnimation()
{
    if (!__matrix_animating)
        return;
    __matrix_last_event_time = timeInMilliseconds();
    __matrix_timer_id++; //will cancel any running timer
    __matrix_animating = false;
    
	var canvas_holder = document.getElementById("matrix_canvas_holder");
    if (canvas_holder == null)
        return;
    canvas_holder.style.visibility = "hidden";
    
    canvas_holder.style.opacity = 0.0;
}







//Guide:

//Auto-reload code:
var __guide_last_reload_api_response; //saved API response from the last time we reloaded
var __guide_ash_url;
var __guide_last_reload_time; //Date.now(), milliseconds since epoch
var __guide_default_window_size;
var __guide_active_timer;
var __guide_timer_interval = 2000;

var __guide_importance_bar_visible = false;
var __guide_resource_bar_visible = true;
var __guide_version = "";

var __guide_colset_type = -1; //1 for long, 2 for short

var __guide_colset_long_kol_default = "200,3**,*";
var __guide_colset_long_kol_default_regex = /([0-9][0-9]*),(3\*|[0-9][0-9]*%|[0-9][0-9]*|3\*[0-9][0-9]*),[\*0123456789][0-9]*/; //firefox generic matching
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
	//old method:
    //var scroll_position = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;
    var scroll_position = document.getElementById("main_content_holder").scrollTop; 
    var desired_visibility = false;
    if (scroll_position > test_position)
        desired_visibility = true;
    //console.log("scroll_position = " + scroll_position + " test_position = " + test_position + " desired_visibility = " + desired_visibility);
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

function updateResourceBar(should_be_instant)
{
	var resource_bar = document.getElementById("resource_bar_outer_container");
	var hide_show_button = document.getElementById("resource_bar_hide_show_button");
	
    if (resource_bar === null)
    	return;
	
	if (should_be_instant)
	{
        resource_bar.classList.add("r_no_css_transition");
	}
	if (__guide_resource_bar_visible)
	{
		resource_bar.style.maxHeight = "33vh";
        //hide_show_button.innerHTML = "&#x2573;"; //╳
        //hide_show_button.innerHTML = "X"; //╳
        //don't use X; it looks inconsistent (the X implies we're closing something on a level different from closing a drawer)
        //hide_show_button.innerHTML = "<img src=\"data:image/gif;base64,R0lGODlhgACAANUiAODg4IqKitra2o2NjYGBgdXV1YCAgOPj49vb24eHh4iIiIODg+fn5+Tk5NnZ2YmJidbW1ouLi9zc3M/Pz4WFhdTU1MDAwMfHx8HBwcrKysbGxtjY2Lu7u8XFxfj4+IKCgsTExH9/f/f39wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAACIALAAAAACAAIAAAAb/QJFwmBEMj8ikcslsOp/QaBOgcSIMBKN0y+16v0fAIlRgCgKhUOAAbrvfXcYgnagoL4Z0OuCA+/+AAHN6IRZIV4RpBn2AjY5bYolpZUJnkmkPbI+bnEhylyF1Ihl5oCEPG52qj4KmaSASBK4hi6u2cJGuBmUIEbOZt8Fen64JlCINvq4PjMLOTq3FAEgCsrrNz9lhY7oQSpbLmtraxKYKx0kHaMvY48HR5tNN1bO17u/cpgbeT+CmwPdWlQN1Toq6X+0CNoJHUJ4UetcUssoHap8Xf6AASvQz8FLBLwfZbcQ1KJ4biPoSjoRE8ZLFNxgvaVy5paOkj3BC/lNJkwlD/48O/aCsqKUntJaSXjaKKWmm0SQ2E+F0pDMjT6M/bwZ9NNRl0adCcunjp4ppIqc9oxKaqqqqzKsKs0rduqpr0q8jxVYkK8wsIbQB1ephK8xtU7jP5K6l68xuIgN4x+l1yXecXz2AnQlOQ3ic4bOIVSkezNidY0KQtU1OWlniZUzigm0O0VniZ0J8hI3mXHojAmumstxa/bh1z9dqYm+aXbtng3WmcnPaTbu30d+zhE+sZxxsJeig1jhijs57kuezpPuhrsC6eRHYXWl/Qxx19/dHkIt3Qx4/FPSuqOcFe+75N0R8wUUWRX16KGVgP+Bdsl9NJRFU3oNOABhdaGFUCP8UhlwgCMp8R3EHYhf6KadEfyd2oWF4cBHY4hciXkLiNibO+EWKUHl404U6bvGihF/JGGQbNUqiHYOK3HfkQxFKsgZ7QD7pYpRSAdeQlX4kOUtxXP6BnDlVhvnFkF9WZ2YjXo61piNjclbmm200oMCXFBRI54AffJnanoH4GJ6CgA6IlHyEFirFbBKqqOiCgqYZQKKPLsHklzdWysRsFJQSnaOadjhLAgDoR2mll+4iRJt6ZBrqbMbkhyVuoCpKHannzarHpKGGdShqVbKahqt7wjonArruUauZtxaIZiK8FprqnEcIGwKxVhq7BbLpLatjs1emd+qJ09KopY3jPqj/LRjcBuitgeC68Sxu6ZpXLhzWYovful0mm1yL8QIy7671rnSvI/kWLBG/j7T7qX8BczLwHgpL9muD1P6RsHcMr+JweO9KFqkeuDozsRoVD3exIhlvsvFIHTvzcaMbRazNydHec/A9L48TszszSxnyJjYrhHPKuKxMS8vZ9HzLz775O+EqRdN0tC07g+X0I1BfJ/XQA45Mh54rXe1I1v5t/UbX7wUNLdhPVP2g2W6gfaLaXLCNodu0giH3jMmIa2g9TGMYS3YV661jL91K8beVgQeYrt1rHo6oE4pzybi7PokdCtlcRh6dgpQXanmCnngea68HKvNwWKqDTqfog4pQT3qlHohw+ogCXDBq4YpuboohBdx5ScmsM0E7IRRMMAQELgGv6e56OH8EBomsnvwTwqfBgRLFj729FJE3zwT0qo4vxeHWM9GB9OojgEESQQAAOw==\" width=\"16\" height=\"16\" style=\"margin-top:2px;\">";
        hide_show_button.innerHTML = "&#x25bc;"; //▼
	}
	else
	{
		resource_bar.style.maxHeight = "0px";
        hide_show_button.innerHTML = "&#x25b2;"; //▲
    }
    resource_bar.offsetHeight; //glFlush()
    resource_bar.classList.remove("r_no_css_transition");
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
        
    //Always show refresh; our pop-up might not show it in-browser.
    try
    {
        document.getElementById("button_refresh").style.display = "inline";
	}
	catch (exception)
	{
	}
    if (frame_id == "Guide Frame")
	{
		//in frame
        try
        {
            document.getElementById("button_close_box").style.display = "inline";
            
            document.getElementById("button_new_window").style.display = "inline";
            
            
            var current_position = getCurrentInstalledFramePosition();
            
            if (current_position == 3)
            {
                document.getElementById("button_arrow_right_left").style.display = "inline";
            }
            if (current_position == 2)
            {
                document.getElementById("button_arrow_right_right").style.display = "inline";
            }
        }
        catch (e) //buttons may not be there
        {
        }
	}
    var refresh_status = document.getElementById("refresh_status");
    refresh_status.innerHTML = ""; //clear out disabled message
    
    updateResourceBar(true);
    showhideRegenerateFromDataset();
    
    var importance_container = document.getElementById("importance_bar");
    if (importance_container != undefined)
    {
        __guide_importance_bar_visible = false;
        var tasks_position = elementGetGlobalOffsetTop(document.getElementById("Tasks_checklist_container")) + 1;
        
        recalculateImportanceBarVisibility(tasks_position, importance_container, true)
        
        //window.onscroll = function (event) { recalculateImportanceBarVisibility(tasks_position, importance_container, false); };
        document.getElementById("main_content_holder").onscroll = function (event) { recalculateImportanceBarVisibility(tasks_position, importance_container, false); };
    }
    else
    {
        window.onscroll = undefined;
        document.getElementById("main_content_holder").onscroll = undefined;
    }
}

function updatePageHTML(body_response_string)
{
	if (body_response_string.length < 11)
		return;
	//Somewhat hacky way of reloading the page:
    matrixStopAnimation();
    
    //Save display style for two tags:
    //r_location_popup_blackout r_location_popup_box
    var elements_to_save_properties_of = ["r_location_popup_blackout", "r_location_popup_box","resource_bar_outer_container", "r_location_popup_blackout_info_container", "showhide_mouseover_popup", "importance_bar_gradient"];
    var elements_to_save_inner_html_of = ["resource_bar_info_container", "showhide_mouseover_popup"];
    var elements_to_save_styles_of = ["resource_bar_info_container", "showhide_mouseover_popup"];
    
    var saved_opacity_of_element = [];
    var saved_bottom_of_element = [];
    var saved_visibility_of_element = [];
    var saved_max_height_of_element = [];
    
    
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
        saved_max_height_of_element[element_id] = element.style.maxHeight;
    }
    
    var saved_inner_html = [];
    for (var i = 0; i < elements_to_save_inner_html_of.length; i++)
    {
    	var element_id = elements_to_save_inner_html_of[i];
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        
        saved_inner_html[element_id] = element.innerHTML;
    }
    
    var saved_styles = [];
    for (var i = 0; i < elements_to_save_styles_of.length; i++)
    {
    	var element_id = elements_to_save_styles_of[i];
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        
        saved_styles[element_id] = element.style.cssText;
    }
    
    window.onscroll = undefined;
    
    var scroll_position = 0;
    try
    {
        document.getElementById("main_content_holder").onscroll = undefined;
    	scroll_position = document.getElementById("main_content_holder").scrollTop;
    }
    catch (exception)
    {
    }
    
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
        //It's not visible; reposition.
        if (element_id === "r_location_popup_box" && !__location_popup_bar_visibility_status)
            element.style.bottom = "-" + element.clientHeight + "px";
        else
        	element.style.bottom = bottom;
            
        
        element.style.maxHeight = saved_max_height_of_element[element_id];
        
        element.offsetHeight; //force movement
        element.style.transition = saved_transition;
    }
    
    for (var element_id in saved_inner_html)
    {
        if (!saved_inner_html.hasOwnProperty(element_id))
            continue;
            
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        
        element.innerHTML = saved_inner_html[element_id];
    }
    
    for (var element_id in saved_styles)
    {
        if (!saved_styles.hasOwnProperty(element_id))
            continue;
            
        var element = document.getElementById(element_id);
        if (element == undefined)
            continue;
        if (element.style == undefined)
            continue;
        
        element.style.cssText = saved_styles[element_id];
    }
    
    
    writePageExtras();
    
    try
    {
        document.getElementById("main_content_holder").scrollTo(0, scroll_position);
    }
    catch (exception)
    {
    }
    
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
    
    if (__matrix_last_event_time == undefined)
    	__matrix_last_event_time = timeInMilliseconds();
    var seconds_since_last_matrix_event = (timeInMilliseconds() - __matrix_last_event_time) / 1000.0;
    var matrix_activation_time = 5 * 60;
    if (Math.min(seconds_since_last_reload, seconds_since_last_matrix_event) > matrix_activation_time && !__matrix_animating)
        matrixStartAnimation();
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
    //should_update = true; //continuous refresh for testing
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
	if (false)
		request.open("POST", "GuideAPI.js");
	else
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

function GuideInit(ash_url, default_window_size, resource_bar_visible, guide_version)
{
    __guide_ash_url = ash_url;
    __guide_default_window_size = default_window_size;
    
    __guide_resource_bar_visible = resource_bar_visible;
    __guide_version = guide_version;
    
    showhideDatasetReadFromLocalStorage();
    
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
    	if (false)
        {
        	//old method:
            window.scrollTo(0, container_position);
        }
        else
        {
        	var main_content_holder = document.getElementById("main_content_holder");
            main_content_holder.scrollTo(0, container_position);
            
        }
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

function toggleBlackoutBoxVisibility(element_id, visible)
{
    var blackout_box = document.getElementById(element_id);
    
    if (visible)
    {
        blackout_box.style.visibility = "visible";
        blackout_box.style.transition = "opacity 1.0s";
        blackout_box.style.opacity = 1.0;
    }
    else
    {
        if (!browserProbablySupportsPointerEvents()) //disable animation, but allow clicks
            blackout_box.style.visibility = "hidden";
        blackout_box.style.transition = "opacity 0.25s";
        blackout_box.style.opacity = 0.0;
    }
}


var __location_popup_bar_visibility_status = false;
function alterLocationPopupBarVisibility(event, visibility)
{
    var popup_box = document.getElementById('r_location_popup_box');
    if (document.getElementById('location_bar_inner_container') != event.target && event.target != undefined) //I... think what is happening here is that we're receiving mouseleave events for the last innerHTML, and that causes a re-pop-up, so only listen to events from current inner containers
        return;
    
    if (popup_box == undefined)
        return;
        
    __location_popup_bar_visibility_status = visibility;
    
    toggleBlackoutBoxVisibility("r_location_popup_blackout", visibility);
    if (visibility)
    {
        popup_box.style.opacity = 1.0;
        
        //scroll up from proper position:
        if (true) //!(popup_box.style.bottom === "4.59em"))
        {
            var saved_transition = popup_box.style.transition;
            popup_box.style.transition = "";
            popup_box.style.bottom = "-" + popup_box.clientHeight + "px";
            popup_box.offsetHeight; //force movement
            popup_box.style.transition = saved_transition;
            
            
            var bottom_location = document.getElementById("location_bar_outer_container").offsetHeight;
            
            var navigation_bar_outer_container = document.getElementById("navigation_bar_outer_container");
            if (navigation_bar_outer_container !== null)
	            bottom_location += navigation_bar_outer_container.offsetHeight;
            popup_box.style.bottom = bottom_location + "px";
            //popup_box.style.bottom = "4.59em"; //supposed to be 4.6em, but temporarily renders one pixel off in chromium otherwise
            //document.getElementById("location_bar_outer_container").top;
        }
    }
    else
    {
        popup_box.style.bottom = "-" + popup_box.clientHeight + "px";
    }
}

function setUserPreference(key, value)
{
	var request = new XMLHttpRequest();
	var form_data = "set user preferences=true&" + key + "=" + value;
	
	request.open("POST", __guide_ash_url, false);
	request.send(form_data);
}

function setResourceBarStatus(status)
{
	setUserPreference("resource bar open", status);
}

function setMatrixStatus(status)
{
	setUserPreference("matrix disabled", status);
	document.location.reload(true); //hack, do not replicate
}










//Resource bar code:


function handleResourceBarClick()
{
	__guide_resource_bar_visible = !__guide_resource_bar_visible;
	setResourceBarStatus(__guide_resource_bar_visible);
	updateResourceBar(false);
}


function displayResourceBarPopupFor(holding_div)
{
	var resource_bar_info_container = document.getElementById("resource_bar_info_container");
	
	var resource_id = parseInt(holding_div.dataset.resourceId);
	var colour = holding_div.dataset.backgroundColour;
	var background_colour_faded_out_alpha = holding_div.dataset.backgroundColourFadedOutAlpha;
	var readable_category_name = holding_div.dataset.readableCategoryName;
	
	
	if (colour === "")
		colour = "#FFFFFF";
    if (false)
    {
        var border_style = "";
        //border_style = "10px solid #B2B2B2";
        border_style = "20px solid " + colour;
        resource_bar_info_container.style.borderTop = border_style;
        resource_bar_info_container.style.borderBottom = border_style;
    }
    else
        resource_bar_info_container.style.borderTop = "1px solid #B2B2B2";
    
    //Instead of vertical padding, switch to location-bar style background? Or both?
    if (true)
    {
    	var paddington_bear = "1em"; //"25px";
    	resource_bar_info_container.style.paddingTop = paddington_bear;
        resource_bar_info_container.style.paddingBottom = paddington_bear;
    }
    resource_bar_info_container.style.backgroundColor = colour;
	var all_content_ids = document.querySelectorAll("[data-content-ids]");//document.querySelectorAll("[data-content-ids=\"" + resource_id + "\"]");
	var content_container = undefined;
	var done = false;
	for (var i = 0; i < all_content_ids.length; i++)
	{
		var e = all_content_ids[i];
        var ids = e.dataset.contentIds.split("|");
        for (var j = 0; j < ids.length; j++)
        {
        	var id = parseInt(ids[j]);
            if (id == resource_id)
            {
            	content_container = e;
            	done = true;
                break;
            }
        }
        if (done)
        	break;
	}
	//var content_container = document.getElementById("rightContent" + resource_id);
	if (content_container !== undefined)
	{
		var container_html = "";
        container_html += content_container.innerHTML;
        if (readable_category_name != "")
	        container_html += "<div style=\"font-weight:bold;position:absolute;margin-bottom:-1em;right:20px;\">" + readable_category_name + "&nbsp;</div>";
		resource_bar_info_container.innerHTML = container_html;
  
  
  		var left_showhide_elements = resource_bar_info_container.getElementsByClassName("r_cl_l_left_showhide");
        for (var i = 0; i < left_showhide_elements.length; i++)
        {
        	var e = left_showhide_elements[i];
            e.className = "r_cl_l_left_showhide_blank";
        }
        resource_bar_info_container.getElementsByClassName("r_cl_l_right_content")[0].style.display = "block";
        resource_bar_info_container.getElementsByClassName("r_cl_l_right_content_abridged")[0].style.display = "none";
  
        var all_elements_containing_content_id = resource_bar_info_container.querySelectorAll("[data-content-id]")
        
        for (var i = 0; i < all_elements_containing_content_id.length; i++)
        {
        	var e = all_elements_containing_content_id[i]; 
        	var element_content_id = parseInt(e.dataset.contentId)
            if (element_content_id != resource_id)
            	e.style.display = "none";
        } 
        if (true)
        {
        	//Replace inner image:
            var resource_images = holding_div.querySelectorAll("img");
            var container_images = resource_bar_info_container.querySelectorAll("img");
            if (resource_images != null && resource_images.length > 0 && container_images != null && container_images.length > 0)
            {
            	var resource_image = resource_images[0];
                var container_image = container_images[0];
                container_image.src = resource_image.src;
            }
        }
    }
	
	if (false)
	{
        var resource_bar_info_container_shadow = document.getElementById("resource_bar_info_container_shadow");
        
        //var background = "linear-gradient(0deg, rgba(0,0,0,.75) 0%, rgba(0,0,0,0) 100%)"; 
        //background = "linear-gradient(0deg, " + colour + " 0%, rgba(0,0,0,0) 100%)";
        //background = "linear-gradient(0deg, " + colour + " 0%, " + background_colour_faded_out_alpha + " 100%)";
        //resource_bar_info_container_shadow.style.background = background;
        //console.log("result is \"" + no + "\"");
        if (false) //disabled; I do not like the look
            resource_bar_info_container_shadow.style.opacity = 0.75;
    }
    
    toggleBlackoutBoxVisibility("r_location_popup_blackout_info_container", true);
}

function cancelResourceBarPopup()
{
	var resource_bar_info_container = document.getElementById("resource_bar_info_container");
	resource_bar_info_container.innerHTML = "";
	resource_bar_info_container.style.borderTop = "";
	resource_bar_info_container.style.borderBottom = "";
	resource_bar_info_container.style.paddingTop = "";
	resource_bar_info_container.style.paddingBottom = "";
    toggleBlackoutBoxVisibility("r_location_popup_blackout_info_container", false);
	if (false)
	{
        var resource_bar_info_container_shadow = document.getElementById("resource_bar_info_container_shadow");
        resource_bar_info_container_shadow.style.opacity = 0.0;
    }
}













//Showhide code:

//Full of dictionaries, key is the checklist name
//More structure would be preferred.
//Try not to edit this directly; use accessor functions.
//string element_stable_id:boolean on_off_state
var __showhide_full_dataset = {};
//string checklist name:boolean on_off_state
var __showhide_checklist_on_off_dataset = {};
var __showhide_stable_id_to_abridged_text_dataset = {}; //used for preserving across versions


function writeAsJSONToLocalStorage(key, value)
{
	try
	{
		if (typeof localStorage === "undefined")
  			return;
        var generated_json = JSON.stringify(value);
        localStorage.setItem(key, generated_json);
        //console.log("writing " + key + ": " + generated_json);
	}
	catch (exception)
	{
	}
}

function loadJSONFromLocalStorage(key)
{
    var json = localStorage.getItem(key);
    var result = JSON.parse(json);
    if (result === undefined || result === null)
        result = {};
    //console.log("reading " + key + ": " + json);
    return result;
}


function showhideDatasetWriteChecklistOnly()
{
	writeAsJSONToLocalStorage("guide showhide checklist on off", __showhide_checklist_on_off_dataset);
}

function showhideDatasetWriteStableIdKnowledge()
{
	writeAsJSONToLocalStorage("guide showhide stable id mappings", __showhide_stable_id_to_abridged_text_dataset);
}

function showhideDatasetWriteMost()
{
	writeAsJSONToLocalStorage("guide showhide dataset", __showhide_full_dataset);
    showhideDatasetWriteChecklistOnly();
}

function showhideDatasetReadFromLocalStorage()
{
	try
	{
		if (typeof localStorage === "undefined")
  			return;
        
        __showhide_full_dataset = loadJSONFromLocalStorage("guide showhide dataset");
        __showhide_checklist_on_off_dataset = loadJSONFromLocalStorage("guide showhide checklist on off");
        
        __showhide_stable_id_to_abridged_text_dataset = loadJSONFromLocalStorage("guide showhide stable id mappings");

         
        var previous_stored_version = localStorage.getItem("guide showhide last version");
        
        if (previous_stored_version !== __guide_version)
        {
        	console.log("Guide version changed from " + previous_stored_version + " to " + __guide_version + ", attempting migration.");
            
            //For now, just clear them all. This will mean version upgrades won't preserve individually clicked entries.
            __showhide_full_dataset = {};
            showhideDatasetWriteMost();
            
        	localStorage.setItem("guide showhide last version", __guide_version);
        }
	}
	catch (exception)
	{
	}
}

function showhideDatasetSet(checklist_title, key, value)
{
    if (!__showhide_full_dataset.hasOwnProperty(checklist_title))
        __showhide_full_dataset[checklist_title] = {};
    __showhide_full_dataset[checklist_title][key] = value;
    showhideDatasetWriteMost(); //(checklist_title);
}
function showhideDatasetClearChecklist(checklist_title, delay_writing)
{
	__showhide_full_dataset[checklist_title] = {};
	if (!delay_writing)
		showhideDatasetWriteMost(); //(checklist_title);
}

function showhideDatasetGet(checklist_title, key)
{
	return __showhide_full_dataset[checklist_title][key];
}

function showhideSetContainersVisibilityState(right_container_element, content_element, content_abridged_element, hidden_mode_enabled, showhide_button_element)
{
	if (hidden_mode_enabled)
	{
     	content_element.style.display = "none";
     	content_abridged_element.style.display = "block";
        //right_container_element.style.alignSelf = "center";
        //purpose of showhide is to draw attention away, this might not help
        //showhide_button_element.style.backgroundColor = "#F7F7F7"; //"#B2B2B2";
        showhide_button_element.classList.add("r_cl_l_left_showhide_clicked");
    }
    else
    {
     	content_element.style.display = "block";
     	content_abridged_element.style.display = "none";
        //right_container_element.style.alignSelf = "";
        //showhide_button_element.style.backgroundColor = "";
        showhide_button_element.classList.remove("r_cl_l_left_showhide_clicked");
    }
}


var __showhide_mouseover_parent_offset = -1;
function showhideContainerOpen(container_element)
{
    //Show popup:
	
	var right_container_element = container_element.getElementsByClassName("r_cl_l_right_container")[0];
	var content_element = right_container_element.getElementsByClassName("r_cl_l_right_content")[0];
	
	
	var showhide_mouseover_popup = document.getElementById("showhide_mouseover_popup");
	if (__showhide_mouseover_parent_offset == -1)
		__showhide_mouseover_parent_offset = showhide_mouseover_popup.parentElement.offsetTop; //cache to prevent a forced layout; it should always be zero but not chancing it
	var base_offset = __showhide_mouseover_parent_offset;
	var offset = container_element.offsetTop;// + ; //elementGetGlobalOffsetTop(container_element);
	
    var container_element_width = container_element.clientWidth;
    
	var multiple_entries_per_line_enabled = true;
	var popup_is_not_strictly_aligned = false;
	var alter_offset_for_element_height_above = false;
    var page_height = document.getElementById("main_content_holder").scrollHeight;
    var popup_is_limited_width = false;
	if (multiple_entries_per_line_enabled)
	{
        //console.log("offset = " + offset + ", page_height = " + page_height);
        if (offset + 200 >= page_height) //FIXME switch to actually testing if we go off page; but that means a relayout?
        {
        	//Above:
            //Underneath instead of replace:
            //offset -= container_element.clientHeight;
            alter_offset_for_element_height_above = true; //do calculation later
        }
        else if (container_element_width < window.innerWidth * 0.85)
        {
            //Underneath instead of replace:
            offset += container_element.clientHeight;
            popup_is_limited_width = true;
        }
        popup_is_not_strictly_aligned = true;
	}
	
	var set_position = offset - base_offset;
	
    var left_position = container_element.offsetLeft;
    
	
	
	showhide_mouseover_popup.style.display = "flex";
	if (!alter_offset_for_element_height_above)
	{
		showhide_mouseover_popup.style.marginTop = set_position + "px";
    }
	showhide_mouseover_popup.innerHTML = container_element.innerHTML; //content_element.innerHTML;
	if (false)
	{
		//This seemed like a good idea for consistency, except there's no room for the description.
		showhide_mouseover_popup.style.width = container_element_width + "px";
  
        showhide_mouseover_popup.style.marginLeft = left_position + "px";
	}
	
	showhide_mouseover_popup.getElementsByClassName("r_cl_l_right_content")[0].style.display = "block";
	showhide_mouseover_popup.getElementsByClassName("r_cl_l_right_content_abridged")[0].style.display = "none";
	if (popup_is_limited_width)
	{
		try
        {
			showhide_mouseover_popup.getElementsByClassName("r_cl_l_left_showhide")[0].className = "r_cl_l_left_showhide_blank";
        }
        catch (e)
        {
        }
    }
    if (alter_offset_for_element_height_above)
    {
    	//this will trigger a forced relayout; could live in imaginary land for a while?
    	set_position -= showhide_mouseover_popup.clientHeight;
		showhide_mouseover_popup.style.marginTop = set_position + "px";
    }
	
	
	//var scroll_position = document.getElementById("main_content_holder").scrollTop;
	//showhide_mouseover_popup.style.marginTop = "-" + scroll_position;
	
	/*var right_container_element = container_element.getElementsByClassName("r_cl_l_right_container")[0];
	var content_element = right_container_element.getElementsByClassName("r_cl_l_right_content")[0];
	var content_abridged_element = right_container_element.getElementsByClassName("r_cl_l_right_content_abridged")[0];
	showhideSetContainersVisibilityState(right_container_element, content_element, content_abridged_element, false, showhide_button_element);*/
}

function showhideContainerCancel()
{
	var showhide_mouseover_popup = document.getElementById("showhide_mouseover_popup");
	showhide_mouseover_popup.style.display = "none";
	showhide_mouseover_popup.innerHTML = "";
}

//The first approach was switch the abridged and full version, except that affects layout and is a nightmare to navigate.
//Better: a popup of some sort
function showhideContainerMouseenter(container_element)
{
	if (container_element.dataset.showhideMouseEnterLeaveEnabled !== "true") return;
	
	showhideContainerOpen(container_element);
}

function showhideContainerMouseleave(container_element)
{
	if (container_element.dataset.showhideMouseEnterLeaveEnabled !== "true") return;
	//Hide popup:
	showhideContainerCancel();
	/*var right_container_element = container_element.getElementsByClassName("r_cl_l_right_container")[0];
	var content_element = right_container_element.getElementsByClassName("r_cl_l_right_content")[0];
	var content_abridged_element = right_container_element.getElementsByClassName("r_cl_l_right_content_abridged")[0];
	showhideSetContainersVisibilityState(right_container_element, content_element, content_abridged_element, true, showhide_button_element);*/

}

function mouseCursorIsOverElement(event, element)
{
	if (event === null) return false;
	//janky
	var scroll_position = document.getElementById("main_content_holder").scrollTop;
	
	//console.log("click: (" + event.clientX + ", " + (event.clientY + scroll_position) + ") offsetLeft: " + element.offsetLeft + " element.offsetWidth = " + element.offsetWidth + " element.offsetTop = " + element.offsetTop + " element.offsetHeight = " + element.offsetHeight);
	if (event.clientX < element.offsetLeft) return false;
	if (event.clientX > element.offsetLeft + element.offsetWidth) return false;
	
	var y = event.clientY + scroll_position;
	if (y < element.offsetTop) return false;
	if (y > element.offsetTop + element.offsetHeight) return false;
	
	return true;
}

function showhideButtonSetState(event, showhide_button_element, new_hidden_state, from_native_click)
{
    showhide_button_element.dataset.currentlyHidden = new_hidden_state;
    
     
	var container_element = showhide_button_element.parentElement;
	var right_container_element = container_element.getElementsByClassName("r_cl_l_right_container")[0];
	
	
	
	//To flip:
	//hide r_cl_l_right_content
	//show r_cl_l_right_content_abridged
	//Or visa-versa
	//Plus tracking
	
	
	var content_abridged_element = right_container_element.getElementsByClassName("r_cl_l_right_content_abridged")[0];
	
	if (from_native_click)
	{
		var checklist_element = container_element.parentElement;
		showhideDatasetSet(checklist_element.dataset.title, container_element.dataset.stableId, new_hidden_state);
        
        __showhide_stable_id_to_abridged_text_dataset[container_element.dataset.stableId] = container_element.dataset.abridgedText; //switch to data property?
        showhideDatasetWriteStableIdKnowledge();
        if (checklist_element.dataset.title === "Tasks")
        {
	        showhideSetStateAllEntriesWithStableId(null, container_element.dataset.stableId, new_hidden_state, false, false, false); //last one is inaccurate but
            //currently disabled because bug with clicking: clicking within element doesn't make it pop up, because if we return early that code doesn't show up until we mouse in/out
            //this might cause problems but who knows
            //return;
        }
	}
     
	var content_element = right_container_element.getElementsByClassName("r_cl_l_right_content")[0];
    
	showhideSetContainersVisibilityState(right_container_element, content_element, content_abridged_element, new_hidden_state, showhide_button_element);
	
    if (new_hidden_state)
    {
        //Hidden mode:
        if (container_element.dataset.hasShowhideEventListeners !== "true")
        {
            //We add the listeners exactly once. Because there's no way in javascript to clear all mouseenter listeners unless you store the result from addEventListener and give that to removeEventListener.
            container_element.addEventListener("mouseenter", function (event) {
                showhideContainerMouseenter(container_element);
            }, false);
            container_element.addEventListener("mouseleave", function (event) {
                showhideContainerMouseleave(container_element);
            }, false);
            container_element.dataset.hasShowhideEventListeners = "true";
        }
        container_element.classList.add("r_cl_l_container_minimised");

        container_element.dataset.showhideMouseEnterLeaveEnabled = "true";
        //Only do this if we're in the target zone:
        if (from_native_click && mouseCursorIsOverElement(event, container_element))
            showhideContainerOpen(container_element);
    }
    else
    {
        //Regular mode:
        container_element.dataset.showhideMouseEnterLeaveEnabled = "false";
        container_element.classList.remove("r_cl_l_container_minimised");
        showhideContainerCancel();
    }
	
	
	//right_container.style.backgroundColor = "pink";
}

function showhideButtonClicked(event)
{
	var showhide_button_element = event.target;
	
	
	var new_hidden_state = false;
	if (showhide_button_element.dataset.currentlyHidden === "true")
		new_hidden_state = false;
    else
    	new_hidden_state = true;
     
     
    
    
    showhideButtonSetState(event, showhide_button_element, new_hidden_state, true);
}



function showhideChecklistSetState(event, header_button_element, new_hidden_state, from_native_click, should_alter_dataset)
{
	var checklist_container_element = header_button_element.parentElement;
	
	header_button_element.dataset.hideAllEntries = new_hidden_state;
	//Hide/show the entire checklist:
    var checklist_title = checklist_container_element.dataset.title;
    
    if (should_alter_dataset)
    {
        showhideDatasetClearChecklist(checklist_title, true);
        __showhide_checklist_on_off_dataset[checklist_title] = new_hidden_state;
        showhideDatasetWriteMost(); //(checklist_title);
    }
     
  	if (checklist_title === "Tasks" && should_alter_dataset)
    {
    	//importance bar:
    	showhideSetStateAllChecklistsWithTitle(checklist_title, new_hidden_state, false, false);
        return;
    }
    var all_showhide_buttons_within_container = checklist_container_element.getElementsByClassName("r_cl_l_left_showhide");
    if (new_hidden_state)
	{
		header_button_element.classList.add("r_cl_header_clicked");
	}
	else
	{
		header_button_element.classList.remove("r_cl_header_clicked");
	}
    for (var i = 0; i < all_showhide_buttons_within_container.length; i++)
    {
        var showhide_button_element = all_showhide_buttons_within_container[i];
        if (showhide_button_element.classList.contains("r_cl_l_left_showhide_blank")) continue;
        showhideButtonSetState(event, showhide_button_element, (header_button_element.dataset.hideAllEntries === "true"), false);
    }
}


function checklistHeaderButtonClicked(event)
{
	var header_button_element = event.target;
	
	
	var new_hidden_state = false;
	if (header_button_element.dataset.hideAllEntries === "true")
		new_hidden_state = false;
    else
    	new_hidden_state = true;
    
    showhideChecklistSetState(event, header_button_element, new_hidden_state, true, true);
}

function showhideSetStateAllChecklistsWithTitle(checklist_title, entire_checklist_showhide_status, should_alter_dataset, operating_on_untouched_page)
{
    //Alter base checklist:
    if (entire_checklist_showhide_status || !operating_on_untouched_page)
    {
        var all_checklist_elements = document.querySelectorAll("[data-title='" + checklist_title + "'");
        for (var i = 0; i < all_checklist_elements.length; i++)
        {
            var checklist_element = all_checklist_elements[i];
            var header_button_element = checklist_element.getElementsByClassName("r_cl_header")[0];
            showhideChecklistSetState(null, header_button_element, entire_checklist_showhide_status, false, should_alter_dataset);
        }
    }
}

//should_alter_dataset doesn't work, needs changing
function showhideSetStateAllEntriesWithStableId(checklist_element, entry_stable_id, entry_status, should_alter_dataset, operating_on_untouched_page, entire_checklist_showhide_status)
{
    if (!operating_on_untouched_page || entry_status !== entire_checklist_showhide_status)
    {
    	var querying_element = checklist_element;
        if (querying_element === null)
        	querying_element = document;
        var all_entry_elements = querying_element.querySelectorAll("[data-stable-id='" + entry_stable_id + "'");
        for (var i = 0; i < all_entry_elements.length; i++)
        {
            var container_element = all_entry_elements[i];
            var showhide_button_element = container_element.getElementsByClassName("r_cl_l_left_showhide")[0];
            
            showhideButtonSetState(null, showhide_button_element, entry_status, false);
        }
    }
}

function showhideRegenerateFromDataset()
{
	for (var checklist_title in __showhide_checklist_on_off_dataset)
	{
        if (!__showhide_checklist_on_off_dataset.hasOwnProperty(checklist_title))
            continue;
        
        showhideSetStateAllChecklistsWithTitle(checklist_title, __showhide_checklist_on_off_dataset[checklist_title], false, true);
	}
	
    for (var checklist_title in __showhide_full_dataset)
    {
        if (!__showhide_full_dataset.hasOwnProperty(checklist_title))
            continue;
        
        var entire_checklist_showhide_status = false;
        if (__showhide_checklist_on_off_dataset.hasOwnProperty(checklist_title))
	        entire_checklist_showhide_status = __showhide_checklist_on_off_dataset[checklist_title];
         
         
        var all_checklist_elements = document.querySelectorAll("[data-title='" + checklist_title + "'");
        for (var i = 0; i < all_checklist_elements.length; i++)
        {
            var checklist_element = all_checklist_elements[i];
            //Now, each entry:
            for (var entry_stable_id in __showhide_full_dataset[checklist_title])
            {
                if (!__showhide_full_dataset[checklist_title].hasOwnProperty(entry_stable_id))
                    continue;
                var entry_status = showhideDatasetGet(checklist_title, entry_stable_id);
                //console.log("attempting on " + checklist_title + ": " + entry_stable_id + ": entry_status = " + entry_status + " entire_checklist_showhide_status = " + entire_checklist_showhide_status);
                showhideSetStateAllEntriesWithStableId(checklist_element, entry_stable_id, entry_status, false, true, entire_checklist_showhide_status);
                
            }
        }
    }
    
}
