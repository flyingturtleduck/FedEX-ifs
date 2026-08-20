-----------------------------------------------------------------------------
--
--  Logical unit: FedexMessageUtil
--  Component:    FRTINT
--
--  IFS Developer Studio Template Version 3.0
--
--  Date        Sign        History
--  ----------  ----------  ---------------------------------------------------------
--  260819         I006, Created - FedEx JSON message types and serialization
-----------------------------------------------------------------------------

layer Cust;


-------------------- PUBLIC DECLARATIONS ------------------------------------

-- Address and party types

TYPE Fe_Account_Number_Rec IS RECORD (
   value          VARCHAR2(9));

TYPE Fe_Address_Rec IS RECORD (
   address_line_1          VARCHAR2(35),
   address_line_2          VARCHAR2(35),
   address_line_3          VARCHAR2(35),
   city                    VARCHAR2(100),
   state_or_province_code  VARCHAR2(2),
   postal_code             VARCHAR2(10),
   country_code            VARCHAR2(2),
   residential             VARCHAR2(5));   -- 'true' / 'false'

TYPE Fe_Contact_Rec IS RECORD (
   person_name        VARCHAR2(70),
   email_address      VARCHAR2(80),
   phone_number       VARCHAR2(15),
   phone_extension    VARCHAR2(6),
   company_name       VARCHAR2(35));

TYPE Fe_Party_Rec IS RECORD (
   address   Fe_Address_Rec,
   contact   Fe_Contact_Rec);

TYPE Fe_Recipients_Arr IS TABLE OF Fe_Party_Rec INDEX BY PLS_INTEGER;

-- Weight, dimensions, money

TYPE Fe_Weight_Rec IS RECORD (
   units   VARCHAR2(2),    -- KG or LB
   value   NUMBER);

TYPE Fe_Dimensions_Rec IS RECORD (
   length  INTEGER,
   width   INTEGER,
   height  INTEGER,
   units   VARCHAR2(2));   -- IN or CM

TYPE Fe_Money_Rec IS RECORD (
   amount    NUMBER,
   currency  VARCHAR2(3));

-- Package line items

TYPE Fe_Customer_Ref_Rec IS RECORD (
   customer_reference_type  VARCHAR2(50),
   value                    VARCHAR2(200));

TYPE Fe_Customer_Ref_Arr IS TABLE OF Fe_Customer_Ref_Rec INDEX BY PLS_INTEGER;

TYPE Fe_Package_Line_Item_Rec IS RECORD (
   sequence_number      VARCHAR2(10),
   weight               Fe_Weight_Rec,
   dimensions           Fe_Dimensions_Rec,
   group_package_count  INTEGER,
   declared_value       Fe_Money_Rec,
   customer_references  Fe_Customer_Ref_Arr,
   item_description     VARCHAR2(50));

TYPE Fe_Package_Line_Item_Arr IS TABLE OF Fe_Package_Line_Item_Rec INDEX BY PLS_INTEGER;

-- Payment / billing

TYPE Fe_Payor_Rec IS RECORD (
   payment_type    VARCHAR2(30),   -- SENDER | RECIPIENT | THIRD_PARTY | COLLECT
   account_number  Fe_Account_Number_Rec,
   country_code    VARCHAR2(2));

-- Label specification

TYPE Fe_Label_Spec_Rec IS RECORD (
   image_type          VARCHAR2(10),    -- PNG | PDF | ZPLII | EPL2
   label_stock_type    VARCHAR2(50),    -- PAPER_4X6 etc.
   label_format_type   VARCHAR2(30));   -- COMMON2D | LABEL_DATA_ONLY

-- Customs / international

TYPE Fe_Commodity_Rec IS RECORD (
   description              VARCHAR2(450),
   name                     VARCHAR2(200),
   harmonized_code          VARCHAR2(20),
   country_of_manufacture   VARCHAR2(2),
   part_number              VARCHAR2(50),
   quantity                 INTEGER,
   quantity_units           VARCHAR2(10),
   number_of_pieces         INTEGER,
   weight                   Fe_Weight_Rec,
   customs_value            Fe_Money_Rec,
   unit_price               Fe_Money_Rec);

TYPE Fe_Commodity_Arr IS TABLE OF Fe_Commodity_Rec INDEX BY PLS_INTEGER;

TYPE Fe_Commercial_Invoice_Rec IS RECORD (
   terms_of_sale    VARCHAR2(3),    -- DDU | DDP | EXW | CIP | FCA etc.
   shipment_purpose VARCHAR2(30));  -- SOLD | GIFT | SAMPLE | NOT_SOLD etc.

TYPE Fe_Customs_Detail_Rec IS RECORD (
   commodities          Fe_Commodity_Arr,
   duties_payment_type  VARCHAR2(30),   -- SENDER | RECIPIENT | THIRD_PARTY
   total_customs_value  Fe_Money_Rec,
   commercial_invoice   Fe_Commercial_Invoice_Rec);

-- Full shipment request

TYPE Fe_Requested_Shipment_Rec IS RECORD (
   ship_datestamp                VARCHAR2(10),
   pickup_type                   VARCHAR2(50),
   service_type                  VARCHAR2(50),
   packaging_type                VARCHAR2(30),
   total_weight                  NUMBER,
   shipper                       Fe_Party_Rec,
   recipients                    Fe_Recipients_Arr,
   payor                         Fe_Payor_Rec,
   rate_request_type             VARCHAR2(50),
   requested_package_line_items  Fe_Package_Line_Item_Arr,
   label_specification           Fe_Label_Spec_Rec,
   customs_clearance_detail      Fe_Customs_Detail_Rec,
   include_customs               BOOLEAN);

TYPE Fe_Create_Ship_Request_Rec IS RECORD (
   account_number       Fe_Account_Number_Rec,
   index_               VARCHAR2(50),
   open_shipment_action VARCHAR2(30),   -- CREATE_PACKAGE | STRONG_VALIDATION
   requested_shipment   Fe_Requested_Shipment_Rec);

TYPE Fe_Confirm_Request_Rec IS RECORD (
   account_number          Fe_Account_Number_Rec,
   index_                  VARCHAR2(50),
   label_response_options  VARCHAR2(10),   -- LABEL | URL_ONLY
   label_specification     Fe_Label_Spec_Rec);

