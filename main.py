import os
import requests
from dotenv import load_dotenv
from pathlib import Path

# import custom functions
import validation
import sendMail
from dashboards import Cove
from dashboards import Ninja
from dashboards import O365
from dashboards import ScreenConnect
from dashboards import SentinelOne

# Load the .env file
path_env = Path(__file__).resolve().parent.parent / ".source" / ".env" # Resolve path to ../.source/.env relative to this file
load_dotenv(dotenv_path=path_env)
envData = dict(os.environ)

def writeTo_Logs():
    return

# Cove
coveAuth = Cove.get_auth()


# Ninja
ninjaURL = os.getenv("NINJA_BASE_URL")
ninjaAuthData = Ninja.get_auth(envData)
ninjaToken = ninjaAuthData["access_token"]

ninjaOrgs = Ninja.get_orgs(envData, ninjaURL, ninjaToken)
ninjaDevices = Ninja.get_devices(envData, ninjaURL, ninjaToken)

ninjaSummary = Ninja.consolidate(ninjaOrgs, ninjaDevices)


# O365
O365Auth = O365.get_auth()


# ScreenConnect
screenconnectAuth = ScreenConnect.get_auth()


# SentinelOne
sentintelAuth = SentinelOne.get_auth(envData)


# main script
if __name__ == "__main__":
    print('******************** Ninja One ********************')
    for num, org in enumerate(ninjaSummary, start=1):
        print(f'Organization number {num}: {org}')
    print('***************************************************')
    print('')
    print('******************* SentinelOne *******************')
    for :
        print()
    print('***************************************************')