name "default"
description "RapidFTR server, with CouchDB, Solr, and Passenger-via-Nginx installed."
run_list(
  "recipe[git]",
  "recipe[erlang]",
  "recipe[spidermonkey]",
  "recipe[couchdb::source]",
  "recipe[java::oracle]",
  "recipe[passenger::daemon]",
  "recipe[imagemagick::rmagick]"
#  "recipe[rapidftr_ssl]"
)

override_attributes({
  "couch_db" => {
    "src_version" => "1.2.1",
    "src_checksum" => "df75b03e56c2431ede7625200f0d44a7",
    "src_mirror" => "http://archive.apache.org/dist/couchdb/1.2.1/apache-couchdb-1.2.1.tar.gz",
    "install_erlang" => false
  },
  "java" => {
    "oracle" => {
      "accept_oracle_download_terms" => true
    }
  }
})
