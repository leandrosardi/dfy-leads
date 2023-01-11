# default screen
get "/dfy-leads", :agent => /(.*)/ do
    redirect2 "/dfy-leads/orders", params
end
get "/dfy-leads/", :agent => /(.*)/ do
    redirect2 "/dfy-leads/orders", params
end

get "/dfy-leads/leads", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/results", :layout => :"/views/layouts/core"
end

get "/dfy-leads/exports", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/leads/views/exports", :layout => :"/views/layouts/core"
end

get "/dfy-leads/orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/orders", :layout => :"/views/layouts/core"
end

get "/dfy-leads/orders/new", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/new_order", :layout => :"/views/layouts/core"
end

get "/dfy-leads/orders/:oid/edit", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/edit_order", :layout => :"/views/layouts/core"
end

# filters
post "/dfy-leads/filter_new_order", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_new_order"
end

post "/dfy-leads/filter_edit_order", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_edit_order"
end

post "/dfy-leads/filter_delete_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_delete_orders"
end
get "/dfy-leads/filter_delete_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_delete_orders"
end

post "/dfy-leads/filter_pause_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_pause_orders"
end
get "/dfy-leads/filter_pause_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_pause_orders"
end

post "/dfy-leads/filter_play_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_play_orders"
end
get "/dfy-leads/filter_play_orders", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_play_orders"
end

post "/dfy-leads/filter_view_results", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_view_results"
end
get "/dfy-leads/filter_view_results", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_view_results"
end
