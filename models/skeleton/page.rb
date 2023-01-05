module BlackStack
    module DfyLeads
        class Page < BlackStack::Scraper::Page
            many_to_one :order, :class=>:'BlackStack::DfyLeads::Order', :key=>:id_order
            one_to_many :results, :class=>:'BlackStack::DfyLeads::Result', :key=>:id_page
            
            # return the URL to the download HTML of this page
            def url
                "#{BlackStack::DfyLeads.html_storage_url}/clients/#{self.order.user.account.id.to_guid}/dfy-leads.pages/#{self.id.to_guid}.html"            
            end 

            # return the HTML code of the page, stored in the storage folder of the account who is owner of the page.
            # return nil if the file doesn't exist.
            def html
                ret = nil
                `wget #{self.url} > /dev/null 2>&1`
                filename = "#{self.id.to_guid}.html"
                ret = File.read(filename)
                `rm #{self.id.to_guid}.html`
                ret
            end

            # get the raw HTML of the page, and get the total leads of the search
            # return the total leads of the search
            def number_of_search_leads
                html = self.html
                return nil if html.nil?
                doc = Nokogiri::HTML(html)
                # get the total number of leads
                o = doc.xpath('//div[contains(@class, "_display-count")]').first
                raise 'Unknown page design: Search results not found.' if o.nil?
                total_leads = o.text.strip.split(' ').first.strip.to_s
                factor = 1000 if total_leads.include?('K')
                factor = 1000000 if total_leads.include?('M')
                n = total_leads.gsub('K', '').gsub('M', '').gsub(',', '').to_i
                n = n * factor if factor
                n
            end

            # Get the raw HTML of the page, and generate list of result descriptors, and get the total leads of the search
            # Update the order of the page with the number of results of the search.
            #
            # Return an array of result descriptors.
            # 
            def parse(l=nil)
                i=0
                leads = []
                # create logger if not passed
                l = BlackStack::DummyLogger.new(nil) if l.nil?
                # create the Nokogiri document
                # return nil if the HTML file is not found
                html = self.html
                return nil if html.nil?
                doc = Nokogiri::HTML(html)
                # get the total number of leads
                l.logs "Getting total number of leads... "
                total_leads = self.number_of_search_leads
                l.logf total_leads.to_s
                # update the order with the total number of leads
                l.logs "Update order dfyl_stat_search_leads... "
                DB.execute("UPDATE scr_order SET dfyl_stat_search_leads = #{total_leads} WHERE id = '#{self.id_order}'")
                self.order.dfyl_stat_search_leads = total_leads
                l.done
                # iterate search results
                lis = doc.xpath('//li[contains(@class, "artdeco-list__item")]')    
                raise 'Unknown page design: List of results not found.' if lis.size == 0
                lis.each { |li|
                    i += 1
                    doc2 = Nokogiri::HTML(li.inner_html)
                    # this is where to find the full name of the lead
                    n1 = doc2.xpath('//div[contains(@class,"artdeco-entity-lockup__title")]/a/span').first
                    lead_name = n1.text.strip.gsub('"', '') if n1
                    # this is where to find the name of the company, when it has a link to a linkedin company page
                    n2 = doc2.xpath('//div[contains(@class,"artdeco-entity-lockup__subtitle")]/a').first
                    # this is where to find the name of the company, when it has not a link to a linkedin company page
                    company_name = nil
                    if n2
                        company_name = n2.text
                    else
                        n2 = doc2.xpath('//div[contains(@class,"artdeco-entity-lockup__subtitle")]').first 
                        if n2
                            company_name = n2.text.split("\n").reject { |s| s.strip.empty? }.last.to_s.strip
                        end
                    end
                    company_name = company_name.strip.gsub('"', '') if company_name
                    # validate: I found a lead name
                    # I remove this validation because some times, SN don't show the full profile of a lead.
                    #raise 'Lead name not found' if lead_name.nil?
                    # validate: I found a company name
                    raise 'Company name not found' if lead_name && company_name.nil?
                    # merge lead
                    l.logs "#{i.to_s}: #{lead_name} at #{company_name}... "
                    if lead_name.nil?
                        l.logf "Lead name not found. Skipping."
                    else
                        h = {
                            'name' => lead_name,
                            'company' => { 'name' => company_name },
                            'id_user' => self.order.id_user,
                        }
                        leads << h
                        l.done
                    end # if lead_name.nil?
                }
                # return 
                leads  
            end # def self.parse_sales_navigator_result_pages(l=nil)
            
            # if this page is not uploaded, return false
            # if this page is not parsed, return false
            # if any result of this page is not enriched, return false
            # otherwise, return true
            #
            # reference: https://github.com/leandrosardi/dfy-leads/issues/58
            #
            def completed?
                # if this page is not uploaded, return false
                return false unless self.upload_success
                # if this page is not parsed, return false
                return false unless self.parse_success
                # if any result of this page is not enriched, return false
                self.results.each { |r|
                    return false unless r.lead.enrich_success
                }
                # otherwise, return true
                true
            end

        end # class Order
    end # DfyLeads
end # BlackStack