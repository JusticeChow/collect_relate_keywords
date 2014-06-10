#coding = utf-8
require "query"
require "rubygems"
require "active_record"

ActiveRecord::Base.establish_connection(
	:adapter => "mysql",
	:host => "localhost",
	:username => "root",
	:password => "123456",
	:database => "relate_words")

class RelateWorld < ActiveRecord::Base
end

#get the sogou rank of elong site
def sogou_rank(wd)
	page = Query::Engine::Sogou.query(wd)
	ranks = page.seo_ranks

	ranks.each do |rank|
		if rank[:text].include? "艺龙"
			puts "艺龙搜索结果在搜狗中排名第#{rank[:rank]}"
			break
		end
	end
end


#search the wd word on baidu, save the relate keywords into db.
def search(wd)
	page = Query::Engine::Baidu.query(wd)
	#page.seo_rank       #it seems that the seo_rank of baidu is not complete crawled the search page
	related_keywords_baidu = page.related_keywords 
	related_keywords_baidu.each do |keywords|            # save each keywords into database unless the word is exist already.
		next unless RelateWorld.find_by_keyword(keywords) == nil
		relate = RelateWorld.new
		relate.keyword = keywords
		relate.save
	end 
end

=begin  
	#it seems like that the search link of Qihu is changed
	page = Query::Engine::Qihu.new
	related_keywords_qihu = Query::Engine::Qihu.related_keywords("北京酒店预订")
	puts related_keywords_qihu
	page = page.query("北京酒店预订")
	puts page.seo_rank
	
	#return no result
	related_keywords_sogou = page.related_keywords
	puts related_keywords_sogou
=end

search_word = "北京酒店预订"       
sogou_rank(search_word)
search(search_word)

i = 0

while RelateWorld.count < 500000      #collect 500_000 words before stop.
	i += 1
	puts "search id#{i}"
	begin
		search(RelateWorld.find(i).keyword)
	rescue Exception
		puts "the id#{i} is empty with problem with auto_increment. or link failed."
	end
end

puts "#{RelateWorld.count} words collected."





