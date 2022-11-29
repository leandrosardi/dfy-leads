module BlackStack
    module DfyLeads
        class Result < Sequel::Model(:scr_result)
            many_to_one :page, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_page
            many_to_one :lead, :class=>:'Leads::FlLead', :key=>:id_lead
        end # class Result
    end # DfyLeads
end # BlackStack