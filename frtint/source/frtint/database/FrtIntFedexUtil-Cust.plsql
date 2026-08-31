-----------------------------------------------------------------------------
--
--  Logical unit: FrtIntFedexUtil
--  Component:    FRTINT
--
--  IFS Developer Studio Template Version 3.0
--
--  Date        Sign        History
--  ----------  ----------  ---------------------------------------------------------
--  260819         I006, Created - FedEx direct API integration utility
--  260826    Rate ops: full Sr_Shipment_Rates_Rec assignment, log trace on Get_Shipment_Rates/Get_Cust_Order_Rates
-----------------------------------------------------------------------------

layer Cust;


-------------------- PUBLIC DECLARATIONS ------------------------------------

SUBTYPE Fe_Shipment_Confirm_Rec IS Frt_Int_FedEx_Message_Util_API.Fe_Shipment_Confirm_Rec;
SUBTYPE Sr_Shipment_Rates_Rec   IS Frt_Int_Message_Util_API.Sr_Shipment_Rates_Rec;


-------------------- PRIVATE DECLARATIONS -----------------------------------

SUBTYPE Fe_Rate_Arr            IS Frt_Int_FedEx_Message_Util_API.Fe_Rate_Arr;
SUBTYPE Fe_Create_Ship_Request_Rec IS Frt_Int_FedEx_Message_Util_API.Fe_Create_Ship_Request_Rec;
SUBTYPE Fe_Confirm_Request_Rec IS Frt_Int_FedEx_Message_Util_API.Fe_Confirm_Request_Rec;
SUBTYPE Fe_Delete_Request_Rec  IS Frt_Int_FedEx_Message_Util_API.Fe_Delete_Request_Rec;
SUBTYPE Fe_Rate_Request_Rec    IS Frt_Int_FedEx_Message_Util_API.Fe_Rate_Request_Rec;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Get_Config_Values___ (
   freight_provider_  IN  VARCHAR2,
   client_id_         OUT VARCHAR2,
   client_secret_     OUT VARCHAR2,
   account_no_        OUT VARCHAR2,
   log_trace_         OUT VARCHAR2)
IS
   CURSOR get_config IS
      SELECT config_id, config_value
        FROM frt_provider_config_value_tab
       WHERE freight_provider_id = freight_provider_;
BEGIN
   FOR cfg_ IN get_config LOOP
      CASE cfg_.config_id
         WHEN 'CLIENT_ID'      THEN client_id_     := cfg_.config_value;
         WHEN 'CLIENT_SECRET'  THEN client_secret_  := cfg_.config_value;
         WHEN 'ACCOUNT_NUMBER' THEN account_no_     := cfg_.config_value;
         WHEN 'IFS_LOGTRACE'   THEN log_trace_      := cfg_.config_value;
         ELSE NULL;
      END CASE;
   END LOOP;
END Get_Config_Values___;


FUNCTION Get_Auth_Token___ (
   freight_provider_  IN VARCHAR2) RETURN VARCHAR2
IS
   client_id_      VARCHAR2(200);
   client_secret_  VARCHAR2(200);
   account_no_     VARCHAR2(20);
   log_trace_      VARCHAR2(5);
   query_params_   Plsqlap_Document_API.Document;
   url_params_     Plsqlap_Document_API.Document;
   request_hdr_    VARCHAR2(2000) := 'Content-Type: application/x-www-form-urlencoded';
   token_body_     CLOB;
BEGIN
   Get_Config_Values___(freight_provider_, client_id_, client_secret_, account_no_, log_trace_);

   token_body_ := 'grant_type=client_credentials'
               || '&client_id='     || UTL_URL.escape(client_id_,     FALSE)
               || '&client_secret=' || UTL_URL.escape(client_secret_, FALSE);

   query_params_ := Plsqlap_Document_API.New_Document('QUERY_PARAMETERS');
   url_params_   := Plsqlap_Document_API.New_Document('URL_PARAMETERS');

   Plsql_Rest_Sender_API.Call_Rest_EndPoint_Json_Sync(
      rest_service_     => 'FEDEX_GET_AUTH_TOKEN',
      json_             => token_body_,
      url_params_       => url_params_,
      http_method_      => 'POST',
      http_req_headers_ => request_hdr_,
      query_parameters_ => query_params_,
      fnd_user_         => Fnd_Session_API.Get_Fnd_User);

   IF token_body_ IS NOT NULL THEN
      RETURN JSON_VALUE(token_body_, '$.access_token');
   END IF;
   RETURN NULL;
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('FrtIntFedExUtil.Get_Auth_Token___: ' || SQLERRM);
      RETURN NULL;
