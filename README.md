#OpenJio: Capstone Project
OpenJio is an app that allows people to search for buddies for a particular activity. Users (orignal poster, or OP for short) can post an activity broadcast, say run or dinner. Interested responders can click on the broadcast and respond if they are interested. Every OP can only broadcast one activity at any one time.

This app consists of three tabs, a mapView to display activities, a tableView for Matches, and a settings view. 

The mapView displays the activities broadcast from all users filtered by the OP's search preferences. The view also includes an add button for the OP to broadcast his activity call. 

The tableView collates interested responders and display into a tableView of two sections. The top section is used to display successful matches, which the OP and interested responders mutually 'liked' each other. The second section is to display responders who are interested in the OP's activities. Tapping into the row allows the OP to 'liked' back. 

The settingsView consists of a header view which displays the OP's profile picture and name, and a tableView to allow OP to adjust his search preferences. For this project, gender and distance settings are available. Lastly, it includes a logout button. Profile picture and name are pulled from FBSDK, and the settingsView is powered by Eureka.

##Requirements
This app requires users to login using Facebook, and allow permissions for email and public profile.
Backend data are managed through Firebase. For reviewer's review purposes, the OP's location is simulated in Singapore where other simulated responders are hardcoded with areas around Singapore.
```
//Simulated user's location
let SGCoordinate = CLLocationCoordinate2DMake(1.3521, 103.8198)

```
Please also use the following test account:

email: udacity_jppzxyl_user@tfbnw.net	
pw: UdacityTest

##Tools 
The following APIs are used in this project:
```
1) Firebase
2) FBSDK
3) Eureka 2.0.0
```
