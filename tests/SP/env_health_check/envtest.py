import tnglib
import sys
import time
import os

# Set the environment
tnglib.set_sp_path(os.environ["SP_PATH"])

# obtain package path/name
pkg_loc = sys.argv[1]

# clean all packages
tnglib.remove_all_packages()

# upload package
upl_package = tnglib.upload_package(pkg_loc)

# Evaluate upload
if not upl_package[0]:
	print("Package upload failed")
	print(upl_package[1])
	exit(1)

print("Package upload succeeded")

# Obtain service uuid
obt_serv_uuid = tnglib.map_package_on_service(upl_package[1])

# Evaluate obtaining serv_uuid
if not obt_serv_uuid[0]:
	print("Couldn't obtain service uuid")
	print(obt_serv_uuid[1])
	exit(1)

print("Service uuid obtained")

# Instantiate the service
req_inst = tnglib.service_instantiate(obt_serv_uuid[1])

# Evaluate instantiation request
if not req_inst[0]:
	print("Couldn't obtain service uuid")
	print(req_inst[1])
	exit(1)

print("Instantiation request made")

# Waiting for instantiation to finish
counter = 0
while counter < 60:
	time.sleep(10)
	request = tnglib.get_request(req_inst[1])
	print("Waiting for instantiation, current status: " + request[1]['status'])

	if request[1]['status'] == 'READY':
		print("instantiation finished successfully")
		break

	if request[1]['status'] == 'ERROR':
		print("instantiation finished in error mode")
		exit(1)

if counter == 60:
	print("instantiation took longer than 10 minutes, aborting")
	exit(1)

service_instance_uuid = request[1]['instance_uuid']

# Terminate the service
ter_req = tnglib.service_terminate(service_instance_uuid)

print("Termination request made")

# Waiting for termination to finish
counter = 0
while counter < 12:
	time.sleep(10)
	request = tnglib.get_request(ter_req[1])
	print("Waiting for termination, current status: " + request[1]['status'])

	if request[1]['status'] == 'READY':
		print("termination finished successfully")
		break

	if request[1]['status'] == 'ERROR':
		print("termination finished in error mode")
		exit(1)

if counter == 10:
	print("termination took longer than 2 minutes, aborting")
	exit(1)

# clean all packages
tnglib.remove_all_packages()

# Test finished
print("test finished successfully")
exit(0)