END Get_Auth_Token___;


FUNCTION Get_Request_Headers___ (
   token_ IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   RETURN 'Authorization: Bearer ' || token_
       || CHR(10) || 'Content-Type: application/json';
END Get_Request_Headers___;


FUNCTION Get_Shipment_Index___ (
   freight_provider_  IN VARCHAR2,
   transaction_id_    IN VARCHAR2) RETURN VARCHAR2
IS
   prefix_  VARCHAR2(20);
BEGIN
   prefix_ := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'TRANSACTION_PREFIX');
   RETURN NVL(prefix_, '') || transaction_id_;
END Get_Shipment_Index___;


FUNCTION Call_Fedex_Endpoint___ (
   token_        IN  VARCHAR2,
   service_name_ IN  VARCHAR2,
   request_body_ IN  Json_Object_T,
   http_method_  IN  VARCHAR2 DEFAULT 'POST',
   url_param_1_  IN  VARCHAR2 DEFAULT NULL) RETURN Json_Object_T
IS
   query_params_   Plsqlap_Document_API.Document;
   url_params_     Plsqlap_Document_API.Document;
   request_hdr_    VARCHAR2(4000);
   request_clob_   CLOB;
BEGIN
   query_params_ := Plsqlap_Document_API.New_Document('QUERY_PARAMETERS');
   url_params_   := Plsqlap_Document_API.New_Document('URL_PARAMETERS');
   IF url_param_1_ IS NOT NULL THEN
      Plsqlap_Document_API.Add_Attribute(url_params_, 'URL_PARAM_1', url_param_1_);
   END IF;
   request_hdr_ := Get_Request_Headers___(token_);

   IF request_body_ IS NOT NULL THEN
      request_clob_ := request_body_.to_clob;
   END IF;

   Plsql_Rest_Sender_API.Call_Rest_EndPoint_Json_Sync(
      rest_service_     => service_name_,
      json_             => request_clob_,
      url_params_       => url_params_,
      http_method_      => http_method_,
      http_req_headers_ => request_hdr_,
      query_parameters_ => query_params_,
      fnd_user_         => Fnd_Session_API.Get_Fnd_User);

   IF request_clob_ IS NOT NULL THEN
      RETURN TREAT(Json_Object_T.parse(request_clob_) AS Json_Object_T);
   END IF;
   RETURN NULL;
END Call_Fedex_Endpoint___;


FUNCTION Parse_Error_Message___ (
   response_json_ IN Json_Object_T) RETURN VARCHAR2
IS
   errors_arr_  Json_Array_T;
   error_obj_   Json_Object_T;
   msg_         VARCHAR2(4000);
BEGIN
   IF response_json_ IS NULL THEN
      RETURN 'No response received from FedEx API.';
   END IF;
   errors_arr_ := TREAT(response_json_.get('errors') AS Json_Array_T);
   IF errors_arr_ IS NULL THEN RETURN NULL; END IF;
   FOR i_ IN 0..LEAST(errors_arr_.get_size - 1, 4) LOOP
      error_obj_ := TREAT(errors_arr_.get(i_) AS Json_Object_T);
      IF error_obj_ IS NOT NULL THEN
         msg_ := msg_ || error_obj_.get_string('code') || ': '
              || error_obj_.get_string('message') || ' ';
      END IF;
   END LOOP;
   RETURN TRIM(msg_);
END Parse_Error_Message___;


FUNCTION Create_And_Confirm___ (
   freight_provider_  IN  VARCHAR2,
   transaction_id_    IN  VARCHAR2,
   create_req_        IN  Fe_Create_Ship_Request_Rec,
   token_             IN  VARCHAR2,
   error_message_     OUT VARCHAR2) RETURN Fe_Shipment_Confirm_Rec
