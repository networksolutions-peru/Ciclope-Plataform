//<script type="text/javascript" src="#!-- #TEMPLATES:hit-list.js --#"></script>
function OpenHitList()
{
	var topFrame = top.document.getElementById("topFrame");
	topFrame.rows = "40, *, 180";
}

function CloseHitList()
{
	var topFrame = top.document.getElementById("topFrame");
	topFrame.rows = "40, *, 22";
}