TYPE Fe_Delete_Request_Rec IS RECORD (
   account_number  Fe_Account_Number_Rec,
   index_          VARCHAR2(50));

-- Rate request

TYPE Fe_Rate_Requested_Shipment_Rec IS RECORD (
   shipper                       Fe_Party_Rec,
   recipient                     Fe_Party_Rec,
   pickup_type                   VARCHAR2(50),
   service_type                  VARCHAR2(50),
   rate_request_type             VARCHAR2(50),
   return_transit_times          VARCHAR2(5),   -- 'true' | 'false'
   requested_package_line_items  Fe_Package_Line_Item_Arr);

TYPE Fe_Rate_Request_Rec IS RECORD (
   account_number      Fe_Account_Number_Rec,
   requested_shipment  Fe_Rate_Requested_Shipment_Rec);

-- Rate and confirm response types

TYPE Fe_Rate_Rec IS RECORD (
   service_type                 VARCHAR2(50),
   service_name                 VARCHAR2(100),
   currency                     VARCHAR2(3),
   total_net_charge             NUMBER,
   total_base_charge            NUMBER,
   fuel_surcharge_percent       NUMBER,
   transit_days                 VARCHAR2(30),
   arrival_date                 DATE);

TYPE Fe_Rate_Arr IS TABLE OF Fe_Rate_Rec INDEX BY PLS_INTEGER;

TYPE Fe_Shipment_Confirm_Rec IS RECORD (
   master_tracking_number  VARCHAR2(40),
   tracking_number         VARCHAR2(40),
   encoded_label           CLOB,
   service_type            VARCHAR2(50),
   service_name            VARCHAR2(100),
   net_charge_amount       NUMBER,
   currency                VARCHAR2(3),
   delivery_timestamp      VARCHAR2(30),
   pickup_date             VARCHAR2(20));

SUBTYPE Sr_Shipment_Rate_Arr IS Frt_Int_Message_Util_API.Sr_Shipment_Rate_Arr;


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Json_Put___ (
   json_     IN OUT NOCOPY Json_Object_T,
   name_     IN            VARCHAR2,
   value_    IN            VARCHAR2,
   null_ok_  IN            BOOLEAN DEFAULT FALSE)
IS
BEGIN
   IF (value_ IS NOT NULL) THEN
      json_.put(name_, value_);
   ELSIF null_ok_ THEN
      json_.put_null(name_);
   END IF;
END Json_Put___;


PROCEDURE Json_Put___ (
   json_     IN OUT NOCOPY Json_Object_T,
   name_     IN            VARCHAR2,
   value_    IN            NUMBER,
   null_ok_  IN            BOOLEAN DEFAULT FALSE)
IS
BEGIN
   IF (value_ IS NOT NULL) THEN
      json_.put(name_, value_);
   ELSIF null_ok_ THEN
      json_.put_null(name_);
   END IF;
END Json_Put___;


FUNCTION Address_To_Json___ (
   rec_ IN Fe_Address_Rec) RETURN Json_Object_T
IS
   json_        Json_Object_T := Json_Object_T();
   lines_arr_   Json_Array_T  := Json_Array_T();
BEGIN
   IF rec_.address_line_1 IS NOT NULL THEN
      lines_arr_.append(rec_.address_line_1);
   END IF;
   IF rec_.address_line_2 IS NOT NULL THEN
      lines_arr_.append(rec_.address_line_2);
   END IF;
   IF rec_.address_line_3 IS NOT NULL THEN
      lines_arr_.append(rec_.address_line_3);
   END IF;
   IF lines_arr_.get_size > 0 THEN
      json_.put('streetLines', lines_arr_);
   END IF;
   Json_Put___(json_, 'city',                   rec_.city);
   Json_Put___(json_, 'stateOrProvinceCode',     rec_.state_or_province_code);
   Json_Put___(json_, 'postalCode',              rec_.postal_code);
   Json_Put___(json_, 'countryCode',             rec_.country_code);
   IF rec_.residential IS NOT NULL THEN
      json_.put('residential', (rec_.residential = 'true'));
   END IF;
   RETURN json_;
END Address_To_Json___;


FUNCTION Contact_To_Json___ (
   rec_ IN Fe_Contact_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'personName',    rec_.person_name);
   Json_Put___(json_, 'emailAddress',  rec_.email_address);
   Json_Put___(json_, 'phoneNumber',   rec_.phone_number);
   Json_Put___(json_, 'phoneExtension', rec_.phone_extension);
   Json_Put___(json_, 'companyName',   rec_.company_name);
   RETURN json_;
END Contact_To_Json___;