IS
   confirm_rec_    Fe_Shipment_Confirm_Rec;
   create_json_    Json_Object_T;
   create_resp_    Json_Object_T;
   confirm_req_    Fe_Confirm_Request_Rec;
   confirm_json_   Json_Object_T;
   confirm_resp_   Json_Object_T;
   err_msg_        VARCHAR2(4000);
BEGIN
   create_json_ := Frt_Int_FedEx_Message_Util_API.Create_Ship_Req_To_Json(create_req_);
   create_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_CREATE_OPEN_SHIPMENT', create_json_);
   err_msg_ := Parse_Error_Message___(create_resp_);
   IF err_msg_ IS NOT NULL THEN
      error_message_ := 'Create Open Shipment failed: ' || err_msg_;
      RETURN confirm_rec_;
   END IF;

   confirm_req_.account_number       := create_req_.account_number;
   confirm_req_.index_               := create_req_.index_;
   confirm_req_.label_response_options := 'LABEL';
   confirm_req_.label_specification  := create_req_.requested_shipment.label_specification;
   confirm_json_ := Frt_Int_FedEx_Message_Util_API.Confirm_Req_To_Json(confirm_req_);
   confirm_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_CONFIRM_OPEN_SHIPMENT', confirm_json_);
   err_msg_ := Parse_Error_Message___(confirm_resp_);
   IF err_msg_ IS NOT NULL THEN
      error_message_ := 'Confirm Open Shipment failed: ' || err_msg_;
      RETURN confirm_rec_;
   END IF;

   confirm_rec_ := Frt_Int_FedEx_Message_Util_API.Json_To_Confirm_Rec(confirm_resp_);
   RETURN confirm_rec_;
END Create_And_Confirm___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU CUST NEW METHODS ------------------------------------

PROCEDURE Send_Shipment (
   transaction_id_     IN  VARCHAR2,
   shipment_id_        IN  NUMBER,
   shipment_trans_url_ OUT VARCHAR2,
   error_message_      OUT VARCHAR2,
   frt_provider_       IN  VARCHAR2 DEFAULT NULL)
IS
   provider_       VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   token_          VARCHAR2(2000);
   index_          VARCHAR2(50);
   create_req_     Fe_Create_Ship_Request_Rec;
   confirm_rec_    Fe_Shipment_Confirm_Rec;
   request_json_   Json_Object_T;
   log_trace_      VARCHAR2(5);
   err_msg_        VARCHAR2(4000);
BEGIN
   log_trace_ := Frt_Provider_Config_Value_API.Get_Config_Value(provider_, 'IFS_LOGTRACE');

   token_ := Get_Auth_Token___(provider_);
   IF token_ IS NULL THEN
      error_message_ := 'Failed to obtain FedEx OAuth token. Check CLIENT_ID and CLIENT_SECRET configuration.';
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         SUBSTR(error_message_, 1, 2000));
      RETURN;
   END IF;

   index_ := Get_Shipment_Index___(provider_, transaction_id_);
   create_req_ := Frt_Int_FedEx_Message_Util_API.Get_Create_Ship_Request_Rec(provider_, shipment_id_, index_);
   request_json_ := Frt_Int_FedEx_Message_Util_API.Create_Ship_Req_To_Json(create_req_);

   confirm_rec_ := Create_And_Confirm___(provider_, transaction_id_, create_req_, token_, err_msg_);

   IF err_msg_ IS NOT NULL THEN
      error_message_ := err_msg_;
      IF log_trace_ = 'TRUE' THEN
         Frt_Int_Ship_Util_API.Log_Shipment_Trace(
            freight_provider_id_ => provider_,
            transaction_id_      => transaction_id_,
            interface_           => 'FEDEX_SHIPMENT',
            source_ref_type_     => Frt_Source_Ref_Type_API.DB_SHIPMENT,
            source_ref_          => TO_CHAR(shipment_id_),
            freight_msg_type_    => Frt_Message_Type_API.DB_SHIPMENT,
            request_             => request_json_,
            response_            => NULL,
            status_              => 'Error',
            error_message_       => err_msg_);
      END IF;
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         SUBSTR(err_msg_, 1, 2000));
      RETURN;
   END IF;

   shipment_trans_url_ := confirm_rec_.master_tracking_number;
   Frt_Transaction_API.Modify_Provider_Url(
      Frt_Source_Ref_Type_API.DB_SHIPMENT,
      TO_CHAR(shipment_id_),
      Frt_Message_Type_API.DB_SHIPMENT,
      shipment_trans_url_);

   IF log_trace_ = 'TRUE' THEN
      Frt_Int_Ship_Util_API.Log_Shipment_Trace(
         freight_provider_id_ => provider_,
         transaction_id_      => transaction_id_,
         interface_           => 'FEDEX_SHIPMENT',
         source_ref_type_     => Frt_Source_Ref_Type_API.DB_SHIPMENT,
         source_ref_          => TO_CHAR(shipment_id_),
         freight_msg_type_    => Frt_Message_Type_API.DB_SHIPMENT,
         request_             => request_json_,
         response_            => NULL,
         status_              => 'Completed');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      error_message_ := SQLERRM;
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         SUBSTR(error_message_, 1, 2000));
END Send_Shipment;


