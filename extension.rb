BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => 'dfy-leads',
    
    # Write a description here. It will be shown in the main dashboard of your MySaaS project.
    :description => 'Sales Navigator Scraping + Email Appending + Verification',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/leandrosardi/dfy-leads',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.0.1',

    # define the name of the author
    :author => 'Leandro Daniel Sardi',

    # what is the section to add this extension in either the top-bar, the footer, the dashboard.
    :services_section => 'Services',

    # show this extension as a service in the top bar?
    :show_in_top_bar => true,

    # show this extension as a service in the footer?
    :show_in_footer => true,

    # show this extension as a service in the dashboard?
    :show_in_dashboard => true,

    # list dependencies
    :dependencies => [
        { :extension => :leads, :version => '0.0.2' },
        { :extension => :emails, :version => '0.0.2' },
    ],

    # what are the screens to add in the leftbar
    :leftbar_icons => [
        { :label => 'orders', :icon => :search, :screen => :orders, },
        { :label => 'leads', :icon => :heart, :screen => :leads, },
    ],

    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'dfy-leads.pages', },
    ],

    # deployment routines
    :deployment_routines => [{
        :name => 'install-gems',
        :commands => [{ 
            # removed becuase of the issue https://github.com/leandrosardi/emails/issues/31
            #gem install --no-document google-api-client -v 0.53.0;
            :command => "
                gem install --no-document appending -v 1.0;
            ",
            :sudo => true,
        }],
    }],
})

# setup the I2P product description here
BlackStack::I2P::add_services([
    { 
        :code=>'dfy-leads', 
        :name=>'DFY Leads', 
        :unit_name=>'dfy-records', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'Sales Navigator Scraping + Email Appending + Verification.',
        # persuasive description to show in the sales letter
        :title=>'DFY Leads At 1 Cent Per Record.',
        # larger persuasive description to show in the sales letter
        :summary=>'You push an order with your target parameters. We do all the work. You get the results.',
        :thumbnail=>CS_HOME_WEBSITE+'/dfy-leads/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/dfy-leads/order/new',
        # what is the life time of this product or service?
        :credits_expiration_period => 'month',
        :credits_expiration_units => 1,
        # free tier configuration
        :free_tier=>{
            # add 10 records per month, for free
            :credits=>50,
            :period=>'month',
            :units=>1,
        },
        # most popular plan configuratioon
        :most_popular_plan => 'dfy-leads.batman',
    },
])

# defining Pampa jobs
BlackStack::Pampa.add_job({
  :name => 'dfy-leads.page.parse',

  # Minimum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 5, 
  
  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 15,  
  
  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :scr_page, # Note, that we are sending a class object here
  :field_primary_key => :id,
  :field_id => :parse_reservation_id,
  :field_time => :parse_reservation_time, 
  :field_times => :parse_reservation_times,
  :field_start_time => :parse_start_time,
  :field_end_time => :parse_end_time,
  :field_success => :parse_success,
  :field_error_description => :parse_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    # TODO: Code Me!
  end
})

# defining Pampa jobs
BlackStack::Pampa.add_job({
  :name => 'dfy-leads.order.assign',

  # Minimum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 1, 
  
  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 120,  
  
  # Maximum number of times that a task can be restarted.
  # Default: 3
  :max_try_times => 3,

  # Define the tasks table: each record is a task.
  # The tasks table must have some specific fields for handling the tasks dispatching.
  :table => :scr_page, # Note, that we are sending a class object here
  :field_primary_key => :id,
  :field_id => :upload_reservation_id,
  :field_time => :upload_reservation_time, 
  :field_times => :upload_reservation_times,
  :field_start_time => :upload_start_time,
  :field_end_time => :upload_end_time,
  :field_success => :upload_success,
  :field_error_description => :upload_error_description,

  # Function to execute for each task.
  :processing_function => Proc.new do |task, l, job, worker, *args|
    # TODO: Code Me!
  end
})

# setup the I2P plans descriptors here
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'dfy-leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfy-leads.robin', 
        :name=>'Robin', 
        # billing details
        :credits=>2500, 
        :normal_fee=>97, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>47, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'month',
        :expiration_lead_units => 1,
    }, {
        # which product is this plan belonging
        :service_code=>'dfy-leads', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_SUBSCRIPTION,  
        # show this plan in the UI
        :public=>true,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>false,  
        # plan description
        :item_number=>'dfy-leads.batman', 
        :name=>'Batman', 
        # billing details
        :credits=>10000, 
        :normal_fee=>197, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>97, # this is the fee that your will charge to the account, as a special offer price.
        :period=>'month',
        :units=>1, # billed monthy
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'month',
        :expiration_lead_units => 1,
    }
])