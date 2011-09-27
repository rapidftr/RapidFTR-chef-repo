describe "Basic Services:" do

  describe "Nginx" do
    it "should serve the app over HTTPS" do
      r = response_from(:https, 443, '/login')
      r['code'].should == '200'
      r['body'].should match(/input id="user_name"/)
    end

    it "should redirect HTTP requests to HTTPS" do
      r = response_from(:http, 80, '/')
      r.should include('code' => '301')
      r['location'].first.should match(/^https:/)
    end
  end

  describe "Rails" do
    it "should write logs to production.log" do
      logs_written = check_for_file "/srv/rapid_ftr/shared/log/production.log"
      logs_written.should be_true
    end
  end

  describe "Solr" do
    it "should be responding" do
      response_from(:http, 8902, '/solr/')['body'].should include(
        'Welcome to Solr')
    end
  end

  describe "CouchDB" do
    it "should be responding" do
      response_from(:http, 5984, '/')['body'].should include(
        '"couchdb":"Welcome"')
    end

    describe "seeding" do
      it "should allow login as the rapidftr user"
      it "should have created the default forms"
    end
  end

  def response_from protocol, port, path
    url = "#{protocol}://localhost:#{port}#{path}"
    remote_ruby = <<-EOF
      require 'net/https'
      require 'uri'

      uri = URI.parse('#{url}')
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true if uri.scheme == 'https'
      begin
        response = http.get uri.path
        p response.to_hash.merge('code' => response.code, 'body' => response.body)
      rescue Exception => e
        puts %(\#{e.class}: \#{e.message})
        exit 1
      end
    EOF
    output = `ssh -q #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "ruby -e \\"#{remote_ruby}\\""`
    raise "Request failed to #{url}.\nOutput: #{output}" unless $?.exitstatus == 0
    eval output
  end

  def check_for_file file_path
    output = `ssh -q #{ENV['SSH_OPTIONS']} #{ENV['SSH_HOST']} "[ -f #{file_path} ]"`
    $?.exitstatus == 0
  end
end
