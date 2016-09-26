// Tabs - tab or radio button behavior
//
// A tab group is a set of tabs, only one of which can be "on" at
// a time. This is eqivalent to radio button behavior, and can also
// be used as such. Each tab item consists of an image in an "on"
// state and an "off" state, and can be uniquely identified by its
// name.
//
// Usage Example
//
// var mainTabs = new TabGroup(document);
// mainTabs.addTab("document", "doc-on-tab.gif", "doc-off-tab.gif");
// mainTabs.addTab("results", "res-on-tab.gif", "res-off-tab.gif");
// mainTabs.setCurrentTab("document");


function TabGroup(document_object)
{
	// public
	this.addTab = TabGroup_addTab;	
	this.setCurrentTab = TabGroup_setCurrentTab;	
	this.getCurrentTab = TabGroup_getCurrentTab;
	this.firstActiveTabIs = TabGroup_firstActiveTabIs;
	this.reset = TabGroup_reset;
	
	// private
	this.items = new Array();
	this.item_count = 0;
	this.document_object = document_object;
	this.current_tab = "";
}


function TabGroup_addTab(item_name, on_image_src, off_image_src)
{
	this.items[this.item_count++] = new TabItem(item_name, on_image_src, off_image_src)
}


function TabGroup_setCurrentTab(item_name)
{
	if (this.current_tab == item_name)
	{
		return;
	}

	this.current_tab = item_name;
	
	for (var item_index = 0; item_index < this.items.length; item_index++)
	{
		for (var image_index = 0; image_index < this.document_object.images.length; image_index++)
		{
			if (this.items[item_index].name == this.document_object.images[image_index].name)
			{
				if (item_name == this.items[item_index].name)
				{
					this.document_object.images[image_index].src = this.items[item_index].on.src;
				}
				else
				{
					this.document_object.images[image_index].src = this.items[item_index].off.src;
				}
			}
		}
	}
}


function TabGroup_getCurrentTab()
{
	if (this.current_tab != "")
	{
		return this.current_tab;
	}

	for (var item_index = 0; item_index < this.items.length; item_index++)
	{
		for (var image_index = 0; image_index < this.document_object.images.length; image_index++)
		{
			if (this.items[item_index].name == this.document_object.images[image_index].name)
			{
				if (this.document_object.images[image_index].src == this.items[item_index].on.src)
				{
					return this.items[item_index].name;
				}
			}
		}
	}
	
	return "";
}


function TabGroup_firstActiveTabIs(item_name)
{
	this.current_tab = item_name;
}


function TabGroup_reset(document_object)
{
	this.current_tab = "";
	this.document_object = document_object;
}


function TabItem(item_name, on_image_src, off_image_src)
{
	this.name = item_name;
	this.on = new Image();
	this.on.src = on_image_src;
	this.off = new Image();
	this.off.src = off_image_src;
}

