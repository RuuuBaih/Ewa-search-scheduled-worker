# frozen_string_literal: false

require_relative '../../restaurant_options/init'
require 'concurrent'

module Ewa
  # Provides access to restuarant sites lists data
  module Restaurant
    # Data Mapper: Pixnet POI API, Custom Search API -> Restuarant entity
    class RestaurantMapper
      def initialize(
        custom_search_token,
        custom_search_cx,
        town = nil,
        page_now = 1,
        first_time = false,
        gateway_class = Pixnet::PoiApi
      )
        @token = custom_search_token # custom search api key
        @cx = custom_search_cx # custom search engine setting key
        @page_now = page_now
        @first_time = first_time
        @town = town
        @pix_gateway_class = gateway_class
      end

      # get poi full details
      class PoiDetails
        # page default is 1 (for first time db populate)
        def initialize(pix_gateway_class, town, page_now, first_time)
          @start = []
          @pix_gateway_class = pix_gateway_class
          @setting = { page_now: page_now, town: town, first_time: first_time }
          @tp_towns = %w[中正區 萬華區 大同區 中山區 松山區 大安區 信義區 內湖區 南港區 士林區 北投區 文山區]
          @ntp_towns = %w[萬里區 金山區 板橋區 汐止區 深坑區 石碇區 瑞芳區 平溪區 雙溪區 貢寮區 新店區 坪林區 烏來區 永和區 中和區 土城區 三峽區 樹林區 鶯歌區 三重區 新莊區 泰山區 林口區 蘆洲區 五股區 八里區 淡水區 三芝區 石門區]
        end

        def poi_details
          iterate_pois.map do |hash|
            Concurrent::Promise
              .new {FilterHash.new(hash).filtered_poi_hash}
              .then { |filter| @start << filter if (filter['category_id']).zero? && (filter['money'] != 0)}
              .rescue { { error: "filter process went wrong" } }
              .execute
          end.map(&:value)
          @start
        end

        def iterate_pois
          first_time = @setting[:first_time]
          if first_time then iterate_for_1_time
          else iterate end
        end

        def iterate_for_1_time
          poi_hashes = []
          # return 9 restaurant poi infos from each district (from page 1)
          tp_city = '台北市'
          @tp_towns.each do |tp_town|
            Concurrent::Promise
              .new { call_api(tp_city, tp_town) }
              .then { |ret| poi_hashes << ret }
          end.each(&:value)

          ntp_city = '新北市'
          @ntp_towns.each do |ntp_town|
            Concurrent::Promise
              .new { call_api(ntp_city, ntp_town) }
              .then { |ret| poi_hashes << ret }
          end.each(&:value)
          poi_hashes.flatten
        end

        def iterate
          town = @setting[:town]
          # check town belongs to which city
          # default city is tapei city
          city = if @ntp_towns.include? town then '新北市'
                 else '台北市' end

          call_api(city, town)
        end

        def call_api(city, town)
          # return an array of data hashes
          @pix_gateway_class.new(@setting[:page_now], 9, city, town).poi_lists['data']['pois']
        end
      end

      # get restaurant objs
      def restaurant_obj_lists
        filtered_hashes = PoiDetails.new(@pix_gateway_class, @town, @page_now, @first_time).poi_details
        # filter out hashes without cover pictures
        cov_pic_filtered_hashes = filtered_hashes.map do |hash|
          FilterHash.new(hash).filter_out_empty_cov_pics(@token, @cx)
        end
        # delete restaurants with empty cover pictures
        cov_pic_filtered_hashes.delete_if(&:empty?)

        RestaurantMapper::BuildRestaurantEntity.new(cov_pic_filtered_hashes, @token, @cx).build_entity
      end

      # build Restaurant Entity
      class BuildRestaurantEntity
        def initialize(array_of_hashes, token, cx)
          @array_of_hashes = array_of_hashes
          @token = token
          @cx = cx
        end

        def build_entity
          @array_of_hashes.map do |hash|
            DataMapper.new(hash, @token, @cx).build_entity
          end
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, token, cx)
          @data = data
          @token = token
          @cx = cx
        end

        # rubocop:disable Metrics/MethodLength
        def build_entity
          Ewa::Entity::Restaurant.new(
            id: nil,
            name: @data['name'],
            branch_store_name: @data['branch_store_name'],
            town: @data['town'],
            money: @data['money'],
            city: @data['city'],
            telephone: @data['telephone'],
            cover_img: @data['cover_img'],
            tags: @data['tags'],
            pixnet_rating: @data['pixnet_rating'].to_f,
            open_hours: @data['open_hours'],
            address: @data['address'],
            website: @data['website'],
            clicks: 0,
            likes: nil,
            cover_pictures: cover_pictures
          )
        end
        # rubocop:enable Metrics/MethodLength

        private

        def cover_pictures
          cover_pics = @data['cover_pictures']
          CoverPictureMapper::BuildCoverPictureEntity.new(cover_pics).build_entity
        end
      end

      # Use to filter hashes
      class FilterHash
        def initialize(hash)
          @hash = hash
        end

        # filter the poi fields, select what we want
        # rubocop:disable Metrics/MethodLength
        def filtered_poi_hash
          addr = @hash['address']
          {
            'category_id' => @hash['category_id'],
            'name' => @hash['name'],
            'branch_store_name' => @hash['branch_store_name'],
            'money' => @hash['money'],
            'telephone' => @hash['telephone'],
            'cover_img' => @hash['cover_image_url'],
            'tags' => @hash['tags'],
            'pixnet_rating' => @hash['rating']['avg'],
            'city' => addr['city'],
            'town' => addr['town'],
            'open_hours' => open_hours,
            'website' => website,
            'address' => address
          }
        end
        # rubocop:enable Metrics/MethodLength

        def filter_out_empty_cov_pics(token, cx)
          trim_name = @hash['name'].gsub(' ', '')
          cover_pics = CoverPictureMapper.new(token, cx, trim_name).cover_picture_lists
          if cover_pics.length.zero?
            {}
          else
            @hash['cover_pictures'] = cover_pics
            @hash
          end
        end

        private

        def open_hours
          open_week = @hash['opening_hours_info']['date']
          [
            "星期一: #{open_week['Mo']}", "星期二: #{open_week['Tu']}",
            "星期三: #{open_week['We']}", "星期四: #{open_week['Th']}",
            "星期五: #{open_week['Fr']}", "星期六: #{open_week['Sa']}",
            "星期日: #{open_week['Sun']}"
          ]
        end

        def website
          web_url = @hash['urls']['website']
          if web_url == '' then nil.to_s
          else web_url end
        end

        def address
          addr = @hash['address']
          "#{addr['zip_code']}#{addr['country']}#{addr['city']}#{addr['town']}#{addr['street']}"
        end
      end
    end
  end
end