FUNCTION Party_To_Json___ (
   rec_ IN Fe_Party_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   json_.put('address', Address_To_Json___(rec_.address));
   json_.put('contact', Contact_To_Json___(rec_.contact));
   RETURN json_;
END Party_To_Json___;


FUNCTION Weight_To_Json___ (
   rec_ IN Fe_Weight_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'units', rec_.units);
   Json_Put___(json_, 'value', rec_.value);
   RETURN json_;
END Weight_To_Json___;


FUNCTION Dimensions_To_Json___ (
   rec_ IN Fe_Dimensions_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'length', rec_.length);
   Json_Put___(json_, 'width',  rec_.width);
   Json_Put___(json_, 'height', rec_.height);
   Json_Put___(json_, 'units',  rec_.units);
   RETURN json_;
END Dimensions_To_Json___;


FUNCTION Money_To_Json___ (
   rec_ IN Fe_Money_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'amount',   rec_.amount);
   Json_Put___(json_, 'currency', rec_.currency);
   RETURN json_;
END Money_To_Json___;


FUNCTION Package_Item_To_Json___ (
   rec_     IN  Fe_Package_Line_Item_Rec,
   seq_no_  IN  INTEGER) RETURN Json_Object_T
IS
   json_     Json_Object_T := Json_Object_T();
   refs_arr_ Json_Array_T  := Json_Array_T();
   ref_json_ Json_Object_T;
BEGIN
   json_.put('sequenceNumber', NVL(rec_.sequence_number, TO_CHAR(seq_no_)));
   json_.put('weight', Weight_To_Json___(rec_.weight));
   IF rec_.dimensions.length IS NOT NULL THEN
      json_.put('dimensions', Dimensions_To_Json___(rec_.dimensions));
   END IF;
   IF rec_.group_package_count IS NOT NULL AND rec_.group_package_count > 1 THEN
      json_.put('groupPackageCount', rec_.group_package_count);
   END IF;
   IF rec_.declared_value.amount IS NOT NULL THEN
      json_.put('declaredValue', Money_To_Json___(rec_.declared_value));
   END IF;
   IF rec_.item_description IS NOT NULL THEN
      Json_Put___(json_, 'itemDescription', rec_.item_description);
   END IF;
   IF rec_.customer_references.COUNT > 0 THEN
      FOR i_ IN rec_.customer_references.FIRST..rec_.customer_references.LAST LOOP
         ref_json_ := Json_Object_T();
         ref_json_.put('customerReferenceType', rec_.customer_references(i_).customer_reference_type);
         ref_json_.put('value', rec_.customer_references(i_).value);
         refs_arr_.append(ref_json_);
      END LOOP;
      json_.put('customerReferences', refs_arr_);
   END IF;
   RETURN json_;
END Package_Item_To_Json___;


FUNCTION Commodity_To_Json___ (
   rec_ IN Fe_Commodity_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'description',           rec_.description);
   Json_Put___(json_, 'name',                  rec_.name);
   Json_Put___(json_, 'harmonizedCode',        rec_.harmonized_code);
   Json_Put___(json_, 'countryOfManufacture',  rec_.country_of_manufacture);
   Json_Put___(json_, 'partNumber',            rec_.part_number);
   Json_Put___(json_, 'quantityUnits',         rec_.quantity_units);
   IF rec_.quantity IS NOT NULL THEN
      json_.put('quantity', rec_.quantity);
   END IF;
   IF rec_.number_of_pieces IS NOT NULL THEN
      json_.put('numberOfPieces', rec_.number_of_pieces);
   END IF;
   IF rec_.weight.value IS NOT NULL THEN
      json_.put('weight', Weight_To_Json___(rec_.weight));
   END IF;
   IF rec_.customs_value.amount IS NOT NULL THEN
      json_.put('customsValue', Money_To_Json___(rec_.customs_value));
   END IF;
   IF rec_.unit_price.amount IS NOT NULL THEN
      json_.put('unitPrice', Money_To_Json___(rec_.unit_price));
   END IF;
   RETURN json_;
END Commodity_To_Json___;


FUNCTION Label_Spec_To_Json___ (
   rec_ IN Fe_Label_Spec_Rec) RETURN Json_Object_T
IS
   json_  Json_Object_T := Json_Object_T();
BEGIN
   Json_Put___(json_, 'imageType',        rec_.image_type);
   Json_Put___(json_, 'labelStockType',   rec_.label_stock_type);
   Json_Put___(json_, 'labelFormatType',  rec_.label_format_type);
   RETURN json_;
END Label_Spec_To_Json___;


FUNCTION Payor_To_Json___ (
   rec_ IN Fe_Payor_Rec) RETURN Json_Object_T
IS
   json_        Json_Object_T := Json_Object_T();
   payor_json_  Json_Object_T := Json_Object_T();
   party_json_  Json_Object_T := Json_Object_T();
   acct_json_   Json_Object_T := Json_Object_T();
   addr_json_   Json_Object_T := Json_Object_T();
BEGIN
   acct_json_.put('value', rec_.account_number.value);
   addr_json_.put('countryCode', rec_.country_code);
   party_json_.put('accountNumber', acct_json_);
   party_json_.put('address', addr_json_);
   payor_json_.put('responsibleParty', party_json_);
   json_.put('paymentType', rec_.payment_type);
   json_.put('payor', payor_json_);
   RETURN json_;
END Payor_To_Json___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU CUST NEW METHODS ------------------------------------

FUNCTION Get_Shipper_Rec (
   freight_provider_  IN VARCHAR2,
   contract_          IN VARCHAR2) RETURN Fe_Party_Rec
IS
   rec_         Fe_Party_Rec;
   company_     VARCHAR2(20);
   addr_key_    VARCHAR2(2000);
BEGIN
   company_ := Site_API.Get_Company(contract_);
   addr_key_ := Company_Address_API.Get_Default_Address(company_, Address_Type_Code_API.Decode('INVOICE'));

   rec_.address.address_line_1         := Company_Address_API.Get_Address1(company_, addr_key_);
   rec_.address.address_line_2         := Company_Address_API.Get_Address2(company_, addr_key_);
   rec_.address.city                   := Company_Address_API.Get_City(company_, addr_key_);
   rec_.address.state_or_province_code := Company_Address_API.Get_State(company_, addr_key_);
   rec_.address.postal_code            := Company_Address_API.Get_Zip_Code(company_, addr_key_);
   rec_.address.country_code           := Company_Address_API.Get_Country_Code(company_, addr_key_);
   rec_.address.residential            := 'false';
   rec_.contact.company_name           := Company_API.Get_Name(company_);
   rec_.contact.phone_number           := Company_Address_API.Get_Phone(company_, addr_key_);
   rec_.contact.email_address          := Company_Address_API.Get_Email(company_, addr_key_);
   RETURN rec_;
END Get_Shipper_Rec;


FUNCTION Get_Shipment_Recipient_Rec (
   shipment_id_ IN NUMBER) RETURN Fe_Party_Rec
IS
   rec_  Fe_Party_Rec;
   CURSOR get_shipment IS
      SELECT receiver_id, receiver_type_db, receiver_addr_id,
             name, address1, address2, city, state, zip_code, country_code,
             contact, receiver_phone, receiver_email
        FROM shipment
       WHERE shipment_id = shipment_id_;
   ship_  get_shipment%ROWTYPE;
BEGIN
   OPEN  get_shipment;
   FETCH get_shipment INTO ship_;
   CLOSE get_shipment;
   rec_.address.address_line_1         := ship_.address1;
   rec_.address.address_line_2         := ship_.address2;
   rec_.address.city                   := ship_.city;
   rec_.address.state_or_province_code := ship_.state;
   rec_.address.postal_code            := ship_.zip_code;
   rec_.address.country_code           := ship_.country_code;
   rec_.contact.company_name           := ship_.name;
   rec_.contact.person_name            := ship_.contact;
   rec_.contact.phone_number           := ship_.receiver_phone;
   rec_.contact.email_address          := ship_.receiver_email;
   RETURN rec_;
END Get_Shipment_Recipient_Rec;


FUNCTION Get_Order_Recipient_Rec (
   order_no_ IN VARCHAR2) RETURN Fe_Party_Rec
IS
   rec_  Fe_Party_Rec;
   CURSOR get_order_addr IS
      SELECT a.name, a.address1, a.address2, a.city, a.state, a.zip,
             a.country_code, a.ean_location,
             c.phone, c.email
        FROM customer_order_address a,
             customer_info_address c
       WHERE a.order_no     = order_no_
         AND c.customer_id  = Customer_Order_API.Get_Customer_No(order_no_)
         AND c.address_id   = a.addr_no;
   addr_  get_order_addr%ROWTYPE;
BEGIN
   OPEN  get_order_addr;
   FETCH get_order_addr INTO addr_;
   CLOSE get_order_addr;
   rec_.address.address_line_1         := addr_.address1;
   rec_.address.address_line_2         := addr_.address2;
   rec_.address.city                   := addr_.city;
   rec_.address.state_or_province_code := addr_.state;
   rec_.address.postal_code            := addr_.zip;
   rec_.address.country_code           := addr_.country_code;
   rec_.contact.company_name           := addr_.name;
   rec_.contact.phone_number           := addr_.phone;
   rec_.contact.email_address          := addr_.email;
   RETURN rec_;
END Get_Order_Recipient_Rec;


FUNCTION Get_Package_Items_Arr (
   freight_provider_  IN VARCHAR2,
   shipment_id_       IN NUMBER) RETURN Fe_Package_Line_Item_Arr
IS
   items_     Fe_Package_Line_Item_Arr;
   idx_       PLS_INTEGER := 1;
   weight_uom_ VARCHAR2(30);

   CURSOR get_hu IS
      SELECT hu.handling_unit_id,
             hu.net_weight + NVL(hu.tare_weight, 0) AS gross_weight,
             hu.depth,  hu.width,  hu.height,
             hu.manual_gross_weight
        FROM handling_unit_shipment hus
        JOIN handling_unit hu ON hu.handling_unit_id = hus.handling_unit_id
       WHERE hus.shipment_id = shipment_id_
         AND hus.structure_level = 1
       ORDER BY hu.handling_unit_id;
BEGIN
   weight_uom_ := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'WEIGHT_UOM'), 'LB');
   FOR hu_ IN get_hu LOOP
      items_(idx_).sequence_number       := TO_CHAR(idx_);
      items_(idx_).weight.units          := weight_uom_;
      items_(idx_).weight.value          := NVL(hu_.manual_gross_weight,
                                                NVL(hu_.gross_weight, 0));
      items_(idx_).dimensions.length     := ROUND(NVL(hu_.depth, 0));
      items_(idx_).dimensions.width      := ROUND(NVL(hu_.width, 0));
      items_(idx_).dimensions.height     := ROUND(NVL(hu_.height, 0));
      items_(idx_).dimensions.units      := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'DIM_UOM'), 'IN');
      idx_ := idx_ + 1;
   END LOOP;
   RETURN items_;
