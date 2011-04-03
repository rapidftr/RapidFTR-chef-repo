describe "Basic Services:" do

  describe "Nginx" do
    it "should serve the app over HTTPS" do
      response_from(:https, 443, '/login').should include(
        '<input id="user_name" name="user_name" type="text" />')
    end

    it "should redirect HTTP requests to HTTPS" do
      response_from(:http, 80, '/').should include(
        '301 Moved Permanently')
    end
  end

  describe "Solr" do
    it "should be responding"
  end

  describe "CouchDB" do
    it "should be responding" do
      response_from(:http, 5984, '/').should include(
        '"couchdb":"Welcome"')
    end
  end

  def response_from protocol, port, path
    url = "#{protocol}://localhost:#{port}#{path}"
    output = `ssh -F #{ENV['SSH_CONFIG']} vagrant "curl --insecure #{url}"`
    raise "Request failed to #{url}." unless $?.exitstatus == 0
    output
  end
end
