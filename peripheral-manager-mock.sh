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

# We are only interested in getting notified whenever our mock peripheral is plugged and unplugged
inotifywait -m -e create -e delete /dev |
while read -r directory event file
do
  # We assume we only care about /dev/video0
  if [[ "${file}" = "/dev/video0" ]]
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
      nuvlabox_add_peripheral ${peripheral}
    fi

    if [[ "${event}" = "DELETE" ]]
    then
      echo "EVENT: ${file} has been deleted"
      # Ask the NuvlaBox Agent to remove the mock peripheral
      nuvlabox_delete_peripheral "${mock_peripheral_identifier}"
    fi
  fi
done

nuvlabox_add_peripheral() {
  # Sends a POST request to the NuvlaBox Agent API, asking to register a new peripheral
  # $1 is the request payload, which must match the nuvlabox-peripheral resource JSON schema

  # Get the JSON payload
  payload="$1"
  echo "INFO: registering new NuvlaBox peripheral - ${payload}"

  # Make the request to the NuvlaBox Agent API
  (response=$(curl --fail -X POST http://agent/api/peripheral \
                            -H content-type:application/json  \
                            -H accept:application/json        \
                            -d "${payload}") && \
    echo "INFO: successfully registered new peripheral $(echo ${response} | jq -re '."resource-id"')") || \
    echo "ERR: could not register new peripheral! Reason: ${response}"
}

nuvlabox_delete_peripheral() {
  # Sends a DELETE request to the NuvlaBox Agent API, asking to delete a peripheral
  # $1 is the peripheral's local identifier, as passed in the original POST request

  # Get the identifier
  identifier="$1"
  echo "INFO: deleting NuvlaBox peripheral ${identifier}"

  # Make the request to the NuvlaBox Agent API
  (response=$(curl --fail -X DELETE "http://agent/api/peripheral/${identifier}" \
                            -H accept:application/json)         && \
    echo "INFO: successfully deleted peripheral ${identifier}")  || \
    echo "ERR: could not delete peripheral ${identifier}! Reason: ${response}"
}