PROCEDURE Void_Shipment (
   transaction_id_  IN  VARCHAR2,
   shipment_id_     IN  NUMBER,
   cancel_result_   OUT VARCHAR2,
   error_msg_       OUT VARCHAR2,
   frt_provider_    IN  VARCHAR2 DEFAULT NULL)
IS
   provider_     VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   token_        VARCHAR2(2000);
   index_        VARCHAR2(50);
   del_req_      Fe_Delete_Request_Rec;
   del_json_     Json_Object_T;
   del_resp_     Json_Object_T;
   err_msg_      VARCHAR2(4000);
   output_obj_   Json_Object_T;
BEGIN
   token_ := Get_Auth_Token___(provider_);
   IF token_ IS NULL THEN
      error_msg_ := 'Failed to obtain FedEx OAuth token.';
      RETURN;
   END IF;

   index_ := Get_Shipment_Index___(provider_, transaction_id_);
   del_req_.account_number.value := Frt_Provider_Config_Value_API.Get_Config_Value(provider_, 'ACCOUNT_NUMBER');
   del_req_.index_               := index_;

   del_json_ := Frt_Int_FedEx_Message_Util_API.Delete_Req_To_Json(del_req_);
   del_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_DELETE_OPEN_SHIPMENT', del_json_, 'PUT');

   err_msg_ := Parse_Error_Message___(del_resp_);
   IF err_msg_ IS NOT NULL THEN
      error_msg_     := err_msg_;
      cancel_result_ := 'Failed';
      RETURN;
   END IF;

   output_obj_ := TREAT(del_resp_.get('output') AS Json_Object_T);
   IF output_obj_ IS NOT NULL AND output_obj_.get_string('deletedOpenshipment') = 'true' THEN
      cancel_result_ := 'Success';
   ELSE
      cancel_result_ := 'Success';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      error_msg_     := SQLERRM;
      cancel_result_ := 'Failed';
END Void_Shipment;


PROCEDURE Get_Shipment_Rates (
   shipment_rates_  OUT Sr_Shipment_Rates_Rec,
   transaction_id_  IN  VARCHAR2,
   shipment_id_     IN  NUMBER,
   error_message_   OUT VARCHAR2,
   origin_          IN  VARCHAR2 DEFAULT NULL,
   auto_pack_       IN  VARCHAR2 DEFAULT 'FALSE',
   ship_via_code_   IN  VARCHAR2,
   frt_provider_    IN  VARCHAR2)
IS
   provider_      VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   token_         VARCHAR2(2000);
   rate_req_      Fe_Rate_Request_Rec;
   rate_json_     Json_Object_T;
   rate_resp_     Json_Object_T;
   fe_rates_      Fe_Rate_Arr;
   err_msg_       VARCHAR2(4000);
