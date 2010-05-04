//--------------------------------------------------------------------------------
// JavaScript Document
//
// Authors:		Sunny Kalsi / InfoReliance Inc
// Date:		April 08, 2005
// File:		nps.js
// Notes:		Main javascript file for NPS.gov
// Modification Log:
// Change#		Date		Author		        Remarks				
// --------------------------------------------------------
// 01			9/14/2009	Andy Reid			Updated code to have doMenu work in FFX.  IE4- support deprecated.
// 02			10/16/2009	Andy Reid			Further edited to make FFX compatible.
//
//--------------------------------------------------------------------------------

//window.onerror = function() {return true;}
function doCatch(o) {
	alert(o.name);
}
//window.onerror = doCatch(this);







//*(D)*//
function onclickH(e)
{
	var alert_string = "Event model: "+emod+"\n";
	var interceptURLStr = "http://cms.nps.gov/nps/r.htm?q=";
	var interceptPage = "/nps/r.htm";
	//alert(alert_string);
	switch (emod)	{
		case "NN4":
			switch (window.location.href.indexOf(interceptPage))	{
				case -1:
					if (e.target.href) {
						alert_string += "clientX: "+e.clientX+"\n";
						alert_string += "clientY: "+e.clientY+"\n";
						alert_string += "target.href: "+e.target.href+"\n";
						if (e.target.href.indexOf("javascript:")==-1 && e.target.href.indexOf("doDisplayOptionsMenu")==-1  && (e.target.href.indexOf(".nps.gov")==-1 || e.target.href.indexOf("nps.gov")==-1)) {
							e.target.href = interceptURLStr + e.target.href;
						}						
						alert_string += "REDIRECTED target.href "+e.target.href+"\n";							
						alert_string += "target.text: "+e.target.text+"\n"; 
						alert_string += "type: "+e.type+"\n";							
					}
				break;
				// any other case and it'll default to the std URL link w/o any redirection
			}				
			break;
			
		case "W3C":
			switch (window.location.href.indexOf(interceptPage))	{
				case -1:
					if (e.target.href) {
						alert_string += "clientX: "+e.clientX+"\n";
						alert_string += "clientY: "+e.clientY+"\n";
						alert_string += "target.href: "+e.target.href+"\n";
						if (e.target.href.indexOf("javascript:")==-1 && e.target.href.indexOf("doDisplayOptionsMenu")==-1  && (e.target.href.indexOf(".nps.gov")==-1 || e.target.href.indexOf("nps.gov")==-1)) {
							e.target.href = interceptURLStr + e.target.href;
						}						
						alert_string += "REDIRECTED target.href "+e.target.href+"\n";							
						alert_string += "target.text: "+e.target.text+"\n"; 
						alert_string += "type: "+e.type+"\n";							
					}
				break;
				// any other case and it'll default to the std URL link w/o any redirection
			}				
			break;
			
		case "IE4+":
			/* (E) */
			e = window.event;
			
			if (navigator.appName=="Netscape" && e.target.nodeType==3){ //if safari and user clicked on a link
				var urlStr = e.target.parentNode.toString();
				
				if (e.target.parentNode && !e.target.parentNode.toString().toLowerCase().indexOf(interceptPage)) {
					alert_string += "clientX: "+e.clientX+"\n";
					alert_string += "clientY: "+e.clientY+"\n";
					alert_string += "target.parentNode (before)"+e.target.parentNode+"\n";
				
					if (urlStr.indexOf("javascript:")==-1 && urlStr.indexOf("doDisplayOptionsMenu")==-1 && (urlStr.indexOf(".nps.gov")==-1 || urlStr.indexOf("nps.gov")==-1)) {
						e.target.href = interceptURLStr + urlStr;
						e.target.parentNode = e.target.href;
					}						
					alert_string += "target.parentNode (after)"+e.target.parentNode+"\n";					
					alert_string += "REDIRECTED e.target.href "+e.target.href+"\n";			
					alert_string += "target.innerText "+e.target.innerText+"\n";			
					alert_string += "target.text: "+e.target.text+"\n"; 					
					alert_string += "type: "+e.type+"\n";
				}								
					alert(alert_string);
			} else { //else IE
				urlStr=e.srcElement.href;
				
				switch (window.location.href.indexOf(interceptPage))	{
					case -1:
						if (urlStr) {
							alert_string += "clientX: "+e.clientX+"\n";
							alert_string += "clientY: "+e.clientY+"\n";
							alert_string += "target.href: "+e.srcElement.href+"\n";
							if (e.srcElement.href.indexOf("javascript:")==-1 && e.srcElement.href.indexOf("doDisplayOptionsMenu")==-1  && (e.srcElement.href.indexOf(".nps.gov")==-1 || e.srcElement.href.indexOf("nps.gov")==-1)) {
								e.srcElement.href = interceptURLStr + e.srcElement.href;
							}						
							alert_string += "REDIRECTED target.href "+e.srcElement.href+"\n";							
							alert_string += "target.text: "+e.srcElement.text+"\n"; 
							alert_string += "type: "+e.type+"\n";							
						}
					break;
					// any other case and it'll default to the std URL link w/o any redirection
				}			
			}			
			
			break;
			
		case "unknown":
			/* (E) */
			switch (window.location.href.indexOf(interceptPage))	{
				case -1:
					if (e.target.href) {
						alert_string += "clientX: "+e.clientX+"\n";
						alert_string += "clientY: "+e.clientY+"\n";
						alert_string += "target.href: "+e.target.href+"\n";
						if (e.target.href.indexOf("javascript:")==-1 && e.target.href.indexOf("doDisplayOptionsMenu")==-1  && (e.target.href.indexOf(".nps.gov")==-1 || e.target.href.indexOf("nps.gov")==-1)) {
							e.target.href = interceptURLStr + e.target.href;
						}						
						alert_string += "REDIRECTED target.href "+e.target.href+"\n";							
						alert_string += "target.text: "+e.target.text+"\n"; 
						alert_string += "type: "+e.type+"\n";							
					}
				break;
				// any other case and it'll default to the std URL link w/o any redirection
			}			
			break;
			
	}
	
	//alert(alert_string);
	return true;
}

