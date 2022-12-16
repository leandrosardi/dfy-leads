module BlackStack
    module DfyLeads
        @@html_storage_url = nil

        def self.html_storage_url
            @@html_storage_url
        end

        def self.set_html_storage_url(v)
            @@html_storage_url = v
        end
        
    end # module DfyLeads
end # module BlackStack