BEGIN
   token_ := Get_Auth_Token___(provider_);
   IF token_ IS NULL THEN
      error_message_ := 'Failed to obtain FedEx OAuth token.';
      RETURN;
   END IF;

   rate_req_ := Frt_Int_FedEx_Message_Util_API.Get_Rate_Request_Rec(provider_, shipment_id_);
   IF ship_via_code_ IS NOT NULL THEN
      rate_req_.requested_shipment.service_type := ship_via_code_;
   END IF;

   rate_json_ := Frt_Int_FedEx_Message_Util_API.Rate_Request_To_Json(rate_req_);
   rate_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_GET_RATES', rate_json_);

   err_msg_ := Parse_Error_Message___(rate_resp_);
   IF err_msg_ IS NULL THEN
      fe_rates_       := Frt_Int_FedEx_Message_Util_API.Json_To_Rate_Arr(rate_resp_);
      shipment_rates_ := Frt_Int_FedEx_Message_Util_API.Json_To_Sr_Rate_Arr(fe_rates_);
   ELSE
      error_message_ := err_msg_;
   END IF;

   Frt_Int_Ship_Util_API.Log_Shipment_Trace(
      freight_provider_id_ => provider_,
      transaction_id_      => transaction_id_,
      interface_           => 'RECEIVE_SHIPMENT_RATES_FROM_FEDEX',
      source_ref_type_     => Frt_Source_Ref_Type_API.DB_SHIPMENT,
      source_ref_          => TO_CHAR(shipment_id_),
      freight_msg_type_    => Frt_Message_Type_API.DB_RATE,
      request_             => rate_json_,
      response_            => rate_resp_,
      status_              => CASE WHEN err_msg_ IS NULL THEN 'Success' ELSE 'Warning' END,
      error_message_       => err_msg_);
EXCEPTION
   WHEN OTHERS THEN
      error_message_ := SQLERRM;
END Get_Shipment_Rates;


PROCEDURE Get_Cust_Order_Rates (
   shipment_rates_  OUT Sr_Shipment_Rates_Rec,
   transaction_id_  IN  VARCHAR2,
   order_no_        IN  VARCHAR2,
   error_message_   OUT VARCHAR2,
   origin_          IN  VARCHAR2 DEFAULT NULL,
   auto_pack_       IN  VARCHAR2 DEFAULT 'TRUE',
   ship_via_code_   IN  VARCHAR2,
   frt_provider_    IN  VARCHAR2)
IS
   provider_      VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   token_         VARCHAR2(2000);
   rate_req_      Fe_Rate_Request_Rec;
   rate_json_     Json_Object_T;
   rate_resp_     Json_Object_T;
   fe_rates_      Fe_Rate_Arr;
   err_msg_       VARCHAR2(4000);
BEGIN
   token_ := Get_Auth_Token___(provider_);
   IF token_ IS NULL THEN
      error_message_ := 'Failed to obtain FedEx OAuth token.';
      RETURN;
   END IF;

   rate_req_ := Frt_Int_FedEx_Message_Util_API.Get_Order_Rate_Request_Rec(provider_, order_no_);
   IF ship_via_code_ IS NOT NULL THEN
      rate_req_.requested_shipment.service_type := ship_via_code_;
   END IF;

   rate_json_ := Frt_Int_FedEx_Message_Util_API.Rate_Request_To_Json(rate_req_);
   rate_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_GET_RATES', rate_json_);

   err_msg_ := Parse_Error_Message___(rate_resp_);
   IF err_msg_ IS NULL THEN
      fe_rates_       := Frt_Int_FedEx_Message_Util_API.Json_To_Rate_Arr(rate_resp_);
      shipment_rates_ := Frt_Int_FedEx_Message_Util_API.Json_To_Sr_Rate_Arr(fe_rates_);
   ELSE
      error_message_ := err_msg_;
   END IF;

   Frt_Int_Ship_Util_API.Log_Shipment_Trace(
      freight_provider_id_ => provider_,
      transaction_id_      => transaction_id_,
      interface_           => 'RECEIVE_ORDER_RATES_FROM_FEDEX',
      source_ref_type_     => Frt_Source_Ref_Type_API.DB_CUSTOMER_ORDER,
      source_ref_          => order_no_,
      freight_msg_type_    => Frt_Message_Type_API.DB_RATE,
      request_             => rate_json_,
      response_            => rate_resp_,
      status_              => CASE WHEN err_msg_ IS NULL THEN 'Success' ELSE 'Warning' END,
      error_message_       => err_msg_);
