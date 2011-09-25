# This role exists for provisioning a vagrant box
# (to jumpstart rails developers) before packaging
# it up for distribution.

name "rails_developer"
description "RapidFTR Rails dev machine."
run_list(
  "recipe[apt]",
  "recipe[build-essential]",
  "recipe[passenger::install]",
  "recipe[erlang]",
  "recipe[couchdb]",
  "recipe[git]",
  "recipe[rapid_ftr::rails_developer]")
