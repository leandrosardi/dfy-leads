module BlackStack
    module DfyLeads
        class Order < BlackStack::Scraper::Order
            many_to_one :search, :class=>:'BlackStack::Leads::Search', :key=>:id_search
            many_to_one :export, :class=>:'BlackStack::Leads::Export', :key=>:id_export
            one_to_many :pages, :class=>:'BlackStack::DfyLeads::Page', :key=>:id_order
            
            LEADS_PER_PAGE = 25
            MAX_NUMBER_OF_PAGES = 100

            # Return array of child orders
            def children
                BlackStack::DfyLeads::Order.where(:dfyl_id_parent=>self.id).all
            end

            # If an order has more than 2,500 results, then split it.
            # Track the parent order of each order
            # reference: https://github.com/leandrosardi/dfy-leads/issues/37
            def split(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # get the search linked to this order
                l.logs "Getting search... "
                s = self.search
                raise 'Search not found!' if s.nil?
                l.done
                # get the number of leads
                l.logs "Getting number of leads... "
                n = self.dfyl_stat_search_leads
                raise 'Number of leads not found!' if n.nil?
                l.logf "done (#{n.to_s})"
                # check if the search has more than 1,000 leads
                l.logs "Need to split?... "
                if n <= LEADS_PER_PAGE*MAX_NUMBER_OF_PAGES
                    l.no
                else
                    l.yes
                    # get the USA location
                    # TODO: parametrizar el codigo de USA en la tabla fl_location
                    l.logs "Getting USA location... "
                    usa = BlackStack::MySaaS::Country.where(:code=>'us').first
                    raise 'USA location not found!' if usa.nil?
                    l.done
                    # ask if search is targeting the USA country
                    l.logs "Is the search targeting the USA?... "
                    if s.locations.select { |l| 
                        l.positive && 
                        l.value == usa.name 
                    }.size == 0
                        l.no
                    else
                        l.yes
                        # get the states excludes
                        l.logs "Getting states excludes... "
                        states_excludes = s.locations.select { |l|
                            l.positive == false &&
                            BlackStack::Leads::Location.where(:name=>l.value).first.is_state
                        }.map { |l| 
                            BlackStack::Leads::Location.where(:name=>l.value).first 
                        }
                        l.logf "done (#{states_excludes.size.to_s})"
                        # get the states of USA
                        l.logs "Getting states of USA... "
                        states = BlackStack::Leads::Location.where(:id_country=>usa.id, :is_state=>true).all
                        l.logf "done (#{states.size.to_s})"
                        # get the hash descriptor of the main search
                        g = s.to_hash
                        # iterate the states
                        states.each { |state|
                            l.logs "#{state.name}... "
                            # check if the state is excluded
                            if states_excludes.select { |s| s.id == state.id }.size > 0
                                l.logf "excluded"
                            else
                                # check if already exists a child targeting the state
                                if self.children.select { |q| 
                                    q.search.locations.select { |r|
                                        r.positive == true && r.value == state.name
                                    }.size > 0
                                }.size > 0
                                    l.logf "already exists"
                                else
                                    # clone the hash description
                                    h = g.clone
                                    # remove the USA location
                                    h['locations'] = h['locations'].reject { |r|
                                        r['positive'] == true && r['value'] == usa.name
                                    }
                                    # add the state location
                                    h['locations'] << {
                                        'positive'=>true,
                                        'value'=>state.name
                                    }
                                    # update the search name
                                    h['name'] = "#{s.name} (#{state.name})"
                                    # create the new search
                                    s2 = BlackStack::Leads::Search.new(h)
                                    # save the new search
                                    s2.save
                                    # create a new order
                                    o2 = BlackStack::DfyLeads::Order.new
                                    o2.id = guid
                                    o2.create_time = now
                                    o2.name = self.name + " (#{state.name})"
                                    o2.id_search = s2.id
                                    o2.id_user = self.id_user
                                    o2.status = self.status
                                    o2.url = s2.sales_navigator_url
                                    o2.type = self.type
                                    o2.dfyl_id_parent = self.id
                                    o2.save
                                    # release resources
                                    GC.start
                                    DB.disconnect
                                    # close the log line
                                    l.done
                                end
                            end
                        } # states.each
                    end
                end
            end

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
                l.logs 'Getting search leads... '
                raise 'First uploaded page not parsed!' if self.dfyl_stat_search_leads.nil?
                l.logf "done (#{self.dfyl_stat_search_leads.to_s} results)"
                # calculate the number of pages of the search
                l.logs "Calculating number of pages... "
                n = (self.dfyl_stat_search_leads.to_f / LEADS_PER_PAGE.to_f).ceil.to_i # round up
                n = MAX_NUMBER_OF_PAGES if n > MAX_NUMBER_OF_PAGES
                l.logf "done (#{n.to_s})"
                # generating pages
                i = 1
                j = 0
                while i < n #&& j < 1
                    i += 1
                    l.logs "Generating page #{i.to_s}... "
                    p = BlackStack::DfyLeads::Page.where(:id_order=>self.id, :number=>i).first
                    if p
                        l.logf "already exists"
                    else
                        j += 1
                        # create the page
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
                # 
                self.dfyl_stat_scraped_pages = i
                self.dfyl_stat_scraped_leads = j
            end # def update_stats
        end # class Order
    end # DfyLeads
end # BlackStack