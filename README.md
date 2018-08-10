### Prerequisites

A clean Ubuntu 16.04 machine, minimum 2 vCPUs, 16GB of RAM, 50GB storage.

### QuickStart Guide

Bootstrap the installation by running the following commands as root:
```
WHERE_THE_ORCHESTRATOR_IS='https://github.com/Morphl-Project/MorphL-Orchestrator'
WHERE_THE_SOFTWARE_IS='https://github.com/Morphl-Project/Sample-Code'

apt update -qq && apt -y install git ca-certificates
git clone ${WHERE_THE_ORCHESTRATOR_IS} /opt/orchestrator
git clone ${WHERE_THE_SOFTWARE_IS} /opt/samplecode
bash /opt/orchestrator/bootstrap/runasroot/rootbootstrap.sh

```
The installation process is fully automated and will take a while to complete (20-30 minutes).

Once the installation is done, check the bottom of the output to see the if the status `The installation has completed successfully.` has been reported.

At this point a few more setup steps are necessary.

### Provide your key file and view ID

From the root prompt, log into `airflow`:
```
su - airflow
```
Paste your key file into `/opt/secrets/keyfile.json` and your view ID into `/opt/secrets/viewid.txt`, possibly using syntax like this:
```
cat > /opt/secrets/keyfile.json << EOF
{
...supersecretkeyfilecontents...
}
EOF

cat > /opt/secrets/viewid.txt << EOF
123123456456123123
EOF
```
Log out of `airflow` and back in again, and verify that your key file and view ID have been configured correctly:
```
cat /opt/secrets/keyfile.json

echo ${VIEW_ID}
```
If the output of `echo ${VIEW_ID}` is empty, like this:
```
VIEW_ID=
```
it means you have forgotten to log out of `airflow` and back in again.

### Load historical data

Run the command:
```
load_historical_data.sh
```
You should see a prompt that looks like this:
```
How much historical data should be loaded?

1) 2018-08-04 - present time (5 days worth of data)
2) 2018-07-30 - present time (10 days worth of data)
3) 2018-07-10 - present time (30 days worth of data)
4) 2018-06-10 - present time (60 days worth of data)
5) 2018-04-11 - present time (120 days worth of data)
6) 2018-02-10 - present time (180 days worth of data)
7) 2017-11-12 - present time (270 days worth of data)
8) 2017-08-09 - present time (365 days worth of data)

Select one of the numerical options 1 thru 8:
```
Once you select an option, you should see output like this:
```
Emptying the relevant Cassandra tables ...

Initiating the data load ...

The data load has been initiated.
```
Open [http://PUBLIC_SERVER_IP:8181/admin/](http://PUBLIC_SERVER_IP:8181/admin/) in a browser.  
`PUBLIC_SERVER_IP` is the Internet-facing IP address of the Ubuntu machine.  
You should be able to get this IP address from your cloud management interface or by running:
```
dig +short myip.opendns.com @resolver1.opendns.com
```
With user name `airflow` and the password found with:
```
env | grep AIRFLOW_WEB_UI_PASSWORD
```
log into Airflow's web UI.

Keep refreshing the UI page until all the data for the number of days you specified previously, has been loaded into Cassandra.

### Miscellaneous

Should you need the connection details for Cassandra, the user name is `morphl` and you can find the password with:
```
env | grep MORPHL_CASSANDRA_PASSWORD
```
