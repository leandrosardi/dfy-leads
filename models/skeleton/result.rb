module BlackStack
    module DfyLeads
        class Result < Sequel::Model(:dfyl_result)
            many_to_one :page, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_page
            many_to_one :lead, :class=>:'BlackStack::Leads::Lead', :key=>:id_lead

            def self.pendings(n=1000)
                ret = []
                q = "
                    select r.id
                    from fl_lead l
                    join dfyl_result r on l.id=r.id_lead
                    join scr_page p on r.id_page=p.id
                    join scr_order o on (o.id=p.id_order and o.status=true)
                    where l.enrich_success is null
                    order by r.create_time
                    limit #{n}
                "
                DB[q].all { |row|
                    ret << BlackStack::DfyLeads::Result.where(:id=>row[:id]).first
                }
                # release resources
                DB.disconnect
                GC.start
                # return
                ret
            end # self.pendings
        end # class Result
    end # DfyLeads
end # BlackStack