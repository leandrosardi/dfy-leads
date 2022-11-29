# default screen
get "/<!your-github-repo-name-for-this-extension!>", :agent => /(.*)/ do
    redirect2 "/seminars/pub/<!your-github-repo-name-for-this-extension!>-generation/cold-emails-seminar", params
end
get "/<!your-github-repo-name-for-this-extension!>/", :agent => /(.*)/ do
    redirect2 "/seminars/pub/<!your-github-repo-name-for-this-extension!>-generation/cold-emails-seminar", params
end

# public screens (signup/landing page)
get "/<!your-github-repo-name-for-this-extension!>/signup", :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/signup"
end

# public screens (login page)
get "/<!your-github-repo-name-for-this-extension!>/login", :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/login", :layout => :"/views/layouts/public"
end

# internal wizard (funnel) screens
get "/<!your-github-repo-name-for-this-extension!>/step1", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/step1", :layout => :"/views/layouts/public"
end

get "/<!your-github-repo-name-for-this-extension!>/step2", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/step2", :layout => :"/views/layouts/public"
end

get "/<!your-github-repo-name-for-this-extension!>/offer", :auth => true, :agent => /(.*)/ do
    account = BlackStack::I2P::Account.where(:id=>@login.user.id_account).first
    if account.disabled_trial?
        redirect '/<!your-github-repo-name-for-this-extension!>/plans' 
    else
        erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/offer", :layout => :"/views/layouts/public"
    end
end

# internal app screens
get "/<!your-github-repo-name-for-this-extension!>/plans", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/plans", :layout => :"/views/layouts/core"
end

get "/<!your-github-repo-name-for-this-extension!>/dashboard", :auth => true, :agent => /(.*)/ do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/dashboard", :layout => :"/views/layouts/core"
end

# filters
post "/<!your-github-repo-name-for-this-extension!>/filter_landing" do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/filter_landing"
end

post "/<!your-github-repo-name-for-this-extension!>/filter_step1", :auth => true do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/filter_step1"
end

post "/<!your-github-repo-name-for-this-extension!>/filter_step2", :auth => true do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/filter_step2"
end

get "/<!your-github-repo-name-for-this-extension!>/filter_offer", :auth => true do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/filter_offer"
end

# AJAX 
post "/ajax/<!your-github-repo-name-for-this-extension!>/rename_export_list.json", :auth => true do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/ajax/rename_export_list"
end

# API
post "/api1.0/<!your-github-repo-name-for-this-extension!>/create_export_list.json", :api_key => true do
    erb :"/extensions/<!your-github-repo-name-for-this-extension!>/views/api1.0/create_export_list"
end
