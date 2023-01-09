-- optimizing dfy-leads

create index if not exists IX_scr_order__status__delete_time__dfyl_id_parent__dfyl_calculation_end_time on scr_order(status, delete_time, dfyl_id_parent, dfyl_calculation_end_time);

create index if not exists IX_scr_order__status__delete_time__dfyl_id_parent on scr_order(status, delete_time, dfyl_id_parent);

create index if not exists IX_scr_order__dfyl_id_parent on scr_order(dfyl_id_parent);

create index if not exists IX_scr_page__id_order__number on scr_page(id_order, number); 

create index if not exists IX_dfyl_result__id_page on dfyl_result(id_page);

create index if not exists IX_fl_lead__enrich_success__id on fl_lead(enrich_success, id);

create index if not exists IX_fl_data__verified__id_lead on fl_data(verified, id_lead);

create index if not exists IX_scr_page__id_order__upload_success__number on scr_page(id_order, upload_success, number);

create index if not exists IX_scr_page__upload_end_time__upload_reservation_time__upload_reservation_id_desc on scr_page(upload_end_time, upload_reservation_time, upload_reservation_id desc);

create index if not exists IX_scr_assignation__id_page__create_time_desc on scr_assignation(id_page, create_time desc);

create index if not exists IX_scr_assignation__id_user__create_time on scr_assignation(id_user, create_time);

create index if not exists IX_user__id_account__scraper_last_ping_time on "user"(id_account, scraper_last_ping_time);

create index if not exists IX_user__scraper_share__scraper_last_ping_time on "user"(scraper_share, scraper_last_ping_time);

create index if not exists IX_scr_page__upload_reservation_id__upload_end_time on scr_page(upload_reservation_id, upload_end_time);

create index if not exists IX_scr_order__status__url__id on scr_order(status, url, id);

create index if not exists IX_scr_page__id_order__upload_reservation_id__upload_success__upload_reservation_times on scr_page(id_order, upload_reservation_id, upload_success, upload_reservation_time);

create index if not exists IX_scr_page__upload_end_time__upload_reservation_time__upload_reservation_id on scr_page(upload_end_time, upload_reservation_time, upload_reservation_id);

create index if not exists IX_scr_page__id_order__number on scr_page(id_order, number);

create index if not exists IX_scr_assignation__id_page__create_time_desc on scr_assignation(id_page, create_time desc);

create index if not exists IX_scr_assignation__id_user__create_time_desc on scr_assignation(id_user, create_time desc);

create index if not exists IX_scr_page__upload_reservation_id__upload_end_time on scr_page(upload_reservation_id, upload_end_time);

create index if not exists IX_scr_assignation__id_user__id_page__year__month__day__hour__minute__second on scr_assignation(id_user, id_page, year, month, day, hour, minute, second);
