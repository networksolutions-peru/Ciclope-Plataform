
function makeFullURL(query)
{
	var cur_url = window.location.href;
	
	// strip existing query string
	var queryOffset = cur_url.indexOf('?');
	if (queryOffset != -1)
	{
		cur_url = cur_url.substring(0, queryOffset);
	}
	
	// make sure we've ONLY got a query string
	queryOffset = query.indexOf('?');
	if (queryOffset != -1)
	{
		query = query.substring(queryOffset, query.length);
	}
	
	return cur_url + query;
}



function isIE55()
{
	if (navigator.appName.indexOf("Microsoft") != -1)
	{
		// the appVersion of IE 4 AND ABOVE start with "4", so be careful here
		var version_prefix = "MSIE ";
		var version_pos = navigator.appVersion.indexOf(version_prefix) + version_prefix.length;
		var version_str = navigator.appVersion.substr(version_pos);
		
		var test_version_str = "5.5";

		if (version_str.substr(0, test_version_str.length) == test_version_str)
		{
			return true;
		}
	}

	return false;
}



function componentRequest(query_string)
{
	// If we're using IE 5.5, all the component requests need to force
	// server-side translation, or uploading documents will not work.
	if (isIE55())
	{
		var function_begin = query_string.indexOf("f=");
		if (function_begin != -1)
		{
			function_begin += 2; // skip f=
			var function_end = query_string.indexOf("$", function_begin);
			var function_name = query_string.substr(function_begin, function_end - function_begin);
			query_string += "$" + function_name + "_fss=yes";
		}
	}

	window.location.search = query_string;
}



function showHelp(topic)
{
	var help_url = makeFullURL("?f=templates$fn=update-help.htm") + "#" + topic;

	var new_window = window.open(help_url, "DocLibHelp", "scrollbars,resizable");
	new_window.focus();
}


function formatMetadata(title, creator, subject, description)
{
	var xml = "<?xml version='1.0'?><rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:dc='http://purl.org/dc/elements/1.0/'><rdf:Description>";
	
	if (title != "")
	{
		xml += "<dc:title>" + escapeForXML(title) + "</dc:title>";
	}
	
	if (creator != "")
	{
		xml += "<dc:creator>" + escapeForXML(creator) + "</dc:creator>";
	}
	
	if (subject != "")
	{
		xml += "<dc:subject>" + escapeForXML(subject) + "</dc:subject>";
	}
	
	if (description != "")
	{
		xml += "<dc:description>" + escapeForXML(description) + "</dc:description>";
	}	
	
	xml +=	"</rdf:Description></rdf:RDF>";

	return xml;
}


function escapeForXML(data)
{
	data = data.replace(/&/g, "&amp;");
	data = data.replace(/</g, "&lt;");
	data = data.replace(/>/g, "&gt;");
	data = data.replace(/"/g, "&quot;");
	data = data.replace(/'/g, "&apos;");
	
	return data;
}