END Get_Package_Items_Arr;


FUNCTION Get_Order_Package_Items_Arr (
   freight_provider_  IN VARCHAR2,
   order_no_          IN VARCHAR2) RETURN Fe_Package_Line_Item_Arr
IS
   items_      Fe_Package_Line_Item_Arr;
   idx_        PLS_INTEGER := 1;
   weight_uom_ VARCHAR2(30);
   total_wt_   NUMBER := 0;
   line_rec_   Fe_Package_Line_Item_Rec;
   ref_        Fe_Customer_Ref_Rec;
BEGIN
   weight_uom_ := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'WEIGHT_UOM'), 'LB');
   FOR line_ IN (SELECT buy_qty_due * Sales_Part_API.Get_Gross_Weight(contract, catalog_no) AS line_weight,
                        order_no, line_no
                   FROM customer_order_line_tab
                  WHERE order_no = order_no_
                    AND line_item_no = 0
                    AND rowstate NOT IN ('Cancelled')) LOOP
      total_wt_ := total_wt_ + NVL(line_.line_weight, 0);
   END LOOP;
   line_rec_.sequence_number  := '1';
   line_rec_.weight.units     := weight_uom_;
   line_rec_.weight.value     := total_wt_;
   ref_.customer_reference_type := 'CUSTOMER_REFERENCE';
   ref_.value                   := order_no_;
   line_rec_.customer_references(1) := ref_;
   items_(1) := line_rec_;
   RETURN items_;
END Get_Order_Package_Items_Arr;


FUNCTION Get_Customs_Detail_Rec (
   freight_provider_  IN VARCHAR2,
   shipment_id_       IN NUMBER) RETURN Fe_Customs_Detail_Rec
IS
   rec_      Fe_Customs_Detail_Rec;
   idx_      PLS_INTEGER := 1;
   currency_ VARCHAR2(3);

   CURSOR get_lines IS
      SELECT col.catalog_no,
             col.buy_qty_due AS quantity,
             col.sale_unit_price,
             col.currency_code,
             ip.prime_commodity AS harmonized_code,
             ip.country_of_origin AS country_of_manufacture,
             sp.catalog_desc AS description,
             ip.unit_meas,
             col.buy_qty_due * Inventory_Part_API.Get_Weight_Net(col.contract, col.part_no) AS net_weight
        FROM customer_order_line_tab col
        LEFT JOIN inventory_part ip  ON ip.part_no = col.part_no AND ip.contract = col.contract
        LEFT JOIN sales_part sp      ON sp.catalog_no = col.catalog_no AND sp.contract = col.contract
       WHERE col.order_no    = Shipment_API.Get_Source_Ref1(shipment_id_)
         AND col.line_item_no = 0
         AND col.rowstate NOT IN ('Cancelled');
