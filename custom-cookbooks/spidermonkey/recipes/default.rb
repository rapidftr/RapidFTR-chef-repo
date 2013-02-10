spidermonkey_tar_gz = File.join(Chef::Config[:file_cache_path], "js185-1.0.0.tar.gz")

package "libicu-dev"
package "libcurl4-openssl-dev"
package "g++"
package "zip"
package "xulrunner-dev"

remote_file spidermonkey_tar_gz do
  source "http://ftp.mozilla.org/pub/mozilla.org/js/js185-1.0.0.tar.gz"
end

bash "install spidermonkey development libraries" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -zxf #{spidermonkey_tar_gz}
    cd js-1.8.5/js/src && ./configure && make && make install
  EOH
end
