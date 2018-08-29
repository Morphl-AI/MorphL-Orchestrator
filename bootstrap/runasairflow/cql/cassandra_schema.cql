CREATE KEYSPACE IF NOT EXISTS morphl WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

CREATE TABLE morphl.ga_churned_users (
  client_id text,
  day_of_data_capture date,
  json_meta text,
  json_data text,
  PRIMARY KEY ((client_id), day_of_data_capture)
) WITH CLUSTERING ORDER BY (day_of_data_capture DESC);

CREATE TABLE morphl.ga_churned_users_sessions (
  client_id text,
  day_of_data_capture date,
  session_id text,
  json_meta text,
  json_data text,
  PRIMARY KEY ((client_id), day_of_data_capture, session_id)
) WITH CLUSTERING ORDER BY (day_of_data_capture DESC);

CREATE TABLE morphl.ga_churned_users_features_training_raw (
  client_id text,
  day_of_data_capture date,
  session_id text,
  session_count double,
  days_since_last_session double,
  s_sessions double,
  pageviews double,
  unique_pageviews double,
  screen_views double,
  hits double,
  time_on_page double,
  u_sessions double,
  session_duration double,
  entrances double,
  bounces double,
  exits double,
  page_value double,
  page_load_time double,
  page_load_sample double,
  is_desktop double,
  is_mobile double,
  is_tablet double,
  PRIMARY KEY ((client_id), day_of_data_capture, session_id)
) WITH CLUSTERING ORDER BY (day_of_data_capture DESC);

CREATE TABLE morphl.ga_churned_users_features_training_enriched (
  client_id text,
  day_of_data_capture date,
  session_id text,
  s_sessions double,
  pageviews double,
  unique_pageviews double,
  time_on_page double,
  u_sessions double,
  session_duration double,
  entrances double,
  bounces double,
  exits double,
  is_desktop double,
  is_mobile double,
  is_tablet double,
  churned double,
  PRIMARY KEY ((client_id), day_of_data_capture, session_id)
) WITH CLUSTERING ORDER BY (day_of_data_capture DESC);

CREATE TABLE morphl.ga_churned_users_valid_models (
  always_zero int,
  day_as_str text,
  unique_hash text,
  is_model_valid boolean,
  PRIMARY KEY ((always_zero), day_as_str, unique_hash)
) WITH CLUSTERING ORDER BY (day_as_str DESC);

CREATE TABLE morphl.config_parameters (
  morphl_component_name text,
  parameter_name text,
  parameter_value text,
  PRIMARY KEY ((morphl_component_name, parameter_name))
);

INSERT INTO morphl.config_parameters (morphl_component_name,parameter_name,parameter_value)
VALUES ('ga_pyspark','days_worth_of_data_to_load','60');

CREATE TABLE morphl.ps_area (
  client_id text,
  day_of_data_capture date,
  days_since_last_seen int,
  PRIMARY KEY ((client_id), day_of_data_capture)
) WITH CLUSTERING ORDER BY (day_of_data_capture DESC);

INSERT INTO morphl.ps_area (client_id,day_of_data_capture,days_since_last_seen)
VALUES ('GA1','2018-07-01',15);
INSERT INTO morphl.ps_area (client_id,day_of_data_capture,days_since_last_seen)
VALUES ('GA2','2018-07-03',25);
INSERT INTO morphl.ps_area (client_id,day_of_data_capture,days_since_last_seen)
VALUES ('GA1','2018-07-05',4);
INSERT INTO morphl.ps_area (client_id,day_of_data_capture,days_since_last_seen)
VALUES ('GA2','2018-07-10',6);
