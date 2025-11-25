import os
import requests
from dotenv import load_dotenv
from pathlib import Path

# Get auth data
def test_auth(envData):
    apiKey = envData.get("SENTINEL_API_KEY")
    headers = {
        "Authorization": f'ApiToken {apiKey}',
        "Content-Type": "application/json"
    }
    try: 
        resp = requests.get(f'{envData.get("SENTINEL_BASE_URL")}system/status', headers=headers)
        resp.raise_for_status()
        return resp
    except requests.exceptions.RequestException as e:
        print(f"Authentication test failed: {e}")
        return None

def get_sites(envData):
    apiKey = envData.get("SENTINEL_API_KEY")
    headers = {
        "Authorization": f'ApiToken {apiKey}',
        "Content-Type": "application/json"
    }
    sites = requests.get(f'{envData.get("SENTINEL_BASE_URL")}sites', headers=headers)
    sites = sites.json()
    return sites

def get_assets(envData):
    apiKey = envData.get("SENTINEL_API_KEY")
    assetsURL = envData.get("SENTINEL_BASE_URL") + envData.get("SENTINEL_AGENTS_ENDPOINT")
    headers = {
        "Authorization": f'ApiToken {apiKey}',
        "Content-Type": "application/json"
    }
    params = {
        "isActive": True
    }
    resp = requests.get(assetsURL, headers=headers, params=params)
    assetData = resp
    return assetData

def consolidate():
    customerSummary = []
    return customerSummary

if __name__ == "__main__":
    path_env = Path(__file__).resolve().parent.parent / ".source" / ".env" # Resolve path to ../.source/.env relative to this file
    load_dotenv(dotenv_path=path_env)
    envData = dict(os.environ)
    
    authTest = test_auth(envData)
    print(authTest)
    
    print(get_assets(envData))