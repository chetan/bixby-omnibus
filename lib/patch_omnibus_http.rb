
module Omnibus
  class NetFetcher < Fetcher

    def create_http_client(host, port)
      if ENV['http_proxy'] then
        proxy = URI.parse(ENV['http_proxy'])
        return Net::HTTP::Proxy(proxy.host, proxy.port).new(host, port)
      end
      return Net::HTTP.new(host, port)
    end

    # patch this method to create an http client as above
    # uses a proxy as necessary
    def get_with_redirect(url, headers, limit = 10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      log "getting from #{url} with #{limit} redirects left"

      if !url.kind_of?(URI)
        url = URI.parse(url)
      end

      req = Net::HTTP::Get.new(url.request_uri, headers)
      http_client = create_http_client(url.host, url.port)
      http_client.use_ssl = (url.scheme == "https")

      response = http_client.start { |http| http.request(req) }
      case response
      when Net::HTTPSuccess
        open(project_file, "wb") do |f|
          f.write(response.body)
        end
      when Net::HTTPRedirection
        get_with_redirect(response['location'], headers, limit - 1)
      else
        response.error!
      end
    end

  end
end
