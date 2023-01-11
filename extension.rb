BlackStack::Extensions::add ({
    # descriptive name and descriptor
    :name => 'dfy-leads',
    
    # Write a description here. It will be shown in the main dashboard of your MySaaS project.
    :description => 'Sales Navigator Scraping + Email Appending + Verification',

    # setup the url of the repository for installation and updates
    :repo_url => 'https://github.com/leandrosardi/dfy-leads',
    :repo_branch => 'main',

    # define version with format <mayor>.<minor>.<revision>
    :version => '0.1.1',

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
        { :label => 'exports', :icon => :'cloud-download', :screen => :exports, },
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

# defining Pampa jobs
BlackStack::Pampa.add_job({
  :name => 'dfy-leads.page.parse',

  # Minimum number of tasks that a worker must have in queue.
  # Default: 5
  :queue_size => 5, 
  
  # Maximum number of minutes that a task should take to process.
  # If a tasks didn't finish X minutes after it started, it is restarted and assigned to another worker.
  # Default: 15
  :max_job_duration_minutes => 60,  
  
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

