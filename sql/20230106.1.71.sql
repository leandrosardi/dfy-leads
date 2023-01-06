-- optimizing `/p/planner.rb`

create index if not exists IX_fl_location__id_country__is_state on fl_location(id_country, is_state);

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

create index IX_eml_delivery__is_response__create_time_desc on eml_delivery(is_response, create_time desc);

-- optimizing `/p/order.calculate.rb`

create index IX_scr_order__status__delete_time__dfyl_id_parent__dfyl_calculation_end_time on scr_order(status, delete_time, dfyl_id_parent, dfyl_calculation_end_time);

create index IX_scr_order__status__delete_time__dfyl_id_parent on scr_order(status, delete_time, dfyl_id_parent);

create index IX_scr_order__dfyl_id_parent on scr_order(dfyl_id_parent);

create index IX_scr_page__id_order__number on scr_page(id_order, number); 

create index IX_dfyl_result__id_page on dfyl_result(id_page);

create index IX_fl_lead__enrich_success__id on fl_lead(enrich_success, id);

create index IX_fl_data__verified__id_lead on fl_data(verified, id_lead);