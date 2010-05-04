function callPoll()
 {
	 if ( ValidIP()== 0 ) 
	 {
		Poll();
	 }
	 
}
function ValidIP() {
		var arrRegExp = new Array();

		arrRegExp[0] = /^10\.250\.17\.[0-9]{1,3}$/
		arrRegExp[1] = /^10\.250\.16\.[0-9]{1,3}$/
		arrRegExp[2] = /^66\.82\.[0-9]{1,3}\.[0-9]{1,3}$/
		arrRegExp[3] = /^165\.83\.[0-9]{1,3}\.[0-9]{1,3}$/
		arrRegExp[4] = /^170\.215\.143\.[0-9]{1,3}$/
		arrRegExp[5] = /^192\.168\.0.[0-9]{1,3}$/
		// the follow were added by AR - 4-25
		arrRegExp[6] = /^10\.144\.[0,32]\.[0-9]{1,3}$/
		arrRegExp[6] = /^10\.14[5-9]\.[0-9]{1,3}\.[0-9]{1,3}$/
		arrRegExp[7] = /^10\.7[2,6,8]\.[0-9]{1,3}\.[0-9]{1,3}$/
		
		var intMatch = 0;
		var strIP = '<!--#echo var="REMOTE_ADDR"-->';
		for(var i = 0; i < arrRegExp.length; i++){
			if(arrRegExp[i].test(strIP)){
				intMatch = 1;
				break;
			}
		}
		return intMatch;
	}

