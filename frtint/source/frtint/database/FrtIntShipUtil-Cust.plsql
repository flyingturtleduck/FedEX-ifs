-----------------------------------------------------------------------------
--
--  Logical unit: FrtIntShipUtil
--  Component:    FRTINT
--
--  IFS Developer Studio Template Version 3.0
--
--  Date        Sign        History
--  ----------  ----------  ---------------------------------------------------------
--  260819         I006, Added FedEx direct API dispatch and new utility methods
-----------------------------------------------------------------------------

layer Cust;


-------------------- PUBLIC DECLARATIONS ------------------------------------

SUBTYPE Pj_Carrier_Service_Arr IS Frt_Int_Message_Util_API.Pj_Carrier_Service_Arr;
SUBTYPE Sr_Shipment_Rates_Rec  IS Frt_Int_Message_Util_API.Sr_Shipment_Rates_Rec;
SUBTYPE Sp_Origin_Rec          IS Frt_Int_Message_Util_API.Sp_Origin_Rec;


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Returns the active default freight provider ID.
FUNCTION Get_Freight_Provider RETURN VARCHAR2
IS
   provider_  VARCHAR2(30);
   CURSOR get_default IS
      SELECT freight_provider_id
        FROM frt_provider_config_tab
       WHERE active         = 'TRUE'
         AND default_provider = 'YES'
         AND ROWNUM = 1;
BEGIN
   OPEN  get_default;
   FETCH get_default INTO provider_;
   CLOSE get_default;
   RETURN provider_;
END Get_Freight_Provider;


PROCEDURE Send_Shipment (
   transaction_id_     IN  VARCHAR2,
   shipment_id_        IN  NUMBER,
   shipment_trans_url_ OUT VARCHAR2,
   error_message_      OUT VARCHAR2,
   freight_provider_id_ IN VARCHAR2 DEFAULT NULL)
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   Shipment_API.Exist(shipment_id_);
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Send_Shipment(
         transaction_id_     => transaction_id_,
         shipment_id_        => shipment_id_,
         shipment_trans_url_ => shipment_trans_url_,
         error_message_      => error_message_,
         frt_provider_       => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Send_Shipment(
         transaction_id_     => transaction_id_,
         shipment_id_        => shipment_id_,
         shipment_trans_url_ => shipment_trans_url_,
         error_message_      => error_message_,
         frt_provider_       => provider_);
   END IF;
END Send_Shipment;


PROCEDURE Void_Shipment (
   transaction_id_     IN  VARCHAR2,
   shipment_id_        IN  NUMBER,
   cancel_result_      OUT VARCHAR2,
   error_msg_          OUT VARCHAR2,
   freight_provider_id_ IN VARCHAR2 DEFAULT NULL)
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Void_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         cancel_result_  => cancel_result_,
         error_msg_      => error_msg_,
         frt_provider_   => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Void_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         cancel_result_  => cancel_result_,
         error_msg_      => error_msg_,
         frt_provider_   => provider_);
   END IF;
END Void_Shipment;


