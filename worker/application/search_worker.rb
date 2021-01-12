# frozen_string_literal: true

require_relative '../../init.rb'
require_relative '../domain/restaurants/init'
require 'aws-sdk-sqs'

module Ewa
  # Scheduled worker to report on recent cloning operations
  class SearchWorker
    def initialize
      @config = SearchWorker.config
      @queue = Ewa::Messaging::Queue.new(
        @config.SEARCH_QUEUE_URL, @config
      )
    end

    def call
      puts "UPDATE TOWNS RESTAURANT INFO DateTime: #{Time.now}"

      # Update town count times
      towns = update_towns

      if towns.any?
        puts "\tNumber of towns need update: #{towns.count}"

        towns.each do |key, val|
          # If one restaurant has been clicked upon 5 times then needs an update
          towns_name = key.to_s
          searchs = val.to_i
          searchs.times do
            do_db_update(towns_name)
          end
          puts "\tTown #{towns_name} need to be updated #{searchs} times, update has done."
        end
      else
        puts "\tNo update towns need for today."
      end
    end

    def do_db_update(town)
      # put new restaurant infos to db
      town_entity = Repository::Towns.find_by_name(town)
      new_page = town_entity.page + 1
      town_name = town_entity.town_name
      restaurants = Restaurant::RestaurantMapper.new(@config.GMAP_TOKEN, @config.CX, town_name, new_page).restaurant_obj_lists
      restaurants.map do |restaurant_entity|
        Repository::For.entity(restaurant_entity).create(restaurant_entity)
      end
      # update new page and restaurant search nums to db town table
      Repository::Towns.update_page(town_name)
    end

    def update_towns
      return @updated_towns if @updated_towns

      # default hash value is 0
      @updated_towns = Hash.new(0)
      #binding.irb
      @queue.poll do |queue|
        puts queue.inspect
        # count how many times restaurants get search
        town_name = queue
        @updated_towns[town_name] = @updated_towns[town_name] + 1
      end
      @updated_towns
    end
  end
end


