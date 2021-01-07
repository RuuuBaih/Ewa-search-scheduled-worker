# frozen_string_literal: true

require 'http'

module Ewa
  module CustomSearch
    # Client Library for Google Custom Search API, use a restaurant name to search for photos
    class CustomSearchApi
      # exclude images from instagram and fb (where picture urls will expire very soon)
      EXCLUDE_TERMS = "cdninstagram.com%20fbsbx.com"
      GMAP_API_PATH = "https://customsearch.googleapis.com/customsearch/v1?fileType=jpg&searchType=image&imgType=photo&excludeTerms=#{EXCLUDE_TERMS}"

      def initialize(token, rest, cx)
        @gmap_token = token
        @restaurant_name = rest
        @search_engine = cx
      end

      def search_photo
        CustomSearchRequest.new(GMAP_API_PATH, @gmap_token, @restaurant_name, @search_engine).custom_search_http.parse(:json)
      end

      # Sends out HTTP requests to Custom Search API
      class CustomSearchRequest
        def initialize(resource_root, token, rest, cx)
          @resource_root = resource_root
          @token = token
          @restaurant_name = rest
          @search_engine = cx
        end

        def custom_search_http
          CustomSearch::Request.new("#{@resource_root}&q=#{@restaurant_name}&cx=#{@search_engine}&key=#{@token}").get
        end
      end
    end

    # Send requests
    class Request
      def initialize(url)
        @url = url
        puts @url
      end

      def get
        http_response = HTTP.get(@url)

        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end
      end
    end

    # Decorates HTTP responses from GMap with success/error
    class Response < SimpleDelegator
      BadRequest = Class.new(StandardError)
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)

      HTTP_ERROR = {
        400 => BadRequest,
        401 => Unauthorized,
        404 => NotFound
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
