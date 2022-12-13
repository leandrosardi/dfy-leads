module BlackStack
    module DfyLeads
        class Page < BlackStack::Scraper::Page
            many_to_one :order, :class=>:'BlackStack::DfyLeads::Order', :key=>:id_order
            one_to_many :results, :class=>:'BlackStack::DfyLeads::Result', :key=>:id_page
            
            # get the raw HTML of the page, and generate list of results, and get the total leads of the search
            def parse
                # TODO: Code Me!
            end
            
        end # class Order
    end # DfyLeads
end # BlackStack