BEGIN
   currency_ := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'CUSTOMS_CURRENCY'), 'USD');

   FOR ln_ IN get_lines LOOP
      rec_.commodities(idx_).description            := SUBSTR(ln_.description, 1, 450);
      rec_.commodities(idx_).harmonized_code        := ln_.harmonized_code;
      rec_.commodities(idx_).country_of_manufacture := NVL(ln_.country_of_manufacture, 'US');
      rec_.commodities(idx_).quantity               := CEIL(ln_.quantity);
      rec_.commodities(idx_).quantity_units         := NVL(ln_.unit_meas, 'EA');
      rec_.commodities(idx_).number_of_pieces       := CEIL(ln_.quantity);
      rec_.commodities(idx_).weight.units           := 'LB';
      rec_.commodities(idx_).weight.value           := NVL(ln_.net_weight, 0);
      rec_.commodities(idx_).customs_value.amount   := NVL(ln_.sale_unit_price * ln_.quantity, 0);
      rec_.commodities(idx_).customs_value.currency := currency_;
      rec_.commodities(idx_).unit_price.amount      := NVL(ln_.sale_unit_price, 0);
      rec_.commodities(idx_).unit_price.currency    := currency_;
      idx_ := idx_ + 1;
   END LOOP;

   rec_.duties_payment_type             := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'DUTIES_PAYMENT_TYPE'), 'RECIPIENT');
   rec_.commercial_invoice.terms_of_sale := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'TERMS_OF_SALE'), 'DDU');
   rec_.commercial_invoice.shipment_purpose := 'SOLD';
   RETURN rec_;
END Get_Customs_Detail_Rec;


FUNCTION Get_Create_Ship_Request_Rec (
   freight_provider_  IN VARCHAR2,
   shipment_id_       IN NUMBER,
   index_             IN VARCHAR2) RETURN Fe_Create_Ship_Request_Rec
IS
   req_       Fe_Create_Ship_Request_Rec;
   contract_  VARCHAR2(5);
   origin_ctry_  VARCHAR2(2);
   dest_ctry_    VARCHAR2(2);
BEGIN
   contract_ := Shipment_API.Get_Contract(shipment_id_);

   req_.account_number.value              := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'ACCOUNT_NUMBER');
   req_.index_                            := index_;
   req_.open_shipment_action              := 'CREATE_PACKAGE';
   req_.requested_shipment.pickup_type    := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PICKUP_TYPE'), 'USE_SCHEDULED_PICKUP');
   req_.requested_shipment.packaging_type := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PACKAGING_TYPE'), 'YOUR_PACKAGING');
   req_.requested_shipment.rate_request_type := 'ACCOUNT';
   req_.requested_shipment.ship_datestamp := TO_CHAR(SYSDATE, 'YYYY-MM-DD');

   req_.requested_shipment.shipper := Get_Shipper_Rec(freight_provider_, contract_);
   req_.requested_shipment.recipients(1) := Get_Shipment_Recipient_Rec(shipment_id_);

   req_.requested_shipment.payor.payment_type        := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PAYMENT_TYPE'), 'SENDER');
   req_.requested_shipment.payor.account_number.value := req_.account_number.value;
   req_.requested_shipment.payor.country_code        := req_.requested_shipment.shipper.address.country_code;

   req_.requested_shipment.requested_package_line_items := Get_Package_Items_Arr(freight_provider_, shipment_id_);

   req_.requested_shipment.label_specification.image_type       := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'LABEL_IMAGE_TYPE'), 'PNG');
   req_.requested_shipment.label_specification.label_stock_type := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'LABEL_STOCK_TYPE'), 'PAPER_4X6');

   origin_ctry_ := req_.requested_shipment.shipper.address.country_code;
   dest_ctry_   := req_.requested_shipment.recipients(1).address.country_code;
   IF origin_ctry_ != dest_ctry_ THEN
      req_.requested_shipment.include_customs        := TRUE;
      req_.requested_shipment.customs_clearance_detail := Get_Customs_Detail_Rec(freight_provider_, shipment_id_);
   ELSE
      req_.requested_shipment.include_customs := FALSE;
   END IF;

   RETURN req_;
END Get_Create_Ship_Request_Rec;


FUNCTION Get_Order_Create_Ship_Request_Rec (
   freight_provider_  IN VARCHAR2,
   order_no_          IN VARCHAR2,
   index_             IN VARCHAR2) RETURN Fe_Create_Ship_Request_Rec
IS
   req_       Fe_Create_Ship_Request_Rec;
   contract_  VARCHAR2(5);
BEGIN
   contract_ := Customer_Order_API.Get_Contract(order_no_);

   req_.account_number.value              := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'ACCOUNT_NUMBER');
   req_.index_                            := index_;
   req_.open_shipment_action              := 'CREATE_PACKAGE';
   req_.requested_shipment.pickup_type    := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PICKUP_TYPE'), 'USE_SCHEDULED_PICKUP');
   req_.requested_shipment.packaging_type := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PACKAGING_TYPE'), 'YOUR_PACKAGING');
   req_.requested_shipment.rate_request_type := 'ACCOUNT';
   req_.requested_shipment.ship_datestamp := TO_CHAR(SYSDATE, 'YYYY-MM-DD');

   req_.requested_shipment.shipper   := Get_Shipper_Rec(freight_provider_, contract_);
   req_.requested_shipment.recipients(1) := Get_Order_Recipient_Rec(order_no_);

   req_.requested_shipment.payor.payment_type        := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PAYMENT_TYPE'), 'SENDER');
   req_.requested_shipment.payor.account_number.value := req_.account_number.value;
   req_.requested_shipment.payor.country_code        := req_.requested_shipment.shipper.address.country_code;

   req_.requested_shipment.requested_package_line_items := Get_Order_Package_Items_Arr(freight_provider_, order_no_);

   req_.requested_shipment.label_specification.image_type       := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'LABEL_IMAGE_TYPE'), 'PNG');
   req_.requested_shipment.label_specification.label_stock_type := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'LABEL_STOCK_TYPE'), 'PAPER_4X6');
   req_.requested_shipment.include_customs := FALSE;
   RETURN req_;
END Get_Order_Create_Ship_Request_Rec;


FUNCTION Get_Rate_Request_Rec (
   freight_provider_  IN VARCHAR2,
   shipment_id_       IN NUMBER) RETURN Fe_Rate_Request_Rec
