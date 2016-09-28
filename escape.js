// Escape - escapes URLs for proper interpretation by the web server.

function utf8Encode(str) 
{ 
	var	out	= ""; 

	for(var	i =	0; i < str.length; i++) 
	{ 
		var	c =	str.charCodeAt(i); 

		if (c <	0x80) 
		{ 
			out	+= String.fromCharCode(c); 
		} 
		else if	(c < 0x800)	
		{ 
			out	+= String.fromCharCode(0xC0	+ (c / 0x40)); 
			out	+= String.fromCharCode(0x80	+ (c % 0x40)); 
		} 
		else 
		{ 
			out	+= String.fromCharCode(0xE0	+ (c / 0x1000));  // c >> 12 
			c =	c %	0x1000;	
			out	+= String.fromCharCode(0x80	+ (c / 0x40));	 //	c >> 6 
			out	+= String.fromCharCode(0x80	+ (c % 0x40)); 
		} 
	} 

	return out;	
}


function utf8Decode(str)
{
	var out = "";
	
	for (var i = 0; i < str.length; )
	{
		var c = str.charCodeAt(i);
		
		if (c <	0x80) 
		{ 
			out	+= String.fromCharCode(c);
			i++;
		}
		else if (c < 0xE0)
		{
			out += String.fromCharCode((str.charCodeAt(i) - 0xC0) * 0x40 + (str.charCodeAt(i + 1) - 0x80));
			i += 2;
		}
		else
		{
			out += String.fromCharCode((str.charCodeAt(i) - 0xE0) * 0x1000 + (str.charCodeAt(i + 1) - 0x80) * 0x40 + (str.charCodeAt(i + 2) - 0x80));
			i += 3;
		}
	}
	
	return out;
}



function escapeURL(string)
{
	if (string=="" || string==null)
		return;
	var escaped = utf8Encode(string);
	escaped = escape(escaped);
	
	// the escape function doesn't escape the plus sign
	escaped = escaped.replace(/\+/g, "%2b");
	
	return escaped;
}
  

