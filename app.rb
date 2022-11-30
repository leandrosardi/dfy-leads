# default screen
get "/dfy-leads", :agent => /(.*)/ do
    redirect2 "/dfy-leads/signup", params
end
get "/dfy-leads/", :agent => /(.*)/ do
    redirect2 "/dfy-leads/signup", params
end
get "/dfy-leads/login", :agent => /(.*)/ do
    redirect2 "/login", params
end

# public screens (signup/landing page)
get "/dfy-leads/signup", :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/signup", :layout => :"/views/layouts/public"
end

# internal app screens
get "/dfy-leads/offer", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/offer", :layout => :"/views/layouts/core"
end

get "/dfy-leads/plans", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/plans", :layout => :"/views/layouts/core"
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
    erb :"/extensions/dfy-leads/views/filter_new_order"
end

post "/dfy-leads/filter_delete_order", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_new_order"
end

post "/dfy-leads/filter_pause_order", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_new_order"
end

post "/dfy-leads/filter_play_order", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/dfy-leads/views/filter_new_order"
end
