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
                                    # register the first page
                                    p2 = BlackStack::DfyLeads::Page.new()
                                    p2.id = guid
                                    p2.create_time = now
                                    p2.id_order = o2.id
                                    p2.number = 1 # this column is added by dfy-leads extension
                                    p2.save
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
            def paginate(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # get the first page
                l.logs "Getting first uploaded page... "
                p = BlackStack::DfyLeads::Page.select(:id).where(:id_order=>self.id, :upload_success=>true, :number=>1).first
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
                    p = BlackStack::DfyLeads::Page.select(:id).where(:id_order=>self.id, :number=>i).first
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

            # number of leads scraped, beloning this order and all its children
            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            def total_leads_scraped
                q = "
                    select count(distinct p.id)*#{LEADS_PER_PAGE} as n
                    from scr_order o 
                    join scr_page p on o.id=p.id_order
                    where (o.id='#{self.id}' or o.dfyl_id_parent='#{self.id}')
                    and p.upload_success=true
                "
                DB[q].first[:n]
            end

            # number of leads scraped and enriched (with success or not), beloning this order and all its children
            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            def total_leads_processed
                q = "
                    select count(distinct r.id_lead) as n
                    from scr_order o 
                    join scr_page p on o.id=p.id_order
                    join dfyl_result r on (p.id=r.id_page)
                    join fl_lead l on (l.id=r.id_lead and l.enrich_success=true)
                    where (o.id='#{self.id}' or o.dfyl_id_parent='#{self.id}')
                "
                DB[q].first[:n]
            end

            # number of leads scraped and enriched (with success only), beloning this order and all its children
            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            def total_leads_appended
                q = "
                    select count(distinct r.id_lead) as n
                    from scr_order o 
                    join scr_page p on o.id=p.id_order
                    join dfyl_result r on (p.id=r.id_page)
                    join fl_lead l on (l.id=r.id_lead and l.enrich_success=true)
                    join fl_data d on (l.id=d.id_lead and d.verified=true)
                    where (o.id='#{self.id}' or o.dfyl_id_parent='#{self.id}')
                "
                DB[q].first[:n]
            end

            # if this order has not been paginated, return false
            # if this order has not been splited, return false
            # if any page of this order is not completed, return false
            # if any child of this order is not completed, return false
            # otherwise, return true
            #
            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            #
            def completed?
                # if this order has not been paginated, return false
                return false unless self.dfyl_pagination_success
                # if this order has not been splited, return false
                return false unless self.dfyl_splitting_success
                # if any page of this order is not completed, return false
                self.pages.each { |page|
                    return false unless page.completed?
                }
                # if any child of this order is not completed, return false
                self.children.each { |child|
                    return false unless child.completed?
                }
                # otherwise, return true
                true
            end

            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            def update_stats(l=nil)
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # dfyl_stat_children
                l.logs 'Updating dfyl_stat_children...'
                self.dfyl_stat_children = self.children.size
                l.logf "done (#{self.dfyl_stat_children.to_s})"
                # dfyl_stat_progress
                l.logs 'Updating dfyl_stat_progress...'
                if self.completed?
                    self.dfyl_stat_progress = 100.to_i
                else
                    a = self.total_leads_processed.to_i
                    b = self.dfyl_stat_search_leads
                    if b.nil?
                        self.dfyl_stat_progress = nil
                    else
                        b = b.to_i    
                        self.dfyl_stat_progress = (b == 0) ? 100.to_i : (100.to_f * (a.to_f / b.to_f)).round.to_i
                    end
                end
                l.logf "done (#{self.dfyl_stat_progress.to_s})"
                # dfyl_stat_scraped_leads
                l.logs 'Updating dfyl_stat_scraped_leads...'
                self.dfyl_stat_scraped_leads = self.total_leads_scraped
                l.logf "done (#{self.dfyl_stat_scraped_leads.to_s})"
                # dfyl_stat_leads_appended
                l.logs 'Updating dfyl_stat_leads_appended...'
                self.dfyl_stat_leads_appended = self.total_leads_appended
                l.logf "done (#{self.dfyl_stat_leads_appended.to_s})"
                # update
                l.logs 'Updating order...'
                self.save
                l.logf 'done'
            end # def update_stats
            
        end # class Order
    end # DfyLeads
end # BlackStack