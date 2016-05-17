
//Min, max inclusive.
function randomi(min, max)
{
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

var __matrix_spinners = [];
var __matrix_spinner_counter = 0;
var __matrix_animation_interval = 16;
var __matrix_glyph_size = 16;

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


function matrixTick()
{
	var context_width = window.innerWidth; //document.body.clientWidth;
	var context_height = window.innerHeight; //document.body.clientHeight;
	var canvas = document.getElementById("matrix_canvas");
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
				matrixTick();
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
	//var glyphs_white = document.getElementById("matrix_glyphs_white");
	
	
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
		
		/*if (spinner.counter % 6 == 0)
		{
			spinner.glyph_index = randomi(0, 102 - 1);
			matrixDrawGlyph(context, glyphs_white, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, "");
		}*/
		if (spinner.counter % spinner.interval == 0)
		{
			//matrixDrawGlyph(context, glyphs_white, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, "rgb(0, 200, 0);");
			matrixDrawGlyph(context, glyphs, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, "");
			spinner.y_index++;
			spinner.glyph_index = randomi(0, 102 - 1);
			if (spinner.y_index > maximum_glyphs_y)
			{
				should_delete = true;
			}
			//matrixDrawGlyph(context, glyphs, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, ""); //rgb(255, 255, 255);");
		}
		else
		{			
			//matrixDrawGlyph(context, glyphs_white, spinner.glyph_index, spinner.x_index, spinner.y_index, spinner.alpha, ""); //rgb(255, 255, 255);");
		}
		if (Math.random() < 0.05 / 60.0)
			should_delete = true;
		if (true && spinner.interval > 1)
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
	
	setTimeout(function() {matrixTick()}, __matrix_animation_interval);
}

function matrixInit()
{
	var context = document.getElementById("matrix_canvas").getContext("2d");
	context.fillStyle = "rgb(0,0,0)";
	context.fillRect(0, 0, 1024, 1024);
	
	setTimeout(function() {matrixTick()}, __matrix_animation_interval);
}