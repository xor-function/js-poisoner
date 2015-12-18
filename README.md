# js-poisoner
###Tampering with CDN's over the wire

This takes an advantage of the inherent vulnerabilities 
of network structures. Which demonstrates the importance 
of encrypting Internet traffic.

This is composed of a squid3 setup script and url rewrite program
along with some javascript code that is designed to add undesired
functionality to a website. By default an iframe is appended to a
target web page as an example.


Method of Use

Note: This will not work against encrypted traffic,
but can work against https sites that pull js scripts over 
regular http.

This makes use of a web caching proxy (squid3) to tamper with
urls belonging javascript libraries via a url rewrite program.

The url must be selected manually after inspecting the html source
of a target webpage, look for scripts hosted on remote domains.
Copy it's link then download the .js file specified, through a
web browser or with curl/wget.

Then modify the contents of js-poisoner to suit your needs and
append the contents of poisoner.js to the downloaded js file.

Place the moded js file in the public_html or /var/www web root of a
web server and change to appropriate permissions so that it's
publicly downloadable.

The link/url that points to the script is what you are going to
set as a filter (regex) for the rewrite script included.

Also will have to input the modified scripts url/domain in the
rewrite program so that this replaces the original url upon
regex match.