// Customer : NPS 
// Version : DHTML Trigger 2.1
var popUpURL = "//www.foreseeresults.com/survey/display"; // base URL to the survey 
var ckAlreadyShown = triggerParms["ascookie"]; // name of the persistent/session cookie
var ckLoyaltyCount = triggerParms["lfcookie"]; // name of the loyalty count cookie
var fullURL=null;
var oldURL=null;
var fsr_browser =null;
var winOptions = "width= 1,height= 1,top= 4000,left= 4000,resizable=yes,scrollbars=yes";
var persistentExpires = new Date(); // persistent cookie expiration 
persistentExpires.setTime(persistentExpires.getTime() + (triggerParms["rw"]*60*1000));
function ForeCStdGetCookie (name) {
	var arg = name + "=";
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	while (i < clen) {
		var j = i + alen;
		if (document.cookie.substring(i, j) == arg) {
			return ForeCStdGetCookieVal (j);
		}
		i = document.cookie.indexOf(" ", i) + 1;
		if (i == 0) {
			break;
		}
	}
	return null;
}
function fsr_IEshowWindow() {
	if (eval("document.all.fsr_window").filters.revealTrans.status == 0) {
		eval("document.all.fsr_window").filters.revealTrans.transition = 23 ;
		eval("document.all.fsr_window").filters.revealTrans.Apply();
		eval("document.all.fsr_window").style.visibility = 'visible';
		eval("document.all.fsr_window").filters.revealTrans.Play();
	} else {
		eval("document.all.fsr_window").style.visibility = 'visible';
	}
}
function fsr_hideWindow() {
		if (fsr_browser=="fsr_ie"){
			if (eval("document.all.fsr_window").filters.revealTrans.status == 0)  {
				eval("document.all.fsr_window").filters.revealTrans.transition = 23;
				eval("document.all.fsr_window").filters.revealTrans.Apply();
				eval("document.all.fsr_window").style.visibility = 'hidden';
				eval("document.all.fsr_window").filters.revealTrans.Play();
			} else {
				eval("document.all.fsr_window").style.visibility = 'hidden';
			}
		} else {
			document.getElementById("fsr_window").style.visibility = 'hidden';
		}
}
function fsr_showWindow() {
	document.getElementById("fsr_window").style.visibility = 'visible';
}
function ForeCStdSetCookie (name, value) {
	var argv = ForeCStdSetCookie.arguments;
	var argc = ForeCStdSetCookie.arguments.length;
	var expires = (argc > 2) ? argv[2] : null;
	var path = (argc > 3) ? argv[3] : null;
	var domain = (argc > 4) ? argv[4] : null;
	var secure = (argc > 5) ? argv[5] : false;
	document.cookie = name + "=" + escape (value) +
	((expires == null) ? "" : ("; expires=" + expires.toGMTString())) +
	((path == null) ? "" : ("; path=" + path)) +
	((domain == null) ? "" : ("; domain=" + domain)) +
	((secure == true) ? "; secure" : "");
}
function ForeCStdGetCookieVal(offset) {
	var endstr = document.cookie.indexOf (";", offset);
	if (endstr == -1) {
		endstr = document.cookie.length;
	}
	return unescape(document.cookie.substring(offset, endstr));
}
function specialEscape(str) {
	var translated = "";
	var i; 
	var found = 0;
	for(i = 0; (found = str.indexOf('+', found)) != -1; ) {
		translated += str.substring(i, found) + "%2B";
		i = found + 1;
		found++;
	}
	translated += str.substring(i, str.length);
	return translated;
}
function Pop(){
	var myPopUp = window.open(fullURL, 'survey',winOptions);
	if (  myPopUp && myPopUp.open && !myPopUp.closed) {
		if (triggerParms["pu"] == 1){
			self.focus();
		} else {
			myPopUp.focus(); 							
		}
	}
}
function checkMAC(){
	if(navigator.platform.indexOf("Win32") >= 0){
		return false;
	} else {
		return true;
	}	
}
function currentLocationExcluded() {	
	var parentURLPath = window.location.pathname;//location path
	for(key in excludeList) {
		if(parentURLPath.indexOf(excludeList[key]) != -1) {
			return true;
		}
	}
	return false;
}
function Poll() { 
	if(triggerParms["dt"] == 1) {
		return;
	}
	if(currentLocationExcluded()) {
		return;
	}
	var stickyCounter = ForeCStdGetCookie(ckLoyaltyCount); // check counter cookie
	var alreadyShown = ForeCStdGetCookie(ckAlreadyShown); // check if we already have shown survey
	var pageCount;
	var randNum = Math.random();
	randNum *= 100;
	if (stickyCounter == null) {
		pageCount = 1; 
		ForeCStdSetCookie(ckLoyaltyCount, pageCount, null,'/',triggerParms["domain"]);
		stickyCounter = ForeCStdGetCookie(ckLoyaltyCount);
	}
	if (stickyCounter != null) {
		pageCount = stickyCounter;
		if(pageCount >= triggerParms["lf"]) {
			if(alreadyShown == null) {
				if (triggerParms["rso"] == 1 && triggerParms["aro"] == 1) {
					triggerParms["sp"] = 100.0; // Update Ssample percentage
				}
				if(randNum <= triggerParms["sp"]) {
					var fsr_mac= checkMAC();
					fsr_browser="fsr_nn6";
					if(document.all){ 
						fsr_browser = "fsr_ie";
					}
					if(document.layers) {
						fsr_browser = "fsr_nn";
					}
					fullURL = popUpURL + "?" + "width=" + triggerParms["width"] +
					"&height=" + triggerParms["height"] +
					"&cid=" + specialEscape(escape(triggerParms["cid"])) + "&mid=" + specialEscape(escape(triggerParms["mid"]));
					if ((triggerParms["omb"] ) != null) {
						fullURL += "&omb=" + escape(triggerParms["omb"]);
					}
					if ((triggerParms["cmetrics"] ) != null) {
						fullURL += "&cmetrics=" + escape(triggerParms["cmetrics"]);
					}
					if (triggerParms["olpu"] == 1) {
						fullURL += "&olpu=1";
					}
					if (triggerParms["rso"] == 1) {
						fullURL += "&rso=1&rct=" + triggerParms["rct"] + "&rds=" + triggerParms["rds"] + "&mrd=" + triggerParms["mrd"] + "&rws=" + triggerParms["rw"];
					}
					if (triggerParms["capturePageView"] == 1) {
						triggerParms["cpp_3"] = "PageView:"+ pageCount; // customer parameter 3 - Page View
					}
					if ((triggerParms["midexp"] ) != null) {
						fullURL += "&ndc=1&fsexp=5256000&midexp=" + triggerParms["midexp"];
					}
					var customerParams = "";
					for(paramKey in triggerParms) {
						if(paramKey.substring(0,3) == "cpp"){
							fullURL += "&" + paramKey + "=" + escape(triggerParms[paramKey]);
						}
					}	
					oldURL=fullURL;
					fullURL+= "&cpp_4=" + escape("popupStats:window=normal browser="+fsr_browser+" mac="+ fsr_mac);
					if (triggerParms["rso"] != 1) {
						if(triggerParms["npc"] == 1) {
							ForeCStdSetCookie(ckAlreadyShown, 'true',null,'/',triggerParms["domain"]);
						} else {
							ForeCStdSetCookie(ckAlreadyShown, 'true', persistentExpires,'/',triggerParms["domain"]);
						}
					}
					var myPopUp = window.open(fullURL, 'survey',winOptions);
					if (  myPopUp && myPopUp.open && !myPopUp.closed) {
						if (triggerParms["pu"] == 1){
							self.focus();
						} else {
							myPopUp.focus(); //focusing on survey window								
						}
					} else {
						if (fsr_mac==false && (fsr_browser != "fsr_nn") && (triggerParms["dhtml"] == 1)) {
							fullURL=oldURL;
							fullURL+= "&cpp_4=" + escape("popupStats:window=dhtml browser="+fsr_browser+" mac="+ fsr_mac);
							fsr_sw = screen.width;
							fsr_sh = screen.height;
							fsr_left = (fsr_sw -triggerParms["dhtmlWidth"])/2;
							fsr_top =Math.min((fsr_sh - triggerParms["dhtmlHeight"])/2,150);
							document.write( "<div id=\"fsr_window\" style=\"position:absolute; width:1px; height:1px; z-index:1; left:"+fsr_left+"px; top:"+fsr_top+"px; visibility: hidden; filter:revealTrans(Duration=0.5, Transition=23);\" >"
							+"<table border=\"1\" cellspacing=\"0\" cellpadding=\"0\" bgcolor=\"#CCCCCC\"><tr><td>" 
							+"<iframe id=\"cframe\" src="+"\""+triggerParms["dhtmlURL"]+"?fullURL="+fullURL+"\" width="+triggerParms["dhtmlWidth"]+" height="+triggerParms["dhtmlHeight"]+"></iframe>"
							+"</td></tr></table>"
							+"</td></tr></table></div>");
							if (fsr_browser == "fsr_ie") {
								fsr_IEshowWindow();
							} else {
								fsr_showWindow();
							}
						}
					}
				}
			}
		}	
		pageCount++;
		ForeCStdSetCookie(ckLoyaltyCount, pageCount, null,'/',triggerParms["domain"]);		
	}
}
