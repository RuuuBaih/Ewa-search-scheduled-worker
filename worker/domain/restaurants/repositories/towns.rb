# frozen_string_literal: true

require 'json'

module Ewa
  module Repository
    # Repository for Town
    class Towns
      def self.create_first_time
        # create taipei cities
        tp_city = '台北市'
        tp_towns = %w[中正區 萬華區 大同區 中山區 松山區 大安區 信義區 內湖區 南港區 士林區 北投區 文山區]
        tp_entities = create_city_towns(tp_city, tp_towns)

        # create new tapei cities
        ntp_city = '新北市'
        ntp_towns = %w[萬里區 金山區 板橋區 汐止區 深坑區 石碇區 瑞芳區 平溪區 雙溪區 貢寮區 新店區 坪林區 烏來區 永和區 中和區 土城區 三峽區 樹林區 鶯歌區 三重區 新莊區 泰山區 林口區 蘆洲區 五股區 八里區 淡水區 三芝區 石門區]
        ntp_entities = create_city_towns(ntp_city, ntp_towns)

        # return array of town entities
        (tp_entities + ntp_entities)
      end

      def self.create_city_towns(city, towns)
        # city is String, towns is array of strings
        towns.map do |town_name|
          db_entity = find_by_name_city(town_name, city)
          if db_entity
            rebuild_entity(db_entity)
          else
            db_town = Database::TownOrm.create(city: city, town_name: town_name, page: 0, search_times: 0)
            rebuild_entity(db_town)
          end
        end
      end

      def self.find_by_name_city(town_name, city)
        Database::TownOrm.first(town_name: town_name, city: city)
      end

      def self.find_by_name(town_name)
        Database::TownOrm.first(town_name: town_name)
      end

      def self.check_update_status(town_name, limit_num)
        db_record = find_by_name(town_name)
        search_times = db_record.search_times

        # limit_num can be set to any number
        # if upto the limit then will return town entity(need update, api call)
        # can get searche_times and page with the returning entity
        # if not will return false(doesn't need update)
        if (search_times % limit_num).zero?
          { status: true, entity: rebuild_entity(db_record) }
        else
          { status: false, entity: nil }
        end
      end

      def self.all
        Database::TownOrm.all.map { |db_town| rebuild_entity(db_town) }
      end

      def self.update_search(town_name)
        db_entity = Database::TownOrm.first(town_name: town_name)
        new_search_times = db_entity.search_times + 1
        db_entity.update(search_times: new_search_times)
        rebuild_entity db_entity
      end

      # update page when searches above the limit num
      def self.update_page(town_name)
        db_entity = Database::TownOrm.first(town_name: town_name)
        new_page = db_entity.page + 1
        db_entity.update(page: new_page)
        rebuild_entity db_entity
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Town.new(
          id: db_record.id,
          city: db_record.city,
          town_name: db_record.town_name,
          page: db_record.page,
          search_times: db_record.search_times
        )
      end
    end
  end
end