EXCEPTION
   WHEN OTHERS THEN
      error_message_ := SQLERRM;
END Get_Cust_Order_Rates;


FUNCTION Get_Shipment_Confirm (
   transaction_id_   IN  VARCHAR2,
   shipment_id_      IN  NUMBER,
   shipment_confirm_ OUT Fe_Shipment_Confirm_Rec,
   frt_provider_     IN  VARCHAR2) RETURN BOOLEAN
IS
   provider_       VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   token_          VARCHAR2(2000);
   index_          VARCHAR2(50);
   confirm_req_    Fe_Confirm_Request_Rec;
   confirm_json_   Json_Object_T;
   confirm_resp_   Json_Object_T;
   err_msg_        VARCHAR2(4000);
BEGIN
   token_ := Get_Auth_Token___(provider_);
   IF token_ IS NULL THEN RETURN FALSE; END IF;

   index_ := Get_Shipment_Index___(provider_, transaction_id_);
   confirm_req_.account_number.value  := Frt_Provider_Config_Value_API.Get_Config_Value(provider_, 'ACCOUNT_NUMBER');
   confirm_req_.index_                := index_;
   confirm_req_.label_response_options := 'LABEL';
   confirm_req_.label_specification.image_type       := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(provider_, 'LABEL_IMAGE_TYPE'), 'PNG');
   confirm_req_.label_specification.label_stock_type := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(provider_, 'LABEL_STOCK_TYPE'), 'PAPER_4X6');

   confirm_json_ := Frt_Int_FedEx_Message_Util_API.Confirm_Req_To_Json(confirm_req_);
   confirm_resp_ := Call_Fedex_Endpoint___(token_, 'FEDEX_CONFIRM_OPEN_SHIPMENT', confirm_json_);

   err_msg_ := Parse_Error_Message___(confirm_resp_);
   IF err_msg_ IS NOT NULL THEN RETURN FALSE; END IF;

   shipment_confirm_ := Frt_Int_FedEx_Message_Util_API.Json_To_Confirm_Rec(confirm_resp_);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END Get_Shipment_Confirm;


PROCEDURE Process_Shipment (
   transaction_id_  IN VARCHAR2,
   shipment_id_     IN NUMBER,
   frt_provider_    IN VARCHAR2)
IS
   provider_        VARCHAR2(30) := NVL(frt_provider_, Frt_Int_Ship_Util_API.Get_Freight_Provider);
   confirm_rec_     Fe_Shipment_Confirm_Rec;
   confirm_json_    Json_Object_T;
   erp_status_      VARCHAR2(30);
   err_msg_         VARCHAR2(2000);
   success_         BOOLEAN;
BEGIN
   success_ := Get_Shipment_Confirm(transaction_id_, shipment_id_, confirm_rec_, provider_);
   IF NOT success_ THEN
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         'FedEx Process_Shipment: re-confirm failed.');
      RETURN;
   END IF;

   confirm_json_ := Json_Object_T();
   confirm_json_.put('masterTrackingNumber', confirm_rec_.master_tracking_number);
   confirm_json_.put('trackingNumber',       confirm_rec_.tracking_number);
   confirm_json_.put('netChargeAmount',      confirm_rec_.net_charge_amount);
   confirm_json_.put('currency',             confirm_rec_.currency);

   IF Frt_Int_Ship_Util_API.Update_Shipment(
         freight_provider_  => provider_,
         transaction_id_    => transaction_id_,
         source_ref_type_   => Frt_Source_Ref_Type_API.DB_SHIPMENT,
         source_ref_        => TO_CHAR(shipment_id_),
         freight_msg_type_  => Frt_Message_Type_API.DB_SHIPMENT,
         shipment_confirm_  => confirm_json_,
         erp_status_        => erp_status_,
         err_msg_           => err_msg_) THEN
      Frt_Int_Ship_Util_API.Set_Shipment_Freight_Status(
         freight_provider_  => provider_,
         source_ref_type_   => Frt_Source_Ref_Type_API.DB_SHIPMENT,
         source_ref_        => TO_CHAR(shipment_id_),
         freight_msg_type_  => Frt_Message_Type_API.DB_SHIPMENT,
         status_            => 'Completed');
   ELSE
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         SUBSTR(err_msg_, 1, 2000));
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      Frt_Transaction_API.Set_Error_Message(
         Frt_Source_Ref_Type_API.DB_SHIPMENT,
         TO_CHAR(shipment_id_),
         Frt_Message_Type_API.DB_SHIPMENT,
         SUBSTR(SQLERRM, 1, 2000));
