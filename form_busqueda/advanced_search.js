function countQueryTerms(term_list)
{
	if (term_list == "")
		return 0;

	term_count = 1;
	last_index = 0;
	while (last_index != -1 && last_index < term_list.length)
	{
		new_index = term_list.indexOf(" ", last_index);

		if (new_index - last_index >= 1)
			term_count++;

		last_index = (new_index == -1) ? new_index : new_index + 1;
	}
	return term_count;
}

function submitQuery()
{
	var positive_terms = "";
	var negative_terms = "";
	var rank_terms = "";
	
	var ui = document.ui_form;
	var request = document.request_form;

	if (ui.and.value != "")
	{
		var and_input = ui.and.value;
		positive_terms += "[and:" + and_input + "]";
		rank_terms += and_input + " ";
	}

	if (ui.phrase.value != "")
	{
		var phrase_input = ui.phrase.value;
		positive_terms += "[orderedprox,0:" + phrase_input + "]";
		rank_terms += "[orderedprox,0:" + phrase_input + "]";
	}

	if (ui.prox.value != "")
	{
		var proximity_input = ui.prox.value;
		prox_window = countQueryTerms(ui.prox.value) * 10;
		positive_terms += "[windowprox," + prox_window + ':' + proximity_input + ']';
		rank_terms += "[windowprox," + prox_window + ':' + proximity_input + ']';
	}

	var stem_positive = "";
	var stem_rank = "";
	var thesaurus_positive = "";
	var thesaurus_rank = "";

	if (stem_positive != "")
		positive_terms = stem_positive + ((thesaurus_positive != "") ? thesaurus_positive : "");
	else if (thesaurus_positive != "")
		positive_terms = thesaurus_positive;

	if (stem_rank != "")
		rank_terms = stem_rank + ((thesaurus_rank != "") ? thesaurus_rank : "");
	else if (thesaurus_rank != "")
		rank_terms = thesaurus_rank;

	var query = "";	
	if (positive_terms != "")
	{
		query = "[rank,100:" + "[domain:[or:" + positive_terms + negative_terms + "]][sum:" + rank_terms + ']]';
		request.xhitlist_s.value = "relevance-weight";
	}
	else if (negative_terms != "")
		query = negative_terms;

	//alert(query);
	request.xhitlist_q.value = query;

	if (query != "")
	{
		SetupQuery();
		request.submit();
	}
	else
		alert("Complete algun campo.");
}
 