IS
   req_       Fe_Rate_Request_Rec;
   contract_  VARCHAR2(5);
BEGIN
   contract_ := Shipment_API.Get_Contract(shipment_id_);
   req_.account_number.value                          := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'ACCOUNT_NUMBER');
   req_.requested_shipment.pickup_type                := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PICKUP_TYPE'), 'USE_SCHEDULED_PICKUP');
   req_.requested_shipment.rate_request_type          := 'ACCOUNT';
   req_.requested_shipment.return_transit_times       := 'true';
   req_.requested_shipment.shipper  := Get_Shipper_Rec(freight_provider_, contract_);
   req_.requested_shipment.recipient := Get_Shipment_Recipient_Rec(shipment_id_);
   req_.requested_shipment.requested_package_line_items := Get_Package_Items_Arr(freight_provider_, shipment_id_);
   RETURN req_;
END Get_Rate_Request_Rec;


FUNCTION Get_Order_Rate_Request_Rec (
   freight_provider_  IN VARCHAR2,
   order_no_          IN VARCHAR2) RETURN Fe_Rate_Request_Rec
IS
   req_       Fe_Rate_Request_Rec;
   contract_  VARCHAR2(5);
BEGIN
   contract_ := Customer_Order_API.Get_Contract(order_no_);
   req_.account_number.value                          := Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'ACCOUNT_NUMBER');
   req_.requested_shipment.pickup_type                := NVL(Frt_Provider_Config_Value_API.Get_Config_Value(freight_provider_, 'PICKUP_TYPE'), 'USE_SCHEDULED_PICKUP');
   req_.requested_shipment.rate_request_type          := 'ACCOUNT';
   req_.requested_shipment.return_transit_times       := 'true';
   req_.requested_shipment.shipper   := Get_Shipper_Rec(freight_provider_, contract_);
   req_.requested_shipment.recipient := Get_Order_Recipient_Rec(order_no_);
   req_.requested_shipment.requested_package_line_items := Get_Order_Package_Items_Arr(freight_provider_, order_no_);
   RETURN req_;
END Get_Order_Rate_Request_Rec;


FUNCTION Create_Ship_Req_To_Json (
   rec_ IN Fe_Create_Ship_Request_Rec) RETURN Json_Object_T
IS
   root_json_     Json_Object_T := Json_Object_T();
   acct_json_     Json_Object_T := Json_Object_T();
   req_ship_json_ Json_Object_T := Json_Object_T();
   recipients_arr_ Json_Array_T := Json_Array_T();
   pkgs_arr_      Json_Array_T  := Json_Array_T();
   customs_json_  Json_Object_T;
   comm_inv_json_ Json_Object_T;
   comms_arr_     Json_Array_T;
   payment_json_  Json_Object_T;
   duties_json_   Json_Object_T;
   total_cv_json_ Json_Object_T;
   i_             PLS_INTEGER;
BEGIN
   acct_json_.put('value', rec_.account_number.value);
   root_json_.put('accountNumber', acct_json_);
   root_json_.put('index', rec_.index_);
   root_json_.put('openShipmentAction', rec_.open_shipment_action);

   req_ship_json_.put('pickupType',    rec_.requested_shipment.pickup_type);
   req_ship_json_.put('packagingType', rec_.requested_shipment.packaging_type);
   Json_Put___(req_ship_json_, 'shipDatestamp',    rec_.requested_shipment.ship_datestamp);
   Json_Put___(req_ship_json_, 'serviceType',      rec_.requested_shipment.service_type);
   Json_Put___(req_ship_json_, 'rateRequestType',  rec_.requested_shipment.rate_request_type);

   req_ship_json_.put('shipper', Party_To_Json___(rec_.requested_shipment.shipper));

   IF rec_.requested_shipment.recipients.COUNT > 0 THEN
      FOR i_ IN rec_.requested_shipment.recipients.FIRST..rec_.requested_shipment.recipients.LAST LOOP
         recipients_arr_.append(Party_To_Json___(rec_.requested_shipment.recipients(i_)));
      END LOOP;
   END IF;
   req_ship_json_.put('recipients', recipients_arr_);

   req_ship_json_.put('shippingChargesPayment', Payor_To_Json___(rec_.requested_shipment.payor));

   IF rec_.requested_shipment.requested_package_line_items.COUNT > 0 THEN
      i_ := rec_.requested_shipment.requested_package_line_items.FIRST;
      WHILE i_ IS NOT NULL LOOP
         pkgs_arr_.append(Package_Item_To_Json___(rec_.requested_shipment.requested_package_line_items(i_), i_));
         i_ := rec_.requested_shipment.requested_package_line_items.NEXT(i_);
      END LOOP;
   END IF;
   req_ship_json_.put('requestedPackageLineItems', pkgs_arr_);
   req_ship_json_.put('labelSpecification', Label_Spec_To_Json___(rec_.requested_shipment.label_specification));

   IF rec_.requested_shipment.include_customs THEN
      customs_json_ := Json_Object_T();
      comms_arr_    := Json_Array_T();
      IF rec_.requested_shipment.customs_clearance_detail.commodities.COUNT > 0 THEN
         i_ := rec_.requested_shipment.customs_clearance_detail.commodities.FIRST;
         WHILE i_ IS NOT NULL LOOP
            comms_arr_.append(Commodity_To_Json___(rec_.requested_shipment.customs_clearance_detail.commodities(i_)));
            i_ := rec_.requested_shipment.customs_clearance_detail.commodities.NEXT(i_);
         END LOOP;
      END IF;
      customs_json_.put('commodities', comms_arr_);
      duties_json_ := Json_Object_T();
      duties_json_.put('paymentType', rec_.requested_shipment.customs_clearance_detail.duties_payment_type);
      customs_json_.put('dutiesPayment', duties_json_);
      IF rec_.requested_shipment.customs_clearance_detail.total_customs_value.amount IS NOT NULL THEN
         customs_json_.put('totalCustomsValue', Money_To_Json___(rec_.requested_shipment.customs_clearance_detail.total_customs_value));
      END IF;
      comm_inv_json_ := Json_Object_T();
      Json_Put___(comm_inv_json_, 'termsOfSale',      rec_.requested_shipment.customs_clearance_detail.commercial_invoice.terms_of_sale);
      Json_Put___(comm_inv_json_, 'shipmentPurpose',  rec_.requested_shipment.customs_clearance_detail.commercial_invoice.shipment_purpose);
      customs_json_.put('commercialInvoice', comm_inv_json_);
      req_ship_json_.put('customsClearanceDetail', customs_json_);
   END IF;

   root_json_.put('requestedShipment', req_ship_json_);
   RETURN root_json_;
