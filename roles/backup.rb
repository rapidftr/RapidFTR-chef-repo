name "backup"
description "RapidFTR backup server, with CouchDB, Solr, and Passenger-via-Nginx installed. Replicates data from a main server."
run_list(
  "recipe[apt]",
  "recipe[build-essential]",
  "recipe[erlang]",
  "recipe[couchdb]",
  "recipe[git]",
  "recipe[rapid_ftr::couchdb_backups]",
  "recipe[passenger::daemon]")
