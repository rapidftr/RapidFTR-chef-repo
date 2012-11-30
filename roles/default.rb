name "default"
description "RapidFTR server, with CouchDB, Solr, and Passenger-via-Nginx installed."
run_list(
  "recipe[git]",
  "recipe[couchdb]",
  "recipe[java]",
  "recipe[passenger::daemon]",
  "recipe[rapidftr_ssl]"
)
