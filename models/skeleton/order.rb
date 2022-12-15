module BlackStack
    module DfyLeads
        class Order < BlackStack::Scraper::Order
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            LEADS_PER_PAGE = 25
            MAX_NUMBER_OF_PAGES = 100

            # 
            def generate_results(page, leads, l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                leads.each { |lead|
                    l.logs "#{lead.id}... "
                    r = BlackStack::DfyLeads::Result.where(:id_lead=>lead.id, :id_page=>page.id).first 
                    if r
                        l.no
                    else
                        r = BlackStack::DfyLeads::Result.new
                        r.id = guid
                        r.create_time = now
                        r.id_lead = lead.id
                        r.id_page = page.id
                        r.save
                        l.yes
                        # release resources
                        DB.disconnect
                        GC.start
                    end
                }
            end

            # 
            def generate_pages(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # get the first page
                l.logs "Getting first uploaded page... "
                p = BlackStack::DfyLeads::Page.where(:id_order=>self.id, :upload_success=>true, :number=>1).first
                raise 'First uploaded page not found!' if p.nil?
                l.done
                # verify: the first page must be parsed
                l.logs 'Verifying first page... '
                if self.dfyl_stat_search_leads.nil?
                    raise 'First uploaded page not parsed!' 
                else
                    l.logf "done (#{self.dfyl_stat_search_leads.to_s})"
                end
                # calculate the number of pages of the search
                l.logs "Calculating number of pages... "
                n = (self.dfyl_stat_search_leads.to_f / LEADS_PER_PAGE.to_f).ceil.to_i # round up
                n = MAX_NUMBER_OF_PAGES if n > MAX_NUMBER_OF_PAGES
                l.logf "done (#{n.to_s})"
                # generating pages
                i = 1
                while i < n
                    i += 1
                    l.logs "Generating page #{i.to_s}... "
                    p = BlackStack::DfyLeads::Page.where(:id_order=>self.id, :number=>i).first
                    if p
                        l.logf "already exists"
                    else
                        p = BlackStack::DfyLeads::Page.new
                        p.id = guid
                        p.create_time = now
                        p.id_order = self.id
                        p.number = i
                        p.save
                        # release resources
                        DB.disconnect
                        GC.start
                        # log
                        l.done
                    end
                end
            end

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