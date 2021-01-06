# frozen_string_literal: true

require 'http'

module Ewa
  module Gmap
    # Client Library for Gmap Web API: PlaceApi, use a place name to search place id
    class PlaceApi
      GMAP_API_PATH = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?'

      def initialize(token, place)
        @gmap_token = token
        @new_place = place
      end

      def place_id
        PlaceRequest.new(GMAP_API_PATH, @gmap_token, @new_place).gmap_place_http.parse(:json)
      end

      # Sends out HTTP requests to Gmap
      class PlaceRequest
        def initialize(resource_root, token, place)
          @resource_root = resource_root
          @token = token
          @new_place = place
        end

        def gmap_place_http
          Gmap::Request.new("#{@resource_root}input=#{@new_place}&inputtype=textquery&key=#{@token}").get
        end
      end
    end

    # Client Library for Gmap Web API: PlaceDetailsApi, use gmap place id to search gmap details
    class PlaceDetailsApi
      GMAP_API_PATH = 'https://maps.googleapis.com/maps/api/place/details/json?'

      # language default is Taiwanese
      def initialize(token, place_id, language = 'zh-TW')
        @gmap_token = token
        @place_id = place_id
        @language = language
      end

      def place_details
        PlaceDetailsRequest.new(GMAP_API_PATH, @gmap_token, @place_id, @language).gmap_place_http.parse(:json)
      end

      # Sends out HTTP requests to Gmap
      class PlaceDetailsRequest
        def initialize(resource_root, token, place_id, language)
          @resource_root = resource_root
          @token = token
          @place_id = place_id
          @language = language
        end

        def gmap_place_http
          Gmap::Request.new("#{@resource_root}place_id=#{@place_id}&language=#{@language}&key=#{@token}").get
        end
      end
    end

    # Client Library for Gmap Web API: PlaceDetailsApi, use gmap place id to search gmap details
    class PlacePhotoApi
      GMAP_API_PATH = 'https://maps.googleapis.com/maps/api/place/photo?'

      # language default is Taiwanese
      def initialize(token, photo_refer, thumb = TRUE)
        @gmap_token = token
        @photo_refer = photo_refer
        @thumb = thumb
      end

      def place_photo
        # will receive a 302 redirect to another website url
        PlacePhotosRequest.new(GMAP_API_PATH, @gmap_token, @photo_refer, @thumb).gmap_place_http['Location']
      end

      # Sends out HTTP requests to Gmap
      class PlacePhotosRequest
        def initialize(resource_root, token, photo_refer, thumb = TRUE)
          @resource_root = resource_root
          @token = token
          @photo_refer = photo_refer
          @thumb = thumb
        end

        def size_setting
          if @thumb
            { maxwidth: 180, maxheight: 180 }
          else
            { maxwidth: 400, maxheight: 400 }
          end
        end

        def gmap_place_http
          size = size_setting
          wid = size[:maxwidth]
          ht = size[:maxheight]
          url_with_photo_ref = "#{@resource_root}photo_reference=#{@photo_refer}"
          Gmap::Request.new("#{url_with_photo_ref}&maxwidth=#{wid}&maxheight=#{ht}&key=#{@token}").get
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

    # Decorates HTTP responses from GMap with success/error
    class Response < SimpleDelegator
      Unauthorized = Class.new(StandardError)
      NotFound = Class.new(StandardError)

      HTTP_ERROR = {
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
