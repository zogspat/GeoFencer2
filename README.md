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
