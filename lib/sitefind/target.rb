require 'http'
require 'net/http'
require 'resolv'
require 'yaml'

module SITEFIND
  class Target

    REDIRECT_CODES = [300, 301, 302, 303, 307, 308].to_set.freeze

    attr_reader :errors, :ssl_upgrade, :code_trail, :ip_address, :http_success, :https_success, :start_address, :end_address

    def initialize(server)
      @start_address = server.to_s
      @ip_address = nil
      @address_trail = ["http://#{@start_address}"]
      @start_path = '/'
      @next_path = @start_path
      @end_address = @address_trail.last
      @redirected = false
      @code_trail = []
      @ssl_upgrade = false
      @http_success = false
      @https_success = false
      @errors = []
      @resolver = Resolv::DNS.new(nameserver: '8.8.8.8')
    end

    def display
      self.instance_variables.map do |attribute|
        { attribute => self.instance_variable_get(attribute) }
      end
    end

    def get_ip
      begin
        @ip_address = @resolver.getaddress(@start_address).to_s
      rescue => e
        @errors << e
      end
    end

    def find_http_site

      begin
        response = HTTP.timeout(:global, :write => 5, :connect => 5, :read => 5).get(@address_trail.last)

        if response.headers["Location"].nil?
          @code_trail << response.code
          @http_success = true if @code_trail.last == 200
          return self
        end

        while REDIRECT_CODES.include? response.code
          @code_trail << response.code
          if response.headers["Location"].start_with? 'h'
            @address_trail << response.headers["Location"]
          elsif response.headers["Location"].start_with? '/'
            @next_path = response.headers["Location"]
            @address_trail << "#{@address_trail.last}#{response.headers["Location"]}"
          else
            return self
            break
          end

          response = HTTP.timeout(:global, :write => 5, :connect => 5, :read => 5).get(@address_trail.last)
        end

        @code_trail << response.code
        if REDIRECT_CODES.include? @code_trail.first
          @redirected = true
        end
        @end_address = @address_trail.last

        if @end_address.start_with? "https"
          @ssl_upgrade = true
        end

        @http_success = true if @code_trail.last == 200
        return self

      rescue => e
        @errors << e
        return self
      end
    end

    def find_https_site
      @address_trail << "https://#{@start_address}"
      begin
        ctx = OpenSSL::SSL::SSLContext.new
        ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = HTTP.timeout(:global, :write => 5, :connect => 5, :read => 5).get(@address_trail.last, :ssl_context => ctx)

        if response.headers["Location"].nil?
          @code_trail << response.code
          @https_success = true if @code_trail.last == 200
          return self
        end

        while REDIRECT_CODES.include? response.code
          @code_trail << response.code
          if response.headers["Location"].start_with? 'h'
            @address_trail << response.headers["Location"]
          elsif response.headers["Location"].start_with? '/'
            @next_path = response.headers["Location"]
            @address_trail << "#{@address_trail.last}#{response.headers["Location"]}"
          else
            return self
            break
          end

          response = HTTP.timeout(:global, :write => 5, :connect => 5, :read => 5).get(@address_trail.last, :ssl_context => ctx)
        end

        @code_trail << response.code
        if REDIRECT_CODES.include? @code_trail.first
          @redirected = true
        end
        @end_address = @address_trail.last

        if @end_address.start_with? "https"
          @ssl_upgrade = true
        end

        @https_success = true if @code_trail.last == 200
        return self

      rescue => e
        @errors << e
        return self
      end
    end

    def find_site
      self.get_ip
      if @ip_address == nil
        return self
      end
      self.find_http_site
      self.find_https_site
    end

    def output_target(data)
#      serialized = self.to_yaml
#      File.open(file, "a") do |f|
#        f.puts serialized
    end
  end
end
