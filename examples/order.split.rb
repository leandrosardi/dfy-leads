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

l = BlackStack::LocalLogger.new('./order.split.log')

BlackStack::DfyLeads::Order.where(
    :id=>['45343c57-034b-454d-b60d-6eb33aef40e0', '95c76e9d-9b0e-4895-80bf-87d63369d7f0']
).all { |o|
    l.logs "#{o.name}... "
    o.split(l)
    l.done
}


exit(0)
