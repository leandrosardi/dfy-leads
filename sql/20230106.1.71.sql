-- optimizing `/p/planner.rb`
create index if not exists IX_scr_order__dfyl_id_parent on scr_order(dfyl_id_parent);

create index if not exists IX_fl_location__id_country__is_state on fl_location(id_country, is_state);

create index if not exists IX_scr_order__status__delete_time__dfyl_id_parent on scr_order(status, delete_time, dfyl_id_parent);

create index if not exists IX_eml_delivery__message_id on eml_delivery(message_id);

create index if not exists IX_eml_followup__delete_time__status on eml_followup(delete_time, "status");

create index if not exists IX_eml_outreach__id_campaign on eml_outreach(id_campaign); 

create index if not exists IX_eml_delivery__id_address__is_response___delivery_end_time on eml_delivery(id_address, is_response, delivery_end_time); 

create index if not exists IX_eml_followup__id_campaign on eml_followup(id_Campaign);

create index if not exists IX_eml_campaign__id_export on eml_campaign(id_export);

create index if not exists IX_fl_export_lead__id_export on fl_export_lead(id_export);

create index if not exists IX_eml_delivery__id_lead__delivery_success__delivery_end_time on eml_delivery(id_lead, delivery_success, delivery_end_time);

create index if not exists IX_eml_followup__id_campaign__sequence_number on eml_followup(id_campaign, sequence_number);

create index if not exists IX_fl_data__id_lead__type__verified__trust_rate on fl_data(id_lead, type, verified, trust_rate);


