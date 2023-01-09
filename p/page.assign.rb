# MySaaS DFYL - Assign pages to Agents for Upload
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

l = BlackStack::LocalLogger.new('./page.assign.log')
n = 100 # batch_size

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
        # relaunch abandoned pages
        l.logs 'Relaunching abandoned pages... '
        BlackStack::DfyLeads::Page.abandoned(n).each { |p| 
            l.logs "Relaunching page #{p.id}... "
            p.relaunch 
            l.done
        }
        l.done

        # get active orders
        BlackStack::DfyLeads::Order.where(:delete_time=>nil, :status=>true).each { |o|
        l.logs "Working order #{o.id} (#{o.name}@#{o.user.email})... "

            # get `batch_size` pages pending for upload
            # Remember: `Page.pandings` returns pages in sequence, because of the issue https://github.com/leandrosardi/scraper/issues/24
            l.logs 'Getting pending page... '
            page = o.pending_pages(1).first
            if page.nil?
                l.no
            else
                l.yes

                # user to assign this page
                user = nil
                previous = nil

                # get the latest user who visited a page of this order
                # reference: https://github.com/leandrosardi/scraper/issues/24
                l.logs 'Is the first page of the order... '           
                if page.number == 1
                    l.yes
                else
                    l.no
                    l.logs 'Getting previous page... '
                    previous = BlackStack::DfyLeads::Page.select(:id, :number, :id_order).where(:id_order=>page.id_order, :number=>page.number-1).first
                    if previous.nil?
                        l.logf "Error: previous page not found"
                    else
                        l.done
                        # get the latest assignation of the previous page
                        l.logs 'Getting previous page assignation... '
                        assignation = BlackStack::Scraper::Assignation.where(:id_page=>previous.id).reverse(:create_time)
                        if assignation.nil?
                            l.logf "Error: previous page assignation not found"
                        else
                            l.done
                            
                            # get the user who visited the previous page
                            l.logs 'Getting previous page user... '
                            candidate_user = assignation.user
                            if candidate_user.nil?
                                l.logf "Error: previous page user not found"
                            elsif !candidate_user.online?
                                l.logf "Error: previous page user (#{candidate_user.email}) is not online"
#                            elsif !candidate_user.enabled?
#                                l.logf "Error: previous page user (#{candidate_user.email}) is not enabled"
                            else
                                user = candidate_user
                                l.done
                            end
                        end
                    end
                end
                
                # If I didn't find a user, then get a user beloning the same account than the page, 
                # with active chrome extension.
                if user.nil?
                    # get all the agents with an active chrome extension, who are sharing its chrome extension
                    l.logs 'Getting account user... '
                    user = page.order.user.available_users(1).first
                    # if there is no user belonging the same account than the page with active chrome extension, then get a user with an active chrome extension who is sharing its extension.
                    if user
                        l.yes
                    else
                        l.no

                        l.logs 'Getting public user... '
                        user = BlackStack::Scraper::User.available_users(1).first 
                        if user
                            l.yes
                        else
                            l.no
                        end
                    end
                end

                l.log "Found user: #{user.nil? ? 'nil' : user.email}"

                # if I found a user, then assign the page to the user.
                if user.nil?
                    l.log "No online or available user found"
                else                
                    l.logs 'Assigning page to user... '
                    s = user.why_not_available_for_assignation
                    if s
                        l.logf "User not available: #{s}"
                    #elsif page.number > 1 && previous.upload_end_time.nil?
                    #    l.logf "Error: previous page has no upload_end_time"
                    #elsif page.number > 1 && (previous.parse_end_time.nil? || !previous.parse_success)
                    #    l.logf "Error: previous page has no parsed successfully yet"
                    else
                        page.assign(user)
                        l.done
                    end
                end
            end # if page
        l.done
        } # each order
    rescue => e
        l.logf e.message
    end

    # sleep for 5 seconds
    l.logs 'Sleeping for 60 seconds... '
    sleep 60 # reducing CRDB spendings
    l.done
    l.log ''

end # while (true)