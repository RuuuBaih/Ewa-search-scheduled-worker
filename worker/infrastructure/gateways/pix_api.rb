# frozen_string_literal: true

require 'http'

module Ewa
  module Pixnet
    # Library for Pixnet API: PoiApi, get a lists of restaurants(point of interests)
    class PoiApi
      POI_API_PATH = 'https://emma.pixnet.cc/poi?'

      def initialize(page, per_page, city, town = nil)
        @page = page
        @per_page = per_page
        @city = city
        @town = town
      end

      def poi_lists
        PoiRequest.new(POI_API_PATH, @page, @per_page, @city, @town).poi_http.parse(:json)
      end

      # Sends out HTTP requests to POI
      class PoiRequest
        def initialize(resource_root, page, per_page, city, town)
          @resource_root = resource_root
          @page = page
          @per_page = per_page
          @city = city
          @town = town
        end

        def poi_http
          request_path = if @town.nil?
                           "#{@resource_root}page=#{@page}&per_page=#{@per_page}&city=#{@city}"
                         else
                           "#{@resource_root}page=#{@page}&per_page=#{@per_page}&city=#{@city}&town=#{@town}"
                         end
          Pixnet::Request.new(request_path).get
        end
      end
    end

    # Library for Pixnet APIs: ArticleApi, search blog articles from keyword
    class ArticleApi
      ARTICLE_API_PATH = 'https://emma.pixnet.cc/blog/articles/search?'

      def initialize(page, per_page, keyword)
        @page = page
        @per_page = per_page
        @keyword = keyword
      end

      def article_lists
        ArticleRequest.new(ARTICLE_API_PATH, @page, @per_page, @keyword).article_http.parse(:json)
      end

      # Sends out HTTP requests to Pixnet blog article
      class ArticleRequest
        def initialize(resource_root, page, per_page, keyword)
          @resource_root = resource_root
          @page = page
          @per_page = per_page
          @keyword = keyword
        end

        def article_http
          Pixnet::Request.new("#{@resource_root}page=#{@page}&per_page=#{@per_page}&key=#{@keyword}").get
        end
      end
    end

    # Send requests
    class Request
      def initialize(url)
        @url = url
      end

      def get
        http_response = HTTP.get(@url)

        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end
      end
    end

    # Decorates HTTP responses from Pixnet with success/error
    class Response < SimpleDelegator
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)
      Forbidden = Class.new(StandardError)

      HTTP_ERROR = {
        401 => Unauthorized,
        404 => NotFound,
        403 => Forbidden
      }.freeze

      def successful?
        HTTP_ERROR.keys.include?(code) ? false : true
      end

      def error
        HTTP_ERROR[code]
      end
    end
  end
end