END Create_Ship_Req_To_Json;


FUNCTION Rate_Request_To_Json (
   rec_ IN Fe_Rate_Request_Rec) RETURN Json_Object_T
IS
   root_json_     Json_Object_T := Json_Object_T();
   acct_json_     Json_Object_T := Json_Object_T();
   req_ship_json_ Json_Object_T := Json_Object_T();
   shipper_json_  Json_Object_T := Json_Object_T();
   recip_json_    Json_Object_T := Json_Object_T();
   ship_addr_     Json_Object_T;
   recip_addr_    Json_Object_T;
   pkgs_arr_      Json_Array_T  := Json_Array_T();
   ctrl_json_     Json_Object_T := Json_Object_T();
   i_             PLS_INTEGER;
BEGIN
   acct_json_.put('value', rec_.account_number.value);
   root_json_.put('accountNumber', acct_json_);

   ctrl_json_.put('returnTransitTimes', (rec_.requested_shipment.return_transit_times = 'true'));
   ctrl_json_.put('servicesNeededOnRateFailure', FALSE);
   ctrl_json_.put('rateSortOrder', 'SERVICENAMETRADITIONAL');
   ctrl_json_.put('totalPackageCount', rec_.requested_shipment.requested_package_line_items.COUNT);
   root_json_.put('rateRequestControlParameters', ctrl_json_);

   ship_addr_ := Json_Object_T();
   ship_addr_.put('postalCode',   rec_.requested_shipment.shipper.address.postal_code);
   ship_addr_.put('countryCode',  rec_.requested_shipment.shipper.address.country_code);
   Json_Put___(ship_addr_, 'stateOrProvinceCode', rec_.requested_shipment.shipper.address.state_or_province_code);
   shipper_json_.put('address', ship_addr_);
   req_ship_json_.put('shipper', shipper_json_);

   recip_addr_ := Json_Object_T();
   recip_addr_.put('postalCode',  rec_.requested_shipment.recipient.address.postal_code);
   recip_addr_.put('countryCode', rec_.requested_shipment.recipient.address.country_code);
   Json_Put___(recip_addr_, 'stateOrProvinceCode', rec_.requested_shipment.recipient.address.state_or_province_code);
   recip_json_.put('address', recip_addr_);
   req_ship_json_.put('recipient', recip_json_);

   req_ship_json_.put('pickupType', rec_.requested_shipment.pickup_type);
   IF rec_.requested_shipment.service_type IS NOT NULL THEN
      req_ship_json_.put('serviceType', rec_.requested_shipment.service_type);
   END IF;
   req_ship_json_.put('rateRequestType', Json_Array_T());
   DECLARE
      arr_ Json_Array_T := Json_Array_T();
   BEGIN
      arr_.append(rec_.requested_shipment.rate_request_type);
      req_ship_json_.put('rateRequestType', arr_);
   END;

   IF rec_.requested_shipment.requested_package_line_items.COUNT > 0 THEN
      i_ := rec_.requested_shipment.requested_package_line_items.FIRST;
      WHILE i_ IS NOT NULL LOOP
         pkgs_arr_.append(Package_Item_To_Json___(rec_.requested_shipment.requested_package_line_items(i_), i_));
         i_ := rec_.requested_shipment.requested_package_line_items.NEXT(i_);
      END LOOP;
   END IF;
   req_ship_json_.put('requestedPackageLineItems', pkgs_arr_);
   root_json_.put('requestedShipment', req_ship_json_);
   RETURN root_json_;
END Rate_Request_To_Json;


FUNCTION Confirm_Req_To_Json (
   rec_ IN Fe_Confirm_Request_Rec) RETURN Json_Object_T
IS
   root_json_  Json_Object_T := Json_Object_T();
   acct_json_  Json_Object_T := Json_Object_T();
BEGIN
   acct_json_.put('value', rec_.account_number.value);
   root_json_.put('accountNumber', acct_json_);
   root_json_.put('index', rec_.index_);
   root_json_.put('labelResponseOptions', NVL(rec_.label_response_options, 'LABEL'));
   root_json_.put('labelSpecification', Label_Spec_To_Json___(rec_.label_specification));
   RETURN root_json_;
END Confirm_Req_To_Json;


FUNCTION Delete_Req_To_Json (
   rec_ IN Fe_Delete_Request_Rec) RETURN Json_Object_T
IS
   root_json_  Json_Object_T := Json_Object_T();
   acct_json_  Json_Object_T := Json_Object_T();
BEGIN
   acct_json_.put('value', rec_.account_number.value);
   root_json_.put('accountNumber', acct_json_);
   root_json_.put('index', rec_.index_);
   RETURN root_json_;
END Delete_Req_To_Json;


FUNCTION Json_To_Rate_Arr (
   json_ IN Json_Object_T) RETURN Fe_Rate_Arr
IS
   rates_        Fe_Rate_Arr;
   output_       Json_Object_T;
   details_arr_  Json_Array_T;
   detail_obj_   Json_Object_T;
   rated_arr_    Json_Array_T;
   rated_obj_    Json_Object_T;
   ship_rate_obj_ Json_Object_T;
   surcharges_   Json_Array_T;
   surcharge_obj_ Json_Object_T;
   commit_obj_   Json_Object_T;
   transit_obj_  Json_Object_T;
   idx_          PLS_INTEGER := 1;
   base_charge_  NUMBER := 0;
   net_charge_   NUMBER := 0;
   fuel_pct_     NUMBER := 0;
   transit_days_ VARCHAR2(30);
