# %%
import os
import json
import requests
from dotenv import load_dotenv

# %%
# Portainer API base URL
base_url = 'https://192.168.1.3:9443/api'

# Authentication endpoint
auth_endpoint = '/auth'

# Replace with your Portainer username and password
username = 'admin'
password = 'leminh123456'

# Create a session
session = requests.Session()

# Prepare authentication payload
auth_payload = {
    "Username": username,
    "Password": password
}

# %%
# Make the POST request to authenticate
response = session.post(f"{base_url}{auth_endpoint}", json=auth_payload,verify=False)

# Check the response status code
if response.status_code == 200:
    print("Authentication successful")

    # Parse the JSON response
    auth_data = response.json()

    # Access and print individual values
    auth_token = auth_data.get("jwt", "")
    
    print(f"Access Token: {auth_token}")

    # You can now use the session for authenticated requests
else:
    print(f"Authentication failed with status code: {response.status_code}")
    print(response.json())  # Print the response content for debugging

# %%
# Endpoint for listing all endpoints
endpoint_list_endpoint = '/endpoints'

# Create a session with the authorization header
headers = {
    'Authorization': f'Bearer {auth_token}',
}

# %%
# Make the GET request to list endpoints
response = requests.get(f"{base_url}{endpoint_list_endpoint}", headers=headers, verify=False)

# Check the response status code
if response.status_code == 200:
    print("Endpoints listed successfully")
    
    # Parse the JSON response
    endpoints_data = response.json()

    # Access and work with the endpoint data as needed
    for endpoint in endpoints_data:
        print(f"Endpoint ID: {endpoint['Id']}")
        print(f"Endpoint Name: {endpoint['Name']}")
        if endpoint['Name'] == "local":
            local_enviroment_id = f"{endpoint['Id']}"
        # Add more attributes as needed
else:
    print(f"Failed to list endpoints with status code: {response.status_code}")
    print(response.json())  # Print the response content for debugging

# %%
# Endpoint for creating a standalone stack from a file
stack_create_endpoint = '/stacks/create/standalone/file'

# Replace with your Portainer authentication token (JWT)
# auth_token = 'your_jwt_token_here'

# Replace with the name of your stack
stack_name = 'ElasticStack'

# Replace with the environment ID where you want to deploy the stack
# local_environment_id = 123  # Replace with the actual environment ID

# Prepare the request headers with the authorization token
# headers = {
#     'Authorization': f'Bearer {auth_token}',
# }

# Load environment variables from the .env file
load_dotenv()

# Read environment variables
elastic_password = os.getenv("ELASTIC_PASSWORD")
kibana_password = os.getenv("KIBANA_PASSWORD")
cluster_name = os.getenv("CLUSTER_NAME")
license = os.getenv("LICENSE")
es_port = os.getenv("ES_PORT")
kibana_port = os.getenv("KIBANA_PORT")
mem_limit = os.getenv("MEM_LIMIT")
domain_collect_logs = os.getenv("DOMAIN_COLLECT_LOGS")
ip_collect_logs1 = os.getenv("IP_COLLECT_LOGS1")
ip_collect_logs2 = os.getenv("IP_COLLECT_LOGS2")
data_es = os.getenv("DATA_ES")
certs = os.getenv("CERTS")
data_dash = os.getenv("DATA_DASH")
config_logstash = os.getenv("CONFIG_LOGSTASH")
config_dash = os.getenv("CONFIG_DASH")
config_es = os.getenv("CONFIG_ES")
stack_version = os.getenv("STACK_VERSION")

# Format environment variables as a JSON array
env_variables = [
    {"name": "ELASTIC_PASSWORD", "value": elastic_password},
    {"name": "KIBANA_PASSWORD", "value": kibana_password},
    {"name": "CLUSTER_NAME", "value": cluster_name},
    {"name": "LICENSE", "value": license},
    {"name": "ES_PORT", "value": es_port},
    {"name": "KIBANA_PORT", "value": kibana_port},
    {"name": "MEM_LIMIT", "value": mem_limit},
    {"name": "DOMAIN_COLLECT_LOGS", "value": domain_collect_logs},
    {"name": "IP_COLLECT_LOGS1", "value": ip_collect_logs1},
    {"name": "IP_COLLECT_LOGS2", "value": ip_collect_logs2},
    {"name": "DATA_ES", "value": data_es},
    {"name": "CERTS", "value": certs},
    {"name": "DATA_DASH", "value": data_dash},
    {"name": "CONFIG_LOGSTASH", "value": config_logstash},
    {"name": "CONFIG_DASH", "value": config_dash},
    {"name": "CONFIG_ES", "value": config_es},
    {"name": "STACK_VERSION", "value": stack_version},
]

# Convert the list of environment variables to a JSON string
env_json = json.dumps(env_variables)

# Prepare the request payload as multipart/form-data
payload = {
    'Name': stack_name,
    'Env': env_json,  # Use the formatted environment variables
    'endpointId': local_enviroment_id,
}

# Add the stack file to the payload
files = {
    'file': ('docker-compose.yml', open('./docker-compose.yml', 'rb'))  # Replace 'stack.yml' and 'path/to/stack.yml' with your stack file
}

# %%
# Make the POST request to deploy the stack
response = requests.post(f"{base_url}{stack_create_endpoint}", headers=headers, data=payload, files=files,verify=False)

# Check the response status code
if response.status_code == 200:
    print("Stack deployment successful")
    
    # Parse the JSON response
    stack_data = response.json()

    # Access and work with the stack data as needed
    print(f"Stack ID: {stack_data['Id']}")
    print(f"Stack Name: {stack_data['Name']}")
    # Add more attributes as needed
else:
    print(f"Failed to deploy the stack with status code: {response.status_code}")
    print(response.json())  # Print the response content for debugging