function onloadH(e)
{
	//*(A)*//
	emod = (e) ? (e.eventPhase) ? "W3C" : "NN4" : (window.event) ? "IE4+"  : "unknown";

	//*(B)*//
	if (emod == "NN4") {
		document.captureEvents(Event.CLICK);
	}
	
	//*(C)*//
	//document.onclick = onclickH;
	return true;
}

//global vars
var emod; //the event model

//define the event handler for the onload event

function onloadfx() {
	if (!menus_included || !js_userID) {	onloadH();	}

}


//if (!js_userID) {	onloadH();	}	


//used in the Navigation, DidYouKnows's, Highlights, Page Picture....
function openCustomWindow(newURL) {
	var w = 800, h = 600;
	if (document.all || document.layers)
	{
	  w = screen.availWidth;
	  h = screen.availHeight;
	}
	var popW = 800, popH = 600;
	var leftPos = (w-popW)/2, topPos = (h-popH)/2;
	newCustomWindow = window.open(newURL,'popup','width=' + popW + ',height=' + popH + ',top=' + topPos + ',left=' + leftPos + ',scrollbars=yes' + ',resizable=yes');
	newCustomWindow.opener = window;
	newCustomWindow.focus();
}

// Used in Redirect App
function openRedirectWindow(newURL) {
	var w = 500, h = 660;
	if (document.all || document.layers)
	{
	  w = screen.availWidth;
	  h = screen.availHeight;
	}
	var popW = 500, popH = 660;
	var leftPos = (w-popW)/2, topPos = (h-popH)/2;
	newCustomWindow = window.open(newURL,'popup','width=' + popW + ',height=' + popH + ',top=' + topPos + ',left=' + leftPos + ',scrollbars=no' + ',resizable=yes');
	newCustomWindow.opener = window;
	newCustomWindow.focus();
}

// Used in Akamai Purge App
function openPurgeWindow(newURL) {
	var w = 700, h = 300;
	if (document.all || document.layers)
	{
	  w = screen.availWidth;
	  h = screen.availHeight;
	}
	var popW = 700, popH = 340;
	var leftPos = (w-popW)/2, topPos = (h-popH)/2;
	newCustomWindow = window.open(newURL,'popup','width=' + popW + ',height=' + popH + ',top=' + topPos + ',left=' + leftPos + ',scrollbars=no' + ',resizable=yes');
	newCustomWindow.opener = window;
	newCustomWindow.focus();
}

//pencil icon edit buttons for custom apps.
function doNavMenu(dlgloader,pageid,event)
{
	//alert(jsUserID);
	if (jsUserID == '1000284') {
//		alert(event);
//		if (document.all) {alert('ie')} else {alert('not ie')};
//		(document.all) ? thisMenu = document.all("NavMenu") : thisMenu = document.getElementById("NavMenu",event);
//		var thisMenu = document.getElementById("NavMenu",event);
//		var thisMenu = document.all("NavMenu");
//		alert(thisMenu);
		var thisMenu = document.getElementById("navMenu");
		calcMenuPos ("NavMenu", event);
		event.returnValue = false;		
	} else {
		//var thisMenu = document.getElementById("navMenu");
		/*var thisMenu = document.all("NavMenu");
		calcMenuPos ("NavMenu",event);
		window.event.returnValue = false;*/
		var thisMenu = document.getElementById("navMenu");
		calcMenuPos ("NavMenu", event);
		window.event.returnValue = false;		
	}
}

function redirectScript(yurl) {
	if (!js_userID) { //to prevent redirection from occuring while you are logged into the CMS
		document.location.href = yurl;
	}
}



