// Tri-State Checkbox

var blank_src, yes_src, no_src;
var blank_file_name, yes_file_name, no_file_name;


function initStates(blank, yes, no)
{
	blank_src = blank;
	blank_file_name = getFileName(blank);
	
	yes_src = yes;
	yes_file_name = getFileName(yes);
	
	no_src = no;
	no_file_name = getFileName(no);
}


function cycleState(image)
{
	var current_file_name = getFileName(image.src);
	
	if (current_file_name == blank_file_name)
	{
		image.src = yes_src;
		return 1;
	}
	
	if (current_file_name == yes_file_name)
	{
		image.src = no_src;
		return 2;
	}
	
	image.src = blank_src;
	return 0;
}


function getFileName(src)
{
	var delimiter = "fn=";
	var start = src.indexOf(delimiter);
	if (start == -1)
	{
		alert("tri-stat-check.js\nUnexepected image file name format.");
	}
	
	start += delimiter.length;
	
	var end = src.indexOf("&", start);
	if (end == -1)
	{
		end = src.indexOf("$", start);
		if (end == -1)
		{
			end = src.length;
		}
	}
	
	var file_name = src.substring(start, end);
	
	return file_name;
}