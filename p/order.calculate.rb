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

l = BlackStack::LocalLogger.new('./order.calculate.log')

while (true)
    # find orders who are not child, and are active, and are not deleted, and
    # have not been calculated (dfyl_calculation_success.nil?) or have been 
    # calculated (dfyl_calculation_end_time) 15 minutes ago.
    l.logs 'Getting pending orders... '
    q = "
        SELECT id 
        FROM scr_order
        WHERE COALESCE(dfyl_calculation_end_time, CAST('1900-01-01' AS TIMESTAMP)) < CAST('#{now()}' AS TIMESTAMP) - INTERVAL '15 minutes'
        AND status = true
        AND delete_time IS NULL
        AND dfyl_id_parent IS NULL
    "
    l.logf "done (#{DB[q].count.to_s})"
    
    DB[q].all { |r|
        o = BlackStack::DfyLeads::Order.where(:id=>r[:id]).first
        # open the log
        l.logs "#{o.name}... "
        begin
            # update state
            o.dfyl_calculation_start_time = now
            o.save

            # split the order
            o.update_stats(l)
            
            # generate pages
            if o.pages.select { |p| p.number == 1 && p.parse_success }.size > 0
                if o.dfyl_pagination_success.nil?
                    begin
                        l.logs 'Paginating... '
                        o.paginate(l)
                        o.dfyl_pagination_success = true
                        o.save
                        l.done
                    rescue => e
                        l.logs e.message
                        o.dfyl_pagination_success = false
                        o.dfyl_pagination_error_description = e.message
                        o.save
                    end     
                end # paginate? 

                if o.dfyl_splitting_success.nil?
                    begin
                        l.logs 'Splitting... '
                        o.split(l)
                        o.dfyl_splitting_success = true
                        o.save
                        l.done
                    rescue => e
                        l.logs e.message
                        o.dfyl_splitting_success = false
                        o.dfyl_splitting_error_description = e.message
                        o.save
                    end
                end # split?

            end # first page parsed?

            # update state
            o.dfyl_calculation_end_time = now
            o.dfyl_calculation_success = true
            o.save

            # close the log
            l.done        
        rescue => e
            # close the log
            l.logs e.message

            # update state
            o.dfyl_calculation_end_time = now
            o.dfyl_calculation_success = false
            o.dfyl_calculation_error_description = e.message
            o.save
        end
    }

    # sleep 15 minutes
    l.logs 'Sleeping... '
    sleep(60*15)
    l.logf 'done'

end # while (true)
exit(0)
