module BlackStack
    module DfyLeads
        class Order < Sequel::Model(:scr_order)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            TYPE_SNS = 0 # Sales Navigator Search

            def self.types()
                [TYPE_SNS]
            end

            def self.type_name(type)
                case type
                when TYPE_SNS
                    'Sales Navigator Search'
                end
            end

            def status_label
                if self.
            end

            def status_color
            end

        end # class Order
    end # DfyLeads
end # BlackStack