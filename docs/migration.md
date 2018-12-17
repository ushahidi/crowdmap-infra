# Migration playbooks

Migration from Rackspace to AWS can be done using the `snapshot-restore.yml` playbook.

This works similarly to the snapshot/restore process when migrating ushahidi.io to AWS.

## Where?

The playbooks are deployed the the AWS jump box already (ansible-jump-staging.aws.ushahidi.com)

## Background

- Databases for Crowdmap Classic are on two separate DB servers, so we have to snapshot these separately
- The snapshots cannot be used as a backup because the s3 bucket will expire files after 3 days

## Prep:

- Disable existing Crowdmap servers ie. take down the web UI
- Ensure the cron scheduler is not running on Crowdmap Classic deployments
- The migrations run from lists of deployments, you need to prep these separately for each DB server.
    - Run the python script to grab deployments by number of incidents / logins
    - Match these against mhi_site + mhi_site_database in the crowdma_main db to find which server they are on

## Playbook options:

- `deployments_file` - a new line separated list of deployment subdomains
- `skip_main_db` - a flag to skip importing the crowdma_main db. Useful so you can import additional deployments without wiping the main db
- `snapshot_name` - the name of the snapshot to restore
- Tags: `snapshot` to snapshot, `restore` to restore

## Running the migration:

1. Snapshot deployments from the first server

    `ansible-playbook snapshot-restore.yml -e "deployments_file=deployments-1" -l crowdmap-rs-db1 -vv -t snapshot`

2. Restore deployments

    `ansible-playbook snapshot-restore.yml -e "deployments_file=deployments-1" -l web -vv -t restore -e "snapshot_name=crowdmap-rs-2018-10-16T03:30:03Z"`

3. Snapshot from the second server

    `ansible-playbook snapshot-restore.yml -e "deployments_file=deployments-2" -l crowdmap-rs-db2 -vv -t snapshot -e "skip_main_db=1"`

4. Restore deployments
    
    `ansible-playbook snapshot-restore.yml -e "deployments_file=deployments" -l web -vv -t restore -e "snapshot_name=crowdmap-rs-2018-10-16T03:30:03Z" -e "skip_main_db=1"`
    
## Clean up

- If we're only migrating some deloyments, we need to remove or disable the others in mhi_site 
