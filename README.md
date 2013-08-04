GeoFencer2
==========

Geofencer is a fully featured app for creating and managing GeoFences. It currently supports the following features on entering an identified region:
- email
- Wake on LAN
- Local Notification

The app runs in the background, using registration for location updates, and triggers events through the use of didUpdateToLocation, didEnterRegion and didExitRegion.

The project requires the installation of MailCore. There are are detailed instructions on the github site: https://github.com/MailCore/mailcore . Suggestion: download the project using the following commands:

git clone https://github.com/mronge/MailCore.git

git submodule update --init

While both functional and stable, this app is intended as a test platform. As a consequence, it lacks some refinements [especially for input validation in user settings] that a more complete app would implement. Some additional features not currently implemented are discussed in constants.h, which should be set with appropriate values before building.

The app uses some functionality which does not meet Apples guidelines for store submission - specifically the use of some private APIs for the WoL implementation and the sending of emails in the background.

I am distributing this source under the MIT licence, warranty free. I would be interested in feedback: mailto:appsupport@the-plot.com . Furter information will be available on my blog: http://www.the-plot.com/blog/