PROCEDURE Get_Shipment_Rates (
   shipment_rates_     OUT Sr_Shipment_Rates_Rec,
   transaction_id_     IN  VARCHAR2,
   shipment_id_        IN  NUMBER,
   error_message_      OUT VARCHAR2,
   origin_             IN  Sp_Origin_Rec DEFAULT NULL,
   auto_pack_          IN  VARCHAR2 DEFAULT 'FALSE',
   ship_via_code_      IN  VARCHAR2,
   frt_provider_       IN  VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(frt_provider_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Get_Shipment_Rates(
         shipment_rates_ => shipment_rates_,
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         error_message_  => error_message_,
         ship_via_code_  => ship_via_code_,
         frt_provider_   => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Get_Shipment_Rates(
         shipment_rates_ => shipment_rates_,
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         error_message_  => error_message_,
         origin_         => origin_,
         auto_pack_      => auto_pack_,
         ship_via_code_  => ship_via_code_,
         frt_provider_   => provider_);
   END IF;
END Get_Shipment_Rates;


PROCEDURE Get_Cust_Order_Rates (
   shipment_rates_     OUT Sr_Shipment_Rates_Rec,
   transaction_id_     IN  VARCHAR2,
   order_no_           IN  VARCHAR2,
   error_message_      OUT VARCHAR2,
   origin_             IN  Sp_Origin_Rec DEFAULT NULL,
   auto_pack_          IN  VARCHAR2 DEFAULT 'TRUE',
   ship_via_code_      IN  VARCHAR2,
   frt_provider_       IN  VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(frt_provider_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Get_Cust_Order_Rates(
         shipment_rates_ => shipment_rates_,
         transaction_id_ => transaction_id_,
         order_no_       => order_no_,
         error_message_  => error_message_,
         ship_via_code_  => ship_via_code_,
         frt_provider_   => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Get_Cust_Order_Rates(
         shipment_rates_ => shipment_rates_,
         transaction_id_ => transaction_id_,
         order_no_       => order_no_,
         error_message_  => error_message_,
         origin_         => origin_,
         auto_pack_      => auto_pack_,
         ship_via_code_  => ship_via_code_,
         frt_provider_   => provider_);
   END IF;
END Get_Cust_Order_Rates;


PROCEDURE Process_Shipment (
   transaction_id_     IN VARCHAR2,
   shipment_id_        IN NUMBER,
   freight_provider_id_ IN VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Process_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         frt_provider_   => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Process_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         frt_provider_   => provider_);
   END IF;
END Process_Shipment;


PROCEDURE Reconfirm_Shipment (
   transaction_id_     IN VARCHAR2,
   shipment_id_        IN NUMBER,
   freight_provider_id_ IN VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Reconfirm_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         frt_provider_   => provider_);
   ELSE
      Frt_Int_Pacejet_Util_API.Reconfirm_Shipment(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         frt_provider_   => provider_);
   END IF;
END Reconfirm_Shipment;


FUNCTION Update_Shipment (
   freight_provider_  IN  VARCHAR2,
   transaction_id_    IN  VARCHAR2,
   source_ref_type_   IN  VARCHAR2,
   source_ref_        IN  VARCHAR2,
   freight_msg_type_  IN  VARCHAR2,
   shipment_confirm_  IN  Json_Object_T,
   erp_status_        OUT VARCHAR2,
   err_msg_           OUT VARCHAR2) RETURN BOOLEAN
IS
   provider_    VARCHAR2(30) := NVL(freight_provider_, Get_Freight_Provider);
   fe_confirm_  Frt_Int_FedEx_Message_Util_API.Fe_Shipment_Confirm_Rec;
   sc_confirm_  Frt_Int_Message_Util_API.Sc_Shipment_Confirm_Rec;
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      fe_confirm_.master_tracking_number := shipment_confirm_.get_string('masterTrackingNumber');
      fe_confirm_.tracking_number        := shipment_confirm_.get_string('trackingNumber');
      fe_confirm_.net_charge_amount      := NVL(shipment_confirm_.get_number('netChargeAmount'), 0);
      fe_confirm_.currency               := shipment_confirm_.get_string('currency');
      BEGIN
         fe_confirm_.encoded_label := shipment_confirm_.get_clob('encodedLabel');
      EXCEPTION WHEN OTHERS THEN NULL;
      END;
      DECLARE
         upd_info_  VARCHAR2(32000);
         upd_attr_  VARCHAR2(32000);
      BEGIN
         Client_SYS.Clear_Attr(upd_attr_);
         Client_SYS.Add_To_Attr('MASTER_TRACKING_NO',
            NVL(fe_confirm_.tracking_number, fe_confirm_.master_tracking_number), upd_attr_);
         Frt_Transaction_API.Modify(upd_info_, upd_attr_, source_ref_type_, source_ref_, freight_msg_type_);
      END;
      --(+) 260819  I006 (START)
      IF source_ref_type_ = Frt_Source_Ref_Type_API.DB_SHIPMENT AND fe_confirm_.master_tracking_number IS NOT NULL THEN
         DECLARE
            info_       VARCHAR2(2000);
            objid_      VARCHAR2(100);
            objvers_    VARCHAR2(200);
            attr_       VARCHAR2(32000);
         BEGIN
            SELECT ROWID, TO_CHAR(rowversion, 'YYYYMMDDHH24MISS')
              INTO objid_, objvers_
              FROM shipment_tab
             WHERE shipment_id = TO_NUMBER(source_ref_);
            Client_SYS.Clear_Attr(attr_);
            Client_SYS.Add_To_Attr('PRO_NO', fe_confirm_.master_tracking_number, attr_);
            IF fe_confirm_.pickup_date IS NOT NULL THEN
               Client_SYS.Add_To_Attr('PLANNED_SHIP_DATE', TO_DATE(fe_confirm_.pickup_date, 'YYYY-MM-DD'), attr_);
            END IF;
            Shipment_API.Modify__(info_, objid_, objvers_, attr_, 'DO');
         EXCEPTION
            WHEN OTHERS THEN NULL;
         END;
      END IF;
      --(+) 260819  I006 (FINISH)
      erp_status_ := 'Success';
      RETURN TRUE;
   ELSE
      sc_confirm_ := Frt_Int_Message_Util_API.Json_To_Shipment_Confirm_Rec(shipment_confirm_);
      RETURN Frt_Transaction_Util_API.Update_Transaction(
         source_ref_type_  => source_ref_type_,
         source_ref_       => source_ref_,
         freight_msg_type_ => freight_msg_type_,
         shipment_confirm_ => sc_confirm_,
         erp_status_       => erp_status_,
         err_msg_          => err_msg_);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      err_msg_    := SQLERRM;
      erp_status_ := 'Failed';
      Log_Shipment_Trace(
         freight_provider_id_ => provider_,
         transaction_id_      => transaction_id_,
         interface_           => 'ERP_UPDATE_SHIPMENT',
         source_ref_type_     => source_ref_type_,
         source_ref_          => source_ref_,
         freight_msg_type_    => freight_msg_type_,
         request_             => NULL,
         response_            => NULL,
         status_              => 'Warning',
         error_message_       => err_msg_);
      RETURN FALSE;
END Update_Shipment;


FUNCTION Get_Shipment (
   transaction_id_     IN  VARCHAR2,
   shipment_id_        IN  NUMBER,
   shipment_status_    OUT VARCHAR2,
   freight_provider_id_ IN VARCHAR2 DEFAULT NULL) RETURN Json_Object_T
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   RETURN Frt_Int_Pacejet_Util_API.Get_Shipment(
      transaction_id_  => transaction_id_,
      shipment_id_     => shipment_id_,
      shipment_status_ => shipment_status_,
      frt_provider_    => provider_);
END Get_Shipment;


PROCEDURE Get_Shipment_Confirms_List (
   freight_provider_id_ IN VARCHAR2)
IS
BEGIN
   IF freight_provider_id_ NOT LIKE 'FEDEX%' THEN
      Frt_Int_Pacejet_Util_API.Get_Shipment_Confirms_List(freight_provider_id_);
   END IF;
END Get_Shipment_Confirms_List;


PROCEDURE Send_Shipment_Confirm (
   transaction_id_      IN VARCHAR2,
   shipment_id_         IN NUMBER,
   freight_provider_id_ IN VARCHAR2 DEFAULT NULL,
   erp_status_          IN VARCHAR2 DEFAULT 'Success',
   status_msg_          IN VARCHAR2 DEFAULT 'Shipment Confirmed in the ERP')
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   IF provider_ NOT LIKE 'FEDEX%' THEN
      Frt_Int_Pacejet_Util_API.Send_Shipment_Confirm(
         transaction_id_ => transaction_id_,
         shipment_id_    => shipment_id_,
         frt_provider_   => provider_,
         erp_status_     => erp_status_,
         status_msg_     => status_msg_);
   END IF;
END Send_Shipment_Confirm;


FUNCTION Get_Carrier_Services (
   freight_provider_id_ IN VARCHAR2) RETURN Pj_Carrier_Service_Arr
IS
BEGIN
   RETURN Frt_Int_Pacejet_Util_API.Get_Carrier_Services(freight_provider_id_);
END Get_Carrier_Services;


FUNCTION Get_Freight_Facilities (
   freight_provider_id_ IN VARCHAR2) RETURN CLOB
IS
BEGIN
   RETURN Frt_Int_Pacejet_Util_API.Get_Freight_Facilities(freight_provider_id_);
END Get_Freight_Facilities;


-------------------- LU CUST NEW METHODS ------------------------------------

PROCEDURE Set_Shipment_Freight_Status (
   freight_provider_  IN VARCHAR2,
   source_ref_type_   IN VARCHAR2,
   source_ref_        IN VARCHAR2,
   freight_msg_type_  IN VARCHAR2,
   status_            IN VARCHAR2,
   error_message_     IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
   CASE status_
      WHEN 'Completed' THEN
         Frt_Transaction_API.Set_Completed(source_ref_type_, source_ref_, freight_msg_type_);
      WHEN 'Confirmed' THEN
         Frt_Transaction_API.Set_Confirmed(source_ref_type_, source_ref_, freight_msg_type_);
      WHEN 'Pending' THEN
         Frt_Transaction_API.Set_Pending(source_ref_type_, source_ref_, freight_msg_type_);
      WHEN 'Void' THEN
         Frt_Transaction_API.Set_Void(source_ref_type_, source_ref_, freight_msg_type_);
      ELSE NULL;
   END CASE;
END Set_Shipment_Freight_Status;


PROCEDURE Log_Shipment_Trace (
   freight_provider_id_  IN VARCHAR2,
   transaction_id_       IN VARCHAR2,
   interface_            IN VARCHAR2,
   source_ref_type_      IN VARCHAR2,
   source_ref_           IN VARCHAR2,
   freight_msg_type_     IN VARCHAR2,
   request_              IN Json_Element_T,
   response_             IN Json_Element_T,
   status_               IN VARCHAR2,
   error_message_        IN VARCHAR2 DEFAULT NULL)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   log_trace_  VARCHAR2(5);
   req_clob_   CLOB;
   resp_clob_  CLOB;
BEGIN
   log_trace_ := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_id_, 'IFS_LOGTRACE');
   IF NVL(log_trace_, 'FALSE') != 'TRUE' THEN
      @ApproveTransactionStatement(2026-08-19,obaid.ashraf)
      ROLLBACK;
      RETURN;
   END IF;
   IF request_  IS NOT NULL THEN req_clob_  := request_.to_clob;  END IF;
   IF response_ IS NOT NULL THEN resp_clob_ := response_.to_clob; END IF;
   Frt_Int_Log_Trace_API.New_Update(
      freight_provider_id_ => freight_provider_id_,
      transaction_id_      => transaction_id_,
      interface_           => interface_,
      source_ref_type_     => source_ref_type_,
      source_ref_          => source_ref_,
      freight_msg_type_    => freight_msg_type_,
      request_             => req_clob_,
      response_            => resp_clob_,
      status_              => status_,
      error_message_       => error_message_);
   IF status_ = 'Error' AND Frt_Transaction_API.Exists(source_ref_type_, source_ref_, freight_msg_type_) THEN
      Frt_Transaction_API.Set_Error_Message(source_ref_type_, source_ref_, freight_msg_type_,
         SUBSTR(error_message_, 1, 2000));
   END IF;
   @ApproveTransactionStatement(2026-08-19,obaid.ashraf)
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      @ApproveTransactionStatement(2026-08-19,obaid.ashraf)
      ROLLBACK;
END Log_Shipment_Trace;


PROCEDURE Process_Response_Error (
   frt_provider_error_  OUT VARCHAR2,
   freight_provider_id_ IN  VARCHAR2,
   transaction_id_      IN  VARCHAR2,
   interface_           IN  VARCHAR2,
   source_ref_type_     IN  VARCHAR2,
   source_ref_          IN  VARCHAR2,
   freight_msg_type_    IN  VARCHAR2,
   request_             IN  Json_Object_T,
   response_            IN  Json_Object_T)
IS
   provider_   VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
   err_msg_    VARCHAR2(4000);
   errors_arr_ Json_Array_T;
   error_obj_  Json_Object_T;
   -- PaceJet error fields
   code_       VARCHAR2(200);
   severity_   VARCHAR2(200);
   message_    VARCHAR2(2000);
   more_info_  VARCHAR2(2000);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      IF response_ IS NOT NULL THEN
         errors_arr_ := TREAT(response_.get('errors') AS Json_Array_T);
         IF errors_arr_ IS NOT NULL THEN
            FOR i_ IN 0..LEAST(errors_arr_.get_size - 1, 4) LOOP
               error_obj_ := TREAT(errors_arr_.get(i_) AS Json_Object_T);
               IF error_obj_ IS NOT NULL THEN
                  code_    := error_obj_.get_string('code');
                  message_ := error_obj_.get_string('message');
                  err_msg_ := err_msg_ || code_ || ': ' || message_ || ' ';
               END IF;
            END LOOP;
         END IF;
      END IF;
   ELSE
      IF response_ IS NOT NULL THEN
         code_      := response_.get_string('code');
         severity_  := response_.get_string('severity');
         message_   := response_.get_string('message');
         more_info_ := response_.get_string('moreInfo');
         err_msg_   := severity_ || ' (' || code_ || '): ' || message_;
         IF more_info_ IS NOT NULL THEN
            err_msg_ := err_msg_ || ' ' || more_info_;
         END IF;
      END IF;
   END IF;

   frt_provider_error_ := TRIM(err_msg_);
   Log_Shipment_Trace(
      freight_provider_id_ => provider_,
      transaction_id_      => transaction_id_,
      interface_           => interface_,
      source_ref_type_     => source_ref_type_,
      source_ref_          => source_ref_,
      freight_msg_type_    => freight_msg_type_,
      request_             => request_,
      response_            => response_,
      status_              => 'Error',
      error_message_       => frt_provider_error_);
END Process_Response_Error;


--(+) 260819  I006 (START)
PROCEDURE Update_Co_Freight_Charges (
   order_no_           IN VARCHAR2,
   service_type_       IN VARCHAR2,
   total_net_charge_   IN NUMBER,
   currency_           IN VARCHAR2,
   frt_provider_       IN VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(frt_provider_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      Frt_Int_FedEx_Util_API.Update_Co_Freight_Charges(
         order_no_          => order_no_,
         service_type_      => service_type_,
         total_net_charge_  => total_net_charge_,
         currency_          => currency_,
         frt_provider_      => provider_);
   END IF;
END Update_Co_Freight_Charges;
--(+) 260819  I006 (FINISH)


PROCEDURE Reprocess_Transaction (
   transaction_id_    IN VARCHAR2,
   source_ref_        IN VARCHAR2,
   source_ref_type_   IN VARCHAR2,
   freight_msg_type_  IN VARCHAR2,
   interface_         IN VARCHAR2,
   freight_provider_id_ IN VARCHAR2)
IS
   provider_  VARCHAR2(30) := NVL(freight_provider_id_, Get_Freight_Provider);
BEGIN
   IF provider_ LIKE 'FEDEX%' THEN
      NULL; -- FedEx reprocess: re-send via Send_Shipment from the calling context
   ELSE
      Frt_Int_Pacejet_Util_API.Reprocess_Transaction(
         transaction_id_   => transaction_id_,
         source_ref_       => source_ref_,
         source_ref_type_  => source_ref_type_,
         freight_msg_type_ => freight_msg_type_,
         interface_        => interface_,
         frt_provider_     => provider_);
   END IF;
END Reprocess_Transaction;
