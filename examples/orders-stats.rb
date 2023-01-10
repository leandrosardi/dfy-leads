# this example is about sending a test email to a user.

require 'mail'
require 'mysaas'
require 'lib/stubs'
require 'config'
DB = BlackStack::CRDB::connect
require 'lib/skeletons'
require 'extensions/leads/lib/skeletons'
require 'extensions/scraper/lib/skeletons'
require 'extensions/dfy-leads/lib/skeletons'

l = BlackStack::LocalLogger.new('./orders-stats.log')

# get all orders
BlackStack::DfyLeads::Order.order(:name).all { |o|
    l.logs "order #{o.name} (#{o.id})..."
    o.update_stats
    l.done
}