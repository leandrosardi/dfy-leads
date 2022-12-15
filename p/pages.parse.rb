# MySaaS Emails - Delivery
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

l = BlackStack::LocalLogger.new('./pages.parse.log')
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
                # flag start time
                l.logs 'Flagging start time... '
                p.parse_start_time = now
                p.save
                l.done

                # parse: get # of search leads, get results, create leads and merge them into the database (baded on fname, lname and cname)
                l.logs 'Parsing... '
                leads = p.parse(l)
                l.logf "done (#{leads.size.to_s})"

                # save the leads
                l.logs 'Saving leads... '
                leads.each { |lead|
                    l.logs "#{lead.id}... "
                    lead.save
                    l.done
                    # release resources
                    DB.disconnect
                    GC.start
                }
                l.done
                
                # if not exists a result for that lead and this page, then insert records into the table `dfyl_result`
                l.logs 'Inserting results... '
                leads.each { |lead|
                    l.logs "#{lead.id}... "
                    r = BlackStack::DfyLeads::Result.where(:id_lead=>lead.id, :id_page=>p.id).first 
                    if r
                        l.no
                    else
                        r = BlackStack::DfyLeads::Result.new
                        r.id = guid
                        r.create_time = now
                        r.id_lead = lead.id
                        r.id_page = p.id
                        r.save
                        l.yes
                        # release resources
                        DB.disconnect
                        GC.start
                    end
                }

                # update the order with the total number of pages
                l.logs "Update order stats... "
                p.order.update_stats
                l.done  

                # TODO: apply earnings

                # TODO: generate forther pages

                # TODO: split order

                # flag end time
                l.logs 'Flagging end time... '
                p.parse_end_time = now
                p.parse_success = true
                p.save
                l.done

                l.done
            rescue => e
                l.logf e.message

                # flag end time
                l.logs 'Flagging end time... '
                p.parse_end_time = now
                p.parse_success = false
                p.parse_error_description = e.message
                p.save
            end
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