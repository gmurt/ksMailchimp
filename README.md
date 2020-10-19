# ksMailChimp
Delphi interface for MailChimp

This only has some basic functionality for connecting to the MailChimp API, returning a list of "Audience" lists and a method for adding contacts.  This is all I've needed for my project currently but if you need any extra functionality let me knonw.

This currently requires the JsonDataObjects.pas file from https://github.com/ahausladen/JsonDataObjects

It also requires XE8 or newer as it uses the TNetHttpClient component. 

#### Example use

See the example project for retrieving a list of "audiences" and adding a new contact to an "audience" list.