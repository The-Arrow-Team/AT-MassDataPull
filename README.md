# AT-MassDataPull
## SYNOPSIS
Automated collection of scripts/processes to collect data from multiple dashboards and consolidate them into a single format for viewing.

## DESCRIPTION
Calls to various API endpoints and pulls information on licensing and consolidates it into a .csv file.

Then, it prepares and sends an email through SMTP to any emails present in .\source\distribution.txt

## AUTHOR
Arrow Team | Brendon Mourao

## NOTES
Included is a ".source [sample]" folder, this includes the needed files/variables referenced in the scripts. Rename this folder to just ".source" and edit the keys in the .env file as needed.

This folder is used to build various variables witin the script and where to send the results (results are always saved locally).