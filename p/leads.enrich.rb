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

l = BlackStack::LocalLogger.new('./leads.enrich.log')
n = 25 # batch_size

puts 
puts "1. #{BlackStack::CSVIndexer.indexes.size.to_s}"
puts "2. #{BlackStack::Appending.indexes.size.to_s}"

while (true)

    # This process may be moved as a pampa job.

    # map results to database
    # if it is page #1, get # of results
    # if it is page #1, generate further pages based on # of results
    # if it is page #1, generate further pages based on # of results
    # if parsing was successful, apply earnings to the agent

    begin     
        # set internal logger to the appending
#        BlackStack::Appending.set_logger(l)

        # get `batch_size` pages pending for upload
        l.logs 'Getting pending results... '
        results = BlackStack::DfyLeads::Result.pendings(n)
        l.logf "done (#{results.size.to_s})"

        # parse pages
        i = 0
        results.each { |result|
            i += 1

            lead = result.lead
            l.logs "#{i.to_s}. #{lead.name} @ #{lead.stat_company_name}... "
            begin
                # getting the hash descriptor of the lead
                h = lead.to_hash
                # flag lead start time
                lead.enrich_end_time = now
                lead.save
                # look for verified emails
                emails = BlackStack::Appending.find_verified_emails_with_full_name(lead.name, lead.stat_company_name)
                # add verified emails to the lead
                if emails.size > 0
                    emails.uniq.each { |email|
                        h['datas'] << { 'type'=>BlackStack::Leads::Data::TYPE_EMAIL, 'value'=>email, 'verified'=>true }
                    }
                    lead.update(h) # update method will write the stat fields too.
                end
                # track appending as done
                lead.enrich_end_time = now
                lead.enrich_success = true
                lead.save
                l.logf "done (#{emails.size.to_s})"
            rescue => e
                l.logf e.message
                #
                l.logf 'Updating end flag... '
                lead.enrich_end_time = now
                lead.enrich_success = false
                lead.enrich_error_description = e.message
                lead.save
                l.done
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