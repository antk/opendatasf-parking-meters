This is a quick and dirty script to merge the two data sets for parking meters found at SF OpenData.

###Parking Meters: 
[https://data.sfgov.org/Transportation/Parking-meters/28my-4796](https://data.sfgov.org/Transportation/Parking-meters/28my-4796)

###Meter Operating Schedule: 
[https://data.sfgov.org/Transportation/Meter-Operating-Schedules/6cqg-dxku](https://data.sfgov.org/Transportation/Meter-Operating-Schedules/6cqg-dxku)

###Usage
Download the csv's for Parking Meters and Meter Operating schedule to a folder of your choice (expected filenames are 'Parking\_meters.csv' and 'Meter\_Operating\_Schedules.csv', respectively)

Put this script in a folder with the downloaded csv's.  In the terminal, navigate to the folder with this script and the two downloaded csv's.

Run

```
$ ruby ParkingMeters.rb
```

The script basically takes what is in Meter Operating Schedule and appends data from Parking Meters to each row, matching on Post ID.

The end result will be a csv file with the following header row (the unbolded items are from Meter Operating Schedule and the __bolded__ items are from Parking Meters):

* Street and Block
* Block Side
* Post ID
* Cap Color
* Schedule Type
* Applied Color Rule
* Priority,Days Applied
* From Time
* To Time
* Active Meter Status
* Time Limit
* __STREET_NUM__
* __STREETNAME__
* __MS_ID__
* __MS_SPACEID__
* __LAT__
* __LNG__

The final output file name is 'merged-final.csv'