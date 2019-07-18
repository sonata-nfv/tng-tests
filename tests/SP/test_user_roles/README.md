<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Testing User Management Roles__ | |
| __Test Purpose__ | | Validate the permissions of the different user roles.| |
| __Configuration__ | | Register three differentuser roles, try to fetch the different 5GTANGO descriptors and validate he permissions.| |
| __Test Tool__ | | Robot - tnglib | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-gtk-usr | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD: - Use different License type | |
| __Pre-test conditions__ | | One admin user should exist at least with the following credentials: username: tango password:admin | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Login as admin user| One user should be logged-in in order to create and delete other users|
| | 2 | Register a new user with a role | The new user can be admin, developer or customer. NOTE: In order to register an admin, the logged-in user should be an admin|
| | 3 | Logout initial user |  |
| | 4 | Loggin the new user | Log in the new user to validate the permissions |
| | 5 | Obtain services | Validate the role permissions trying to obtain the services |
| | 6 | Obtain SLAs | Validate the role permissions trying to obtain the SLAs |
| | 7 | Obtain policies | Validate the role permissions trying to obtain the policies |
| | 8 | Obtain slices | Validate the role permissions trying to obtain the slices |
| | 9 | Log out the new user | |
| | 10 | Delete the new user | |

| __Test Verdict__ | | If no error appeared in all actions the test is succesfully past.|
| __Additional resources__ | | | |