END Process_Shipment;


PROCEDURE Reconfirm_Shipment (
   transaction_id_  IN VARCHAR2,
   shipment_id_     IN NUMBER,
   frt_provider_    IN VARCHAR2)
IS
BEGIN
   Process_Shipment(transaction_id_, shipment_id_, frt_provider_);
END Reconfirm_Shipment;


--(+) 260819  I006 (START)
PROCEDURE Update_Co_Freight_Charges (
   order_no_           IN VARCHAR2,
   service_type_       IN VARCHAR2,
   total_net_charge_   IN NUMBER,
   currency_           IN VARCHAR2,
   frt_provider_       IN VARCHAR2)
IS
   total_weight_  NUMBER := 0;
   line_weight_   NUMBER;
   line_charge_   NUMBER;
   info_          VARCHAR2(2000);
   objid_         VARCHAR2(100);
   objvers_       VARCHAR2(200);
   attr_          VARCHAR2(32000);
   weight_uom_    VARCHAR2(10);

   CURSOR get_lines IS
      SELECT col.line_no,
             col.rel_no,
             col.line_item_no,
             col.buy_qty_due * NVL(Sales_Part_API.Get_Gross_Weight(col.contract, col.catalog_no), 0) AS line_weight
        FROM customer_order_line_tab col
       WHERE col.order_no     = order_no_
         AND col.line_item_no = 0
         AND col.rowstate NOT IN ('Cancelled');

   TYPE line_weight_tab IS TABLE OF get_lines%ROWTYPE INDEX BY PLS_INTEGER;
   lines_  line_weight_tab;
   idx_    PLS_INTEGER := 1;
BEGIN
   weight_uom_ := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(frt_provider_, 'WEIGHT_UOM'), 'LB');

   FOR rec_ IN get_lines LOOP
      lines_(idx_) := rec_;
      total_weight_ := total_weight_ + rec_.line_weight;
      idx_ := idx_ + 1;
   END LOOP;

   IF total_weight_ = 0 OR lines_.COUNT = 0 THEN RETURN; END IF;

   FOR i_ IN 1..lines_.COUNT LOOP
      line_charge_ := ROUND(total_net_charge_ * (lines_(i_).line_weight / total_weight_), 2);

      BEGIN
         SELECT objid, objversion
           INTO objid_, objvers_
           FROM customer_order_charge
          WHERE order_no    = order_no_
            AND line_no     = lines_(i_).line_no
            AND rel_no      = lines_(i_).rel_no
            AND line_item_no = lines_(i_).line_item_no
            AND charge_type = 'FRTCHRG'
            AND ROWNUM      = 1;
         Customer_Order_Charge_API.Remove__(info_, objid_, objvers_, 'DO');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr('ORDER_NO',      order_no_,            attr_);
      Client_SYS.Add_To_Attr('LINE_NO',        lines_(i_).line_no,   attr_);
      Client_SYS.Add_To_Attr('REL_NO',         lines_(i_).rel_no,    attr_);
      Client_SYS.Add_To_Attr('LINE_ITEM_NO',   lines_(i_).line_item_no, attr_);
      Client_SYS.Add_To_Attr('CHARGE_TYPE',    'FRTCHRG',            attr_);
      Client_SYS.Add_To_Attr('CHARGE_AMOUNT',  line_charge_,         attr_);
      Client_SYS.Add_To_Attr('CHARGE_COST',    line_charge_,         attr_);
Client_SYS.Add_To_Attr('CHARGE_AMOUNT_INCL_TAX', line_charge_, attr_);
      Customer_Order_Charge_API.New__(info_, objid_, objvers_, attr_, 'DO');
   END LOOP;
END Update_Co_Freight_Charges;
--(+) 260819  I006 (FINISH)
