# MeterBeaters-AllObjectiveC
Meter Beaters iOS Mobile Application in Objective-C

The data used in this application is extremely outdated. Do not rely on this data for parking.  Use at your own risk. 
=======
Back End Has Been Removed!

## Some data can be found in the /Data folder of the Repository
## Overview of Backend Data Schema mapped to function calls 

**Permit Zone Center CLLocations**

| Field     | Type         | Null | Key | Default | Extra |
|-----------|--------------|------|-----|---------|-------|
| ID        | int(11)      | NO   |     | NULL    |       |
| zone      | varchar(12)  | NO   |     | NULL    |       |
| latitude  | double(10,7) | NO   |     | NULL    |       |
| longitude | double(10,7) | NO   |     | NULL    |       |

**Cubs Games**

| Field      | Type        | Null | Key | Default | Extra |
| --------   | -------     | ---- | --  | ------  | ----  |
| index      | int(11)     | NO   | PRI | NULL    |       |
| away_team  | varchar(24) | NO   |     | NULL    |       |
| time_start | int(11)     | NO   |     | NULL    |       |
| date_nice  | varchar(12) | NO   |     | NULL    |       |
| enum       | smallint(6) | NO   |     | NULL    |       |

**Free Parking Entries Optimized for Apple Maps**

| Field         | Type          | Null | Key | Default | Extra |
|-------------- |---------------|------|-----|---------|-------|
| ID            | int(11)       | NO   |     | NULL    |       |
| StreetName    | varchar(64)   | NO   |     | NULL    |       |
| BeginLat      | double(15,12) | NO   |     | NULL    |       |
| BeginLong     | double(15,12) | NO   |     | NULL    |       |
| EndLat        | double(15,12) | NO   |     | NULL    |       |
| EndLong       | double(15,12) | NO   |     | NULL    |       |
| ParkType      | int(11)       | NO   |     | NULL    |       |
| Start         | int(11)       | NO   |     | NULL    |       |
| End           | int(11)       | NO   |     | NULL    |       |
| PermitNum     | int(11)       | NO   |     | NULL    |       |
| SportsRest    | varchar(64)   | NO   |     | NULL    |       |
| UnitedCenter  | varchar(64)   | NO   |     | NULL    |       |
| SchoolZone    | tinyint(4)    | NO   |     | NULL    |       |
| Exception     | tinyint(4)    | NO   |     | NULL    |       |
| ExceptionTxt  | varchar(255)  | NO   |     | NULL    |       |
| AreaName      | varchar(64)   | NO   |     | NULL    |       |
| ParkInsurance | float         | NO   |     | NULL    |       |
| locationid    | int(11)       | NO   |     | NULL    |       |
| StreetNum     | varchar(64)   | NO   |     | NULL    |       |
| Direction     | varchar(64)   | NO   |     | NULL    |       |

**Meter Map Entries Optimized For Apple Maps**

| Field         | Type          | Null | Key | Default | Extra |
|---------------|---------------|------|-----|---------|-------|
| ID            | int(11)       | NO   |     | NULL    |       |
| StreetName    | varchar(64)   | NO   |     | NULL    |       |
| BeginLat      | double(15,12) | NO   |     | NULL    |       |
| BeginLong     | double(15,12) | NO   |     | NULL    |       |
| EndLat        | double(15,12) | NO   |     | NULL    |       |
| EndLong       | double(15,12) | NO   |     | NULL    |       |
| ParkType      | int(11)       | NO   |     | NULL    |       |
| Start         | int(11)       | NO   |     | NULL    |       |
| End           | int(11)       | NO   |     | NULL    |       |
| PermitNum     | int(11)       | NO   |     | NULL    |       |
| SportsRest    | varchar(64)   | NO   |     | NULL    |       |
| SchoolZone    | tinyint(4)    | NO   |     | NULL    |       |
| Exception     | tinyint(4)    | NO   |     | NULL    |       |
| ExceptionTxt  | varchar(255)  | NO   |     | NULL    |       |
| AreaName      | varchar(64)   | NO   |     | NULL    |       |
| ParkInsurance | float         | NO   |     | NULL    |       |
| locationid    | int(11)       | NO   |     | NULL    |       |
| StreetNum     | varchar(64)   | NO   |     | NULL    |       |
| Direction     | varchar(64)   | NO   |     | NULL    |       |
| MeterCost     | float(10,7)   | NO   |     | NULL    |       |

