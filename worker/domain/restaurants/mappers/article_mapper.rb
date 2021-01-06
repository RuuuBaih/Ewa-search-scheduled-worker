# frozen_string_literal: false

module Ewa
  # Provides access to restuarant articles
  module Restaurant
    # Data Mapper: Mapping article data into
    class ArticleMapper
      def initialize(keyword, gateway_class = Pixnet::ArticleApi)
        @keyword = keyword
        @gateway_class = gateway_class
      end

      # get the newest article of restaurant
      def the_newest_article
        data = { 'keyword' => @keyword }
        # per_page should be set to > 2 or there are no results
        article_ret = @gateway_class.new(2, 1, @keyword).article_lists
        data['link'] = if !article_ret.key?('articles')
                         'https://i.imgur.com/kfi33rq.png'
                       else
                         article_ret['articles'][0]['link']
                       end
        data
      end

      # build Article Entity
      class BuildArticleEntity
        def initialize(data)
          @data = data
        end

        def build_entity
          DataMapper.new(@data).build_entity
        end
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Ewa::Entity::Article.new(
            id: nil,
            restaurant_name: name,
            link: link
          )
        end

        private

        def name
          @data['keyword']
        end

        def link
          @data['link']
        end
      end
    end
  end
end
