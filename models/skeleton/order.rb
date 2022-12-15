module BlackStack
    module DfyLeads
        class Order < BlackStack::Scraper::Order
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            #
            def update_stats()
                # dfyl_stat_scraped_pages
                i = self.pages.select { |p| p.parse_success }.size
                # dfyl_stat_scraped_leads
                j = self.pages.map { |p| p.results.size }.sum
                # update the order
                DB.execute("UPDATE scr_order SET dfyl_stat_scraped_pages=#{i}, dfyl_stat_scraped_leads=#{j} WHERE id='#{self.id}'")
            end # def update_stats
            
            # if the search of the order gets more than N resolts, then the order is split into many smaller orders
            def split
                # TODO: Code Me!
            end

        end # class Order
    end # DfyLeads
end # BlackStack