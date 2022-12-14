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

l = BlackStack::LocalLogger.new('./pages.upload.assign.log')

while (true)

    # This process is a kind of dispatcher.
    # It is not dispatching to pampa workers, 
    # but to users with an active chrome 
    # extension of our scraper service.

    # get a page pending for visit/upload, with a try time lower than 5.
    # get a user beloning the same account than the page, with active chrome extension.
    # if there is no user belonging the same account than the page with active chrome extension, then get a user with an active chrome extension who is sharing its extension.
    # if I found a user, then assign the page to the user.

    begin
        # TODO: recover abandoned pages

        # TODO: use user.available_for_assignation? to check if the user is available for assignation

        # get `batch_size` pages pending for upload
        l.logs 'Getting pending page... '
        page = BlackStack::DfyLeads::Page.pendings(1).first
        if page.nil?
            l.no
        else
            l.yes

            # get all the agents with an active chrome extension, who are sharing its chrome extension
            l.logs 'Getting account user... '
            user = page.order.user.online_users(1).first
            # if there is no user belonging the same account than the page with active chrome extension, then get a user with an active chrome extension who is sharing its extension.
            if user
                l.yes
            else
                l.no

                l.logs 'Getting public user... '
                user = BlackStack::Scraper::User.online_users(1).first 
                if user
                    l.yes
                else
                    l.no
                end
            end

            # if I found a user, then assign the page to the user.
            if user
                l.logs 'Assigning page to user... '
                page.assign(user)
                l.done
            end
        end # if page
    rescue => e
        l.logf e.message
    end

    # sleep for 5 seconds
    l.logs 'Sleeping for 5 seconds... '
    sleep 5
    l.done
    l.log ''

end # while (true)