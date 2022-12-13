module BlackStack
    module DfyLeads
        class Order < BlackStack::Scraper::Order
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            # if the search of the order gets more than N resolts, then the order is split into many smaller orders
            def split
                # TODO: Code Me!
            end

        end # class Order
    end # DfyLeads
end # BlackStack