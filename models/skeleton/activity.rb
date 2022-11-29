module BlackStack
    module DfyLeads
        class Activity < Sequel::Model(:scr_activity)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user            
        end # class Activity
    end # DfyLeads
end # BlackStack