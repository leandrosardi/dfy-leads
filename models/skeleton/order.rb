module BlackStack
    module DfyLeads
        class Order < Sequel::Model(:scr_order)
            many_to_one :user, :class=>:'BlackStack::MySaaS::User', :key=>:id_user
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            TYPE_SNS = 0 # Sales Navigator Search

            STAGE_IDLE = 0 # idle
            STAGE_IN_PROGRESS = 1
            STAGE_COMPLETED = 2
            STAGE_FAILED = 3

            # list of different stages and their names
            def status_color
                ret = 'gray'
                ret = 'green' if self.status == true
                ret = 'red' if self.status == false
                ret
            end

            def status_name
                ret = 'Paused'
                ret = 'Running' if self.status == true
                ret
            end

            # list of different types and their names
            def self.types()
                [TYPE_SNS]
            end

            def self.type_name(type)
                case type
                when TYPE_SNS
                    'Sales Navigator Search'
                end
            end

            # list of different stages and their names
            def self.stages()
                [STAGE_IDLE, STAGE_IN_PROGRESS, STAGE_COMPLETED, STAGE_FAILED]
            end

            def self.stage_name(stage)
                case stage
                when STAGE_IDLE
                    'Idle'
                when STAGE_IN_PROGRESS
                    'In Progress'
                when STAGE_COMPLETED
                    'Completed'
                when STAGE_FAILED
                    'Failed'
                else 
                    'Unknown'
                end
            end

            # decide the stage of this order
            def stage
                # it is idle if there are no pages
                ret = STAGE_IDLE
                # it is in progress if there are pages
                ret = STAGE_IN_PROGRESS if self.pages.count > 0
                # it is failed if there are pages and all of them are failed
                ret = STAGE_FAILED if self.pages.count > 0 and self.pages.where(:parse_success=>false).count > 0
                # it is completed if there are pages and all of them are completed with success
                ret = STAGE_COMPLETED if self.pages.count > 0 and self.pages.where(:parse_success=>true).count == self.pages.count
                # return
                ret
            end

            def stage_name
                self.class.stage_name(self.stage)
            end

            def stage_color
                res = 'gray'
                res = 'orange' if self.stage == STAGE_IDLE
                res = 'blue' if self.stage == STAGE_IN_PROGRESS
                res = 'green' if self.stage == STAGE_COMPLETED
                res = 'red' if self.stage == STAGE_FAILED
                res
            end

        end # class Order
    end # DfyLeads
end # BlackStack