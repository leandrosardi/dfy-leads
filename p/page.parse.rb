# MySaaS DFYL - Parse Pages
# Copyright (C) 2022 ExpandedVenture, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
#
# Authors: Leandro Daniel Sardi (https://github.com/leandrosardi)
#

# load gem and connect database
require 'mysaas'
require 'lib/stubs'
require 'config'
require 'version'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'

# TODO: dfy-leads extension should require leads extension as a dependency
require 'extensions/leads/lib/skeletons'
require 'extensions/leads/main'

require 'extensions/scraper/lib/skeletons'
require 'extensions/scraper/main'

require 'extensions/dfy-leads/lib/skeletons'
require 'extensions/dfy-leads/main'

# add required extensions
BlackStack::Extensions.append :i2p
BlackStack::Extensions.append :leads
BlackStack::Extensions.append :scraper
BlackStack::Extensions.append :'dfy-leads'

l = BlackStack::LocalLogger.new('./page.parse.log')
n = 100 # batch_size

while (true)

    # This process may be moved as a pampa job.

    # map results to database
    # if it is page #1, get # of results
    # if it is page #1, generate further pages based on # of results
    # if it is page #1, generate further pages based on # of results
    # if parsing was successful, apply earnings to the agent

    begin     
        # get `batch_size` pages pending for upload
        l.logs 'Getting pending pages... '
        pages = BlackStack::DfyLeads::Page.where(:upload_success=>true, :parse_end_time=>nil).order(:create_time).limit(n).all
        l.logf "done (#{pages.size.to_s})"

        # parse pages
        pages.each { |p|
            l.logs "Parsing page #{p.id}... "
            begin
                if p.order.status && p.order.delete_time.nil?
                    # flag start time
                    l.logs 'Flagging start time... '
                    p.parse_start_time = now
                    p.save
                    l.done

                    # declare array of leads
                    l.logs 'Declaring array of leads... '
                    leads = []
                    l.done

                    # parse: get array of result descriptors
                    l.logs 'Parsing... '
                    a = p.parse(l)
                    l.logf "done (#{a.size.to_s})"

                    # save the leads
                    l.logs 'Creating leads... '
                    a.each { |h|
                        # look for verified emails
                        # retry up to 5 times the call to our api
                        # reference: https://github.com/leandrosardi/dfy-leads/issues/75
                        try = 0
                        max_tries = 3
                        emails = []
                        while try<max_tries && emails.nil?
                            begin
                                try += 1
                                l.logs "Appending try #{try.to_s}: #{h['name']} @ #{h['company']['name']}... "
                                emails = BlackStack::Appending.find_verified_emails_with_full_name(h['name'], h['company']['name'])
                                l.logf "done (#{emails.size.to_s})"
                            rescue => e
                                l.logf e.message
                                
                                l.logs "Sleeping for 5 seconds... "
                                sleep 5
                                l.done
                            end # begin
                        end # while

                        # add verified emails to the lead
                        if emails.size > 0
                            # open the log
                            l.logs "Merging lead with database... "
                            # adding the emails to the hash descriptor of the lead
                            emails.uniq.each { |email|
                                h['datas'] << { 'type'=>BlackStack::Leads::Data::TYPE_EMAIL, 'value'=>email, 'verified'=>true }
                            }
                            # merging the lead with the database
                            lead = BlackStack::Leads::Lead.merge(h)
                            # flag the lead as apready enriched
                            # this ugly code is because of the issue https://github.com/leandrosardi/dfy-leads/issues/71
                            lead.enrich_start_time = now
                            lead.enrich_end_time = now
                            lead.enrich_success = true
                            # save the lead
                            lead.save
                            # add the lead to the array
                            leads << lead
                            # close the log
                            l.done
                        end
                        # release resources
                        DB.disconnect
                        GC.start
                    }
                    l.logf "done (#{leads.size.to_s})"

                    # if not exists a result for that lead and this page, then insert records into the table `dfyl_result`
                    l.logs 'Inserting results... '
                    p.order.generate_results(p, leads, l)
                    l.done

                    # flag end time
                    l.logs 'Flagging end time... '
                    p.parse_end_time = now
                    p.parse_success = true
                    p.save
                    l.done

                    # TODO: split order                    
                else
                    l.logf 'Order was deleted or paused.'
                end
            rescue => e
                l.logf e.message

                # flag end time
                l.logs 'Flagging end time... '
                p.parse_end_time = now
                p.parse_success = false
                p.parse_error_description = e.message
                p.save
                l.done
            end
            l.done
        }        
    rescue => e
        l.logf e.message
    end

    # sleep for 5 seconds
    l.logs 'Sleeping for 5 seconds... '
    sleep 5
    l.done
    l.log ''

end # while (true)