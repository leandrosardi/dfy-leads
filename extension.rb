BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => '<!your-github-repo-name-for-this-extension!>',
    
    # Write a description here. It will be shown in the main dashboard of your MySaaS project.
    :description => '<!extension-description-here!>',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/<!your-github-username!>/<!your-github-repo-name-for-this-extension!>',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.0.1',

    # define the name of the author
    :author => '<!your-github-username!>',

    # what is the section to add this extension in either the top-bar, the footer, the dashboard.
    :services_section => 'Education',
    # show this extension as a service in the top bar?
    :show_in_top_bar => true,
    # show this extension as a service in the footer?
    :show_in_footer => true,
    # show this extension as a service in the dashboard?
    :show_in_dashboard => true,

    :dependencies => [
        { :extension => :content, :version => '0.0.1' },
    ],

    # what are the screens to add in the leftbar
    :leftbar_icons => [
        { :label => 'results', :icon => :search, :screen => :results, },
        { :label => 'exports', :icon => :'cloud-download', :screen => :exports, },
        { :label => 'searches', :icon => :'save', :screen => :'saved_searches', },
    ],
 
    # add a folder to the storage from where user can download the exports.
    :storage_folders => [
        { :name => 'leads.exports', },
    ],

    # deployment routines
    :deployment_routines => [{
        :name => 'install-gems',
        :commands => [{ 
            :command => "
                gem install --no-document google-api-client -v 0.53.0;
                gem install --no-document mail -v 2.7.1;
            ",
            :sudo => true,
    }, {
        :name => 'start-offline-processes',
        :commands => [{ 
            # back up old configuration file
            # setup new configuration file
            :command => "
                source /home/%ssh_username%/.rvm/scripts/rvm; rvm install 3.1.2; rvm --default use 3.1.2;
                cd /home/%ssh_username%/code/mysaas/extensions/leads/p; 
                export RUBYLIB=/home/%ssh_username%/code/mysaas;
                nohup ruby export.rb;
            ",
            :sudo => false,
            :background => true,
        }, {
            # back up old configuration file
            # setup new configuration file
            :command => "
                source /home/%ssh_username%/.rvm/scripts/rvm; rvm install 3.1.2; rvm --default use 3.1.2;
                cd /home/%ssh_username%/code/mysaas/extensions/leads/p; 
                export RUBYLIB=/home/%ssh_username%/code/mysaas;
                nohup ruby stat.search.rb;
            ",
            :sudo => false,
            :background => true,
        }],
    }],

})

# setup the I2P product description here
BlackStack::I2P::add_services([
    { 
        :code=>'ces', 
        :name=>'Cold Emails Seminar', 
        :unit_name=>'access to cold emails seminar', 
        :consumption=>BlackStack::I2P::CONSUMPTION_BY_TIME, 
        # formal description to show in the list of products
        :description=>'Liftetime access to our Cold Emails Seminar.',
        # persuasive description to show in the sales letter
        :title=>'Learn how book meetings and close deals with cold emails, at an affordable cost.',
        # larger persuasive description to show in the sales letter
        :summary=>'This seminar teaches you how to get quality email databases at very low price, how deliver cold emails for free, and how to write cold emails in order to get responses.',
        :thumbnail=>CS_HOME_WEBSITE+'/ces/images/logo.png',
        :return_path=>CS_HOME_WEBSITE+'/ces/results',
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
        :most_popular_plan => 'leads.batman',
    },
])

# setup the I2P plans descriptors here
BlackStack::I2P::add_plans([
    {
        # which product is this plan belonging
        :service_code=>'ces', 
        # recurrent billing plan or one-time payments
        :type=>BlackStack::I2P::PAYMENT_PAY_AS_YOU_GO,  
        # show this plan in the UI
        :public=>false,
        # is this a One-Time Offer?
        # true: this plan is available only if the account has not any invoice using this plan
        # false: this plan can be purchased many times
        :one_time_offer=>true,  
        # plan description
        :item_number=>'ces.lifetime', 
        :name=>'Cold Emails Seminar - Lifetime Access', 
        # billing details
        :credits=>1, 
        :normal_fee=>97, # cognitive bias: expensive fee to show it strikethrough, as the normal price. But it's a lie. 
        :fee=>27, # this is the fee that your will charge to the account, as a special offer price.
        # Additional period after the billing cycle - Extend 2 weeks after the billing cycle - Referemce: https://github.com/ExpandedVenture/ConnectionSphere/issues/283.
        :expiration_lead_period => 'year',
        :expiration_lead_units => 1000,
    }
])