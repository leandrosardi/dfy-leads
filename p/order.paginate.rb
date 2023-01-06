# MySaaS DFYL - Order Spitting
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

l = BlackStack::LocalLogger.new('./order.paginate.log')

while (true)
    # find orders who have been parsed successfully, and have not paginated yet
    l.logs 'Getting pending orders... '
    a = BlackStack::DfyLeads::Order.where(
        :dfyl_pagination_success=>nil
    ).all.select { |o| 
        o.pages.select { |p| p.number == 1 && p.parse_success }.size > 0
    }
    l.logf "done (#{a.size.to_s})"
    
    a.each { |o|
        # open the log
        l.logs "#{o.name}... "
        begin
            # update state
            o.dfyl_pagination_start_time = now
            o.save

            # split the order
            o.paginate(l)
            
            # update state
            o.dfyl_pagination_end_time = now
            o.dfyl_pagination_success = true
            o.save

            # close the log
            l.done        
        rescue => e
            # close the log
            l.logs e.message

            # update state
            o.dfyl_pagination_end_time = now
            o.dfyl_pagination_success = false
            o.dfyl_pagination_error_description = e.message
            o.save
        end
    }

    # sleep
    l.logs 'Sleeping... '
    sleep(60*15) # reduce the frequency in order to reduce CRDB spending
    l.logf 'done'

end # while (true)
exit(0)
