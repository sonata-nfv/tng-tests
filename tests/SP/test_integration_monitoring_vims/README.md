
|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Monitoring VIM integration__ | |
| __Test Purpose__ | | Check the integration between monitoring manager and the VIMs| |
| __Configuration__ | | | |
| __Test Tool__ | | Robot Framework, using Tnglib| |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | |  | |
| __Applicability__ | | This test case can be performed to test if monitoring framework is setup correctly | |
| __Pre-test conditions__ | | At least one VIM has been registered to the SP| |
| __Test sequence__ | Step | Description | Result |
| | 1 | GET list of attached VIMs | VIM list received|
| | 2 | GET 'up' metric for targets | 'up' metric list received  |
| | 3 | Check each target's status | 'up' metric value should be '1'  |
| __Test Verdict__ | | All VIMs are integrated correctly | |
| __Additional resources__ | | | |