**Permit Zone Map Optimized for Apple Maps**

| Field         | Type          | Null | Key | Default | Extra |
|---------------|---------------|------|-----|---------|-------|
| ID            | int(11)       | NO   |     | NULL    |       |
| StreetName    | varchar(64)   | NO   |     | NULL    |       |
| BeginLat      | double(15,12) | NO   |     | NULL    |       |
| BeginLong     | double(15,12) | NO   |     | NULL    |       |
| EndLat        | double(15,12) | NO   |     | NULL    |       |
| EndLong       | double(15,12) | NO   |     | NULL    |       |
| ParkType      | int(11)       | NO   |     | NULL    |       |
| Start         | int(11)       | NO   |     | NULL    |       |
| End           | int(11)       | NO   |     | NULL    |       |
| PermitNum     | int(11)       | NO   |     | NULL    |       |
| SportsRest    | varchar(64)   | NO   |     | NULL    |       |
| SchoolZone    | tinyint(4)    | NO   |     | NULL    |       |
| Exception     | tinyint(4)    | NO   |     | NULL    |       |
| ExceptionTxt  | varchar(255)  | NO   |     | NULL    |       |
| AreaName      | varchar(64)   | NO   |     | NULL    |       |
| ParkInsurance | float         | NO   |     | NULL    |       |
| locationid    | int(11)       | NO   |     | NULL    |       |
| StreetNum     | varchar(64)   | NO   |     | NULL    |       |
| Direction     | varchar(64)   | NO   |     | NULL    |       |


**Permit Zonage To Find What Zone you're In As Geometry Optimized for Apple Maps**

| Field      | Type         | Null | Key | Default | Extra |
|----------- |--------------|------|-----|---------|-------|
| ward       | char(80)     | YES  |     | NULL    |       |
| g          | geometry     | YES  |     | NULL    |       |
| alert_days | varchar(900) | NO   |     | NULL    |       |

**Street sweeping by ward zone and Day**

| Field       | Type         | Null | Key | Default | Extra |
|-------------|--------------|------|-----|---------|-------|
| day_val     | varchar(12)  | NO   |     | NULL    |       |
| ward_string | varchar(500) | NO   |     | NULL    |       |

**Mapping of device token to ward zone for alerts**

| Field      | Type         | Null | Key | Default | Extra |
|------------|--------------|------|-----|---------|-------|
| token      | varchar(256) | YES  |     | NULL    |       |
| ward       | char(12)     | YES  |     | NULL    |       |
| deviceType | varchar(4)   | YES  |     | NULL    |       |

**Bad Spots Reported**

| Field     | Type         | Null | Key | Default | Extra |
|-----------|--------------|------|-----|---------|-------|
| ID        | int(11)      | NO   | MUL | NULL    |       |
| Day       | int(11)      | NO   |     | NULL    |       |
| TimeBegin | int(11)      | NO   |     | NULL    |       |
| TimeEnd   | int(11)      | NO   |     | NULL    |       |
| DeviceID  | varchar(254) | NO   |     | NULL    |       |
| email     | varchar(254) | NO   |     | NULL    |       |
| date      | varchar(18)  | NO   |     | NULL    |       |

**Open Spot Information**

| Field      | Type      | Null | Key | Default           | Extra |
|------------|-----------|------|-----|-------------------|-------|
| db_id      | int(11)   | NO   | PRI | NULL              |       |
| time_stamp | timestamp | NO   |     | CURRENT_TIMESTAMP |       |
| num_spots  | int(11)   | NO   |     | NULL              |       |
| nick_spots | int(11)   | NO   |     | NULL              |       |
| max_spots  | int(11)   | YES  |     | NULL              |       |




