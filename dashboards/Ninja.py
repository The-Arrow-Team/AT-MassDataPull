import os
import requests
from dotenv import load_dotenv
from pathlib import Path

# Get auth data 
def get_auth(envData):
    authURL = envData.get("NINJA_AUTH_ENDPOINT")
    payload = {
        "grant_type": "client_credentials",
        "client_id": envData.get("NINJA_CLIENT_ID"),
        "client_secret": envData.get("NINJA_CLIENT_SECRET"),
        "scope": "monitoring"
    }
    resp = requests.post(authURL, data=payload)
    resp = resp.json()
    authData = {
            "authToken": resp.get("access_token"),
            "ttl": resp.get("expires_in"),
            "scope": resp.get("scope"),
            "tokenType": resp.get("token_type")
        }
    return authData

# Get orgs
def get_orgs(envData, baseURL, authToken):
    endpoint = envData.get("NINJA_ORGS_ENDPOINT")
    assetsURL = f'{baseURL}{endpoint}'
    headers = {
        "Authorization": f'Bearer {authToken}',
        "Accept": "application/json"
    }
    resp = requests.get(URL=assetsURL, headers=headers)
    orgData = resp.json() 
    return orgData

# Get devices
def get_devices(envData, baseURL, authToken):   
    endpoint = envData.get("NINJA_DEVICES_ENDPOINT")
    url = f'{baseURL}{endpoint}'
    headers = {
        "Authorization": f'Bearer {authToken}',
        "Accept": "application/json"
    }
    resp = requests.get(url, headers=headers)
    deviceData = resp.json()
    return deviceData

def consolidate(orgData, deviceData):
    customerSummary = []
    orgData = sorted(orgData, key=lambda x: x["name"])
    for org in orgData:
        customerSummary.append({
            "OrgName": org["name"],
            "OrgID": org["id"],
            "DeviceCount": 0
        })
    for device in deviceData:
        deviceOrg = device.get("organizationId")
        for customer in customerSummary:
            if deviceOrg == customer["OrgID"]:
                customer["DeviceCount"] += 1
                break
    return customerSummary

# main program
if __name__ == "__main__":
    path_env = Path(__file__).resolve().parent.parent / ".source" / ".env" # Resolve path to ../.source/.env relative to this file
    load_dotenv(dotenv_path=path_env)
    envData = dict(os.environ)
    baseURL=os.getenv("NINJA_BASE_URL")
    
    authData = get_auth(envData)
    authToken = authData["authToken"]