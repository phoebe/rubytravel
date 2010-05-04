// Customer : NPS
// Version : DHTML Trigger 2.1
function cppUrlPatch(s) {
	var translated = "";
	var i; 
	var found = 0;
	for(i = 0; (found = s.indexOf(':', found)) != -1; ) {
		translated += s.substring(i, found) + "|";
		i = found + 1;
		found++;
	}
	translated += s.substring(i, s.length);
	return translated;
}
var triggerParms = new Array(); 
var excludeList = new Array();
triggerParms["dt"] = 0; // disable trigger if 1
triggerParms["mid"] = "ssIssMltZMBgYR1Rk5M5FQ=="; // model instance id
triggerParms["cid"] = "IQtYNsFQVdookhchB4BEMg=="; // customer id
triggerParms["lf"] = 4; // loyalty factor
triggerParms["sp"] = 0.4; // sample percentage
triggerParms["npc"] = 1; // no persistent cookies if 1
triggerParms["rw"] = 129600; // resample wait (value in minutes)
triggerParms["pu"] = 0; // pop-under control
triggerParms["olpu"] = 1; // On Load pop-under control
triggerParms["lfcookie"] = "ForeseeLoyalty_MID_ssIssMltZM";
triggerParms["ascookie"] = "ForeseeSurveyShown_IQtYNsFQVd";
triggerParms["width"] = 420; // survey width
triggerParms["height"] = 500; // survey height
triggerParms["domain"] = ".nps.gov"; // domain name
triggerParms["omb"] = "1505-0186"; // OMB number
//triggerParms["cmetrics"] = "90010257"; // coremetrics client id
triggerParms["cpp_1"] = "userURL:" + cppUrlPatch (window.location.href);
//triggerParms["cpp_2"] = "Browser:"+ cppUrlPatch (navigator.userAgent); // customer parameter 2 - Browser
triggerParms["capturePageView"] = 1;
//excludeList[0] = "/exclude/"; //trigger script will not work under this path
//triggerParms["midexp"] = 129600; // model instance expiry value
triggerParms["rso"]= 0; //user has chosen to use Retry Survey Option
triggerParms["aro"]= 0; //user has chosen to use Auto Retry Option, with SP=100
//triggerParms["rct"]= 1; //The maximum number of times allowed to serve a survey to a user
//triggerParms["rds"]= 1; //The minimum number of days to wait to serve a survey repeatedly
//triggerParms["mrd"]= 1; //The total number of days that a user can be re-served a survey
//DHTML Parameter
triggerParms["dhtml"]= 1;// disable dhtml trigger if dhtml=0
triggerParms["dhtmlWidth"] = 400; // welcome page width
triggerParms["dhtmlHeight"] = 290; // welcome page height
triggerParms["dhtmlURL"]= "/pollscript/FSRInvite.html";