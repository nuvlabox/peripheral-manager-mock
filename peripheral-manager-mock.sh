#!/bin/sh

# NAME: NuvlaBox Peripheral Manager Mock
# DESCRIPTION: Mock peripheral manager for demonstration purposes only
# ARGS: none

# ---
# ASSUMPTION 1: our mock peripheral is a video device
# ASSUMPTION 2: when our mock peripheral is plugged, the file /dev/video0 is created
# ASSUMPTION 3: the identifier for our mock peripheral is always the same.
# IMPORTANT: assumption 3 should NOT be considered in real scenarios.
#            Make sure you infer the peripheral identifier dynamically, to avoid conflicts between peripherals
mock_peripheral_identifier="my-mock-peripheralXYZ"


####
# NuvlaBox Agent API functions
# These are generic, so you can re-use them everywhere
####
nuvlabox_add_peripheral() {
  # Sends a POST request to the NuvlaBox Agent API, asking to register a new peripheral
  # $1 is the request payload, which must match the nuvlabox-peripheral resource JSON schema

  # Get the JSON payload
  payload="$1"
  echo "INFO: registering new NuvlaBox peripheral - ${payload}"

  agent_api="http://agent/api/peripheral"
  headers="-H content-type:application/json -H accept:application/json"

  # Make the request to the NuvlaBox Agent API
  response=$(curl -X POST ${agent_api} ${headers} -d "${payload}" --write-out "%{http_code}")

  # Extract the response and http code
  http_code=$(echo ${response} | awk '{print $NF}')
  output=$(echo ${response} | awk '{$NF=""; print $0}')

  if [[ "${http_code}" = "201" ]]
  then
    echo "INFO: successfully registered new peripheral $(echo ${output} | jq -re '."resource-id"')"
  else
    echo "ERR: could not register new peripheral! Reason: ${response}"
  fi
}

nuvlabox_delete_peripheral() {
  # Sends a DELETE request to the NuvlaBox Agent API, asking to delete a peripheral
  # $1 is the peripheral's local identifier, as passed in the original POST request

  # Get the identifier
  identifier="$1"
  echo "INFO: deleting NuvlaBox peripheral ${identifier}"

  agent_api="http://agent/api/peripheral"
  headers="-H accept:application/json"

  # Make the request to the NuvlaBox Agent API
  response=$(curl -X DELETE "${agent_api}/${identifier}" ${headers} --write-out "%{http_code}")

  # Extract the response and http code
  http_code=$(echo ${response} | awk '{print $NF}')
  output=$(echo ${response} | awk '{$NF=""; print $0}')

  if [[ "${http_code}" = "200" ]]
  then
    echo "INFO: successfully deleted peripheral ${identifier}"
  else
    echo "ERR: could not delete peripheral ${identifier}! Reason: ${response}"
  fi
}
####
# End of NuvlaBox Agent API functions
####


######
# MAIN
######

# We are only interested in getting notified whenever our mock peripheral is plugged and unplugged
inotifywait -m -e create -e delete /dev |
while read -r directory event file
do
  # We assume we only care about /dev/video0
  if [[ "${file}" = "video0" ]]
  then
    # If the mock peripheral was plugged in, then we want to register the new NuvlaBox peripheral
    # otherwise, we want to remove it
    if [[ "${event}" = "CREATE" ]]
    then
      echo "EVENT: ${file} has been created"
      # A new mock peripheral has been plugged, so let's categorize it
      # TIP: check the API documentation in Nuvla for a full representation of the supported peripheral schema
      peripheral="{
        \"identifier\": \"${mock_peripheral_identifier}\",
        \"classes\": [\"video\"],
        \"available\": true,
        \"name\": \"Mock Peripheral\"
      }"

      # Ask the NuvlaBox Agent to register the new mock peripheral
      nuvlabox_add_peripheral "${peripheral}"
    fi

    if [[ "${event}" = "DELETE" ]]
    then
      echo "EVENT: ${file} has been deleted"
      # Ask the NuvlaBox Agent to remove the mock peripheral
      nuvlabox_delete_peripheral "${mock_peripheral_identifier}"
    fi
  fi
done