BEGIN
   output_ := TREAT(json_.get('output') AS Json_Object_T);
   IF output_ IS NULL THEN RETURN rates_; END IF;
   details_arr_ := TREAT(output_.get('rateReplyDetails') AS Json_Array_T);
   IF details_arr_ IS NULL THEN RETURN rates_; END IF;

   FOR i_ IN 0..details_arr_.get_size - 1 LOOP
      detail_obj_ := TREAT(details_arr_.get(i_) AS Json_Object_T);
      IF detail_obj_ IS NULL THEN CONTINUE; END IF;

      rated_arr_  := TREAT(detail_obj_.get('ratedShipmentDetails') AS Json_Array_T);
      IF rated_arr_ IS NULL OR rated_arr_.get_size = 0 THEN CONTINUE; END IF;

      rated_obj_ := TREAT(rated_arr_.get(0) AS Json_Object_T);
      IF rated_obj_ IS NULL THEN CONTINUE; END IF;

      base_charge_ := NVL(rated_obj_.get_number('totalBaseCharge'), 0);
      net_charge_  := NVL(rated_obj_.get_number('totalNetCharge'), 0);

      ship_rate_obj_ := TREAT(rated_obj_.get('shipmentRateDetail') AS Json_Object_T);
      IF ship_rate_obj_ IS NOT NULL THEN
         fuel_pct_ := NVL(ship_rate_obj_.get_number('fuelSurchargePercent'), 0);
      ELSE
         fuel_pct_ := 0;
      END IF;

      commit_obj_   := TREAT(detail_obj_.get('commit') AS Json_Object_T);
      transit_days_ := NULL;
      IF commit_obj_ IS NOT NULL THEN
         transit_obj_ := TREAT(commit_obj_.get('transitDays') AS Json_Object_T);
         IF transit_obj_ IS NOT NULL THEN
            transit_days_ := transit_obj_.get_string('description');
         END IF;
         IF transit_days_ IS NULL THEN
            transit_days_ := commit_obj_.get_string('daysInTransit');
         END IF;
      END IF;

      rates_(idx_).service_type           := detail_obj_.get_string('serviceType');
      rates_(idx_).service_name           := detail_obj_.get_string('serviceName');
      rates_(idx_).currency               := rated_obj_.get_string('currency');
      rates_(idx_).total_net_charge       := net_charge_;
      rates_(idx_).total_base_charge      := base_charge_;
      rates_(idx_).fuel_surcharge_percent := fuel_pct_;
      rates_(idx_).transit_days           := transit_days_;
      idx_ := idx_ + 1;
   END LOOP;
   RETURN rates_;
END Json_To_Rate_Arr;


FUNCTION Json_To_Confirm_Rec (
   json_ IN Json_Object_T) RETURN Fe_Shipment_Confirm_Rec
IS
   rec_            Fe_Shipment_Confirm_Rec;
   output_         Json_Object_T;
   shipments_arr_  Json_Array_T;
   shipment_obj_   Json_Object_T;
   pieces_arr_     Json_Array_T;
   piece_obj_      Json_Object_T;
   docs_arr_       Json_Array_T;
   doc_obj_        Json_Object_T;
BEGIN
   output_ := TREAT(json_.get('output') AS Json_Object_T);
   IF output_ IS NULL THEN RETURN rec_; END IF;

   shipments_arr_ := TREAT(output_.get('transactionShipments') AS Json_Array_T);
   IF shipments_arr_ IS NULL OR shipments_arr_.get_size = 0 THEN RETURN rec_; END IF;

   shipment_obj_ := TREAT(shipments_arr_.get(0) AS Json_Object_T);
   IF shipment_obj_ IS NULL THEN RETURN rec_; END IF;

   rec_.master_tracking_number := shipment_obj_.get_string('masterTrackingNumber');
   rec_.service_type           := shipment_obj_.get_string('serviceType');
   rec_.service_name           := shipment_obj_.get_string('serviceName');
   rec_.pickup_date            := SUBSTR(shipment_obj_.get_string('shipDatestamp'), 1, 10);

   pieces_arr_ := TREAT(shipment_obj_.get('pieceResponses') AS Json_Array_T);
   IF pieces_arr_ IS NOT NULL AND pieces_arr_.get_size > 0 THEN
      piece_obj_ := TREAT(pieces_arr_.get(0) AS Json_Object_T);
      IF piece_obj_ IS NOT NULL THEN
         rec_.tracking_number    := piece_obj_.get_string('trackingNumber');
         rec_.net_charge_amount  := NVL(piece_obj_.get_number('netChargeAmount'), 0);
         rec_.delivery_timestamp := piece_obj_.get_string('deliveryTimestamp');
         rec_.currency           := piece_obj_.get_string('currency');

         docs_arr_ := TREAT(piece_obj_.get('packageDocuments') AS Json_Array_T);
         IF docs_arr_ IS NOT NULL AND docs_arr_.get_size > 0 THEN
            doc_obj_ := TREAT(docs_arr_.get(0) AS Json_Object_T);
            IF doc_obj_ IS NOT NULL THEN
               rec_.encoded_label := doc_obj_.get_clob('encodedLabel');
            END IF;
         END IF;
      END IF;
   END IF;
   RETURN rec_;
END Json_To_Confirm_Rec;


FUNCTION Json_To_Sr_Rate_Arr (
   fe_arr_ IN Fe_Rate_Arr) RETURN Sr_Shipment_Rate_Arr
IS
   sr_arr_  Sr_Shipment_Rate_Arr;
   i_       PLS_INTEGER;
BEGIN
   IF fe_arr_.COUNT = 0 THEN RETURN sr_arr_; END IF;
   i_ := fe_arr_.FIRST;
   WHILE i_ IS NOT NULL LOOP
      sr_arr_(i_).carrier_service_code             := fe_arr_(i_).service_type;
      sr_arr_(i_).carrier_service_code_description := fe_arr_(i_).service_name;
      sr_arr_(i_).consignor_freight                := fe_arr_(i_).total_net_charge;
      sr_arr_(i_).list_freight                     := fe_arr_(i_).total_base_charge;
      sr_arr_(i_).fuel_surcharge                   := (fe_arr_(i_).total_base_charge * fe_arr_(i_).fuel_surcharge_percent / 100);
      sr_arr_(i_).currency_code                    := fe_arr_(i_).currency;
      sr_arr_(i_).status_message                   := fe_arr_(i_).transit_days;
      i_ := fe_arr_.NEXT(i_);
   END LOOP;
   RETURN sr_arr_;
END Json_To_Sr_Rate_Arr;
