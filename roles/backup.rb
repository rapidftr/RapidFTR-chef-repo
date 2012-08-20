name "backup"
description "RapidFTR backup server, with CouchDB installed."
run_list(
  "recipe[apt]",
  "recipe[build-essential]",
  "recipe[erlang]",
  "recipe[couchdb]",
  "recipe[rapid_ftr::couchdb_backups]")
