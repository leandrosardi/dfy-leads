module BlackStack
    module DfyLeads
        class Page < Sequel::Model(:scr_page)
            many_to_one :order, :class=>:'BlackStack::DfyLeads::Order', :key=>:id_order
            one_to_many :results, :class=>:'BlackStack::DfyLeads::Result', :key=>:id_page
        end # class Page
    end # DfyLeads
end # BlackStack