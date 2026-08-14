CREATE OR REPLACE PACKAGE C_Swift_Payment_API IS

module_                   CONSTANT VARCHAR2(6)      := 'INVOIC';
lu_name_                  CONSTANT VARCHAR2(30)     := 'CSwiftPayment';
lu_type_                  CONSTANT VARCHAR2(30)     := 'Entity';
entity_projection_name_   CONSTANT VARCHAR2(40)     := 'CSwiftPaymentEntity';

-----------------------------------------------------------------------------
-------------------- PUBLIC DECLARATIONS ------------------------------------
-----------------------------------------------------------------------------

TYPE Public_Rec IS RECORD
  (id                             C_SWIFT_PAYMENT_TAB.id%TYPE,
   "rowid"                        rowid,
   rowversion                     C_SWIFT_PAYMENT_TAB.rowversion%TYPE,
   rowkey                         C_SWIFT_PAYMENT_TAB.rowkey%TYPE,
   msg_id                         C_SWIFT_PAYMENT_TAB.msg_id%TYPE,
   payment_msg                    C_SWIFT_PAYMENT_TAB.payment_msg%TYPE,
   response_msg                   C_SWIFT_PAYMENT_TAB.response_msg%TYPE);

-----------------------------------------------------------------------------
-------------------- BASE METHODS -------------------------------------------
-----------------------------------------------------------------------------
-- Get_Key_By_Rowkey
--   Returns a table record with only keys (other attributes are NULL) based on a rowkey.
--
-- Exist
--   Checks if given pointer (e.g. primary key) to an instance of this
--   logical unit exists. If not an exception will be raised.
--
-- Exists
--   Same check as Exist, but returns a BOOLEAN value instead of exception.
--
-- Rowkey_Exist
--   Checks whether the rowkey exists
--   If not an exception will be raised.
--
-- Get_Msg_Id
--   Fetches the MsgId attribute for a record.
--
-- Get_Payment_Msg
--   Fetches the PaymentMsg attribute for a record.
--
-- Get_Response_Msg
--   Fetches the ResponseMsg attribute for a record.
--
-- Get_By_Rowkey
--   Fetches a record containing the public attributes by rowkey inparameter.
--
-- Get
--   Fetches a record containing the public attributes.
--
-- Get_Objkey
--   Fetches the objkey attribute for a record.
--
-- Write_Payment_Msg__
--   Write CLOB column PaymentMsg to database.
--
-- Write_Response_Msg__
--   Write CLOB column ResponseMsg to database.
--
-- Lock__
--   Client-support to lock a specific instance of the logical unit.
--
-- New__
--   Client-support interface to create LU instances.
--   action_ = 'PREPARE'
--   Default values and handle of information to client.
--   The default values are set in procedure Prepare_Insert___.
--   action_ = 'CHECK'
--   Check all attributes before creating new object and handle of
--   information to client. The attribute list is unpacked, checked
--   and prepared (defaults) in procedures Unpack___ and Check_Insert___.
--   action_ = 'DO'
--   Creation of new instances of the logical unit and handle of
--   information to client. The attribute list is unpacked, checked
--   and prepared (defaults) in procedures Unpack___ and Check_Insert___
--   before calling procedure Insert___.
--
-- Modify__
--   Client-support interface to modify attributes for LU instances.
--   action_ = 'CHECK'
--   Check all attributes before modifying an existing object and
--   handle of information to client. The attribute list is unpacked,
--   checked and prepared(defaults) in procedures Unpack___ and Check_Update___.
--   action_ = 'DO'
--   Modification of an existing instance of the logical unit. The
--   procedure unpacks the attributes, checks all values before
--   procedure Update___ is called.
--
-- Remove__
--   Client-support interface to remove LU instances.
--   action_ = 'CHECK'
--   Check whether a specific LU-instance may be removed or not.
--   The procedure fetches the complete record by calling procedure
--   Get_Object_By_Id___. Then the check is made by calling procedure
-----------------------------------------------------------------------------

--@PoReadOnly(Get_Key_By_Rowkey)
FUNCTION Get_Key_By_Rowkey (
   rowkey_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE;

--@PoReadOnly(Exist)
PROCEDURE Exist (
   id_ IN NUMBER );

--@PoReadOnly(Exists)
FUNCTION Exists (
   id_ IN NUMBER ) RETURN BOOLEAN;

--@PoReadOnly(Rowkey_Exist)
PROCEDURE Rowkey_Exist (
   rowkey_ IN VARCHAR2 );

--@PoReadOnly(Get_Msg_Id)
FUNCTION Get_Msg_Id (
   id_ IN NUMBER ) RETURN VARCHAR2;

--@PoReadOnly(Get_Payment_Msg)
FUNCTION Get_Payment_Msg (
   id_ IN NUMBER ) RETURN CLOB;

--@PoReadOnly(Get_Response_Msg)
FUNCTION Get_Response_Msg (
   id_ IN NUMBER ) RETURN CLOB;

--@PoReadOnly(Get_By_Rowkey)
FUNCTION Get_By_Rowkey (
   rowkey_ IN VARCHAR2 ) RETURN Public_Rec;

--@PoReadOnly(Get)
FUNCTION Get (
   id_ IN NUMBER ) RETURN Public_Rec;

--@PoReadOnly(Get_Objkey)
FUNCTION Get_Objkey (
   id_ IN NUMBER ) RETURN VARCHAR2;

PROCEDURE Write_Payment_Msg__ (
   objversion_ IN OUT NOCOPY VARCHAR2,
   rowid_      IN     ROWID,
   lob_loc_    IN     CLOB );

PROCEDURE Write_Response_Msg__ (
   objversion_ IN OUT NOCOPY VARCHAR2,
   rowid_      IN     ROWID,
   lob_loc_    IN     CLOB );

--@PoReadOnly(Lock__)
PROCEDURE Lock__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2 );

PROCEDURE New__ (
   info_       OUT    VARCHAR2,
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   attr_       IN OUT NOCOPY VARCHAR2,
   action_     IN     VARCHAR2 );

PROCEDURE Modify__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   attr_       IN OUT NOCOPY VARCHAR2,
   action_     IN     VARCHAR2 );

PROCEDURE Remove__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2,
   action_     IN  VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- LU CUST NEW METHODS ------------------------------------
-----------------------------------------------------------------------------
-- Store_Msg
--
-- Call_Swift_Api
--
-- Store_Response_Msg
--
-- Store_Transformed_Msg
-----------------------------------------------------------------------------

FUNCTION Store_Msg(
   in_payment_msg_ IN CLOB)
   RETURN VARCHAR2;

PROCEDURE Call_Swift_Api(
   msg_ IN CLOB, 
   app_msg_id_  IN VARCHAR2 , 
   fnd_user_    IN VARCHAR2 , 
   key_ref_     IN VARCHAR2
   );

PROCEDURE Store_Response_Msg(
   msg_ IN CLOB, 
   app_msg_id_  IN VARCHAR2 , 
   fnd_user_    IN VARCHAR2 , 
   key_ref_     IN VARCHAR2);

FUNCTION Store_Transformed_Msg(
   msg_ IN CLOB)
   RETURN VARCHAR2;

-----------------------------------------------------------------------------
-------------------- FOUNDATION1 METHODS ------------------------------------
-----------------------------------------------------------------------------
-- Init
--   Framework method that initializes this package.
-----------------------------------------------------------------------------

--@PoReadOnly(Init)
PROCEDURE Init;


-----------------------------------------------------------------------------
---------------------------- PUBLIC DECLARATIONS ----------------------------
-----------------------------------------------------------------------------

TYPE Entity_Dec IS RECORD (
   etag                           VARCHAR2(4000),
   info                           VARCHAR2(4000),
   attr                           VARCHAR2(32000));

TYPE Entity_Small_Dec IS RECORD (
   etag                           VARCHAR2(4000),
   info                           VARCHAR2(4000),
   attr                           VARCHAR2(4000));

TYPE Entity_Small_Drr      IS TABLE OF Entity_Small_Dec;

TYPE Entity_Drr      IS TABLE OF Entity_Dec;

TYPE DES_Objid_Arr   IS TABLE OF VARCHAR2(100);

TYPE Empty_Art       IS TABLE OF VARCHAR2(1);

TYPE Boolean_Arr     IS TABLE OF BOOLEAN;

TYPE Boolean_Art     IS TABLE OF VARCHAR2(5);

TYPE Number_Arr      IS TABLE OF NUMBER;

TYPE Text_Arr        IS TABLE OF VARCHAR2(4000);

TYPE Stream_Data_Rec IS RECORD (
   file_name                           VARCHAR2(100),
   mime_type                           VARCHAR2(100),
   stream_data                         BLOB);

TYPE Stream_Data_Arr IS TABLE OF Stream_Data_Rec;

TYPE Stream_Info_Rec IS RECORD (
   file_name                           VARCHAR2(100),
   mime_type                           VARCHAR2(100));

TYPE Stream_Text_Data_Rec IS RECORD (
   file_name                           VARCHAR2(100),
   mime_type                           VARCHAR2(100),
   stream_data                         CLOB);


-----------------------------------------------------------------------------
--------------------- METHODS FOR C SWIFT PAYMENT ENTITY --------------------
-----------------------------------------------------------------------------
--These methods should only use with data entities

--@DataEntityServiceMethod
--@PoReadOnly(CRUD_Default)
FUNCTION CRUD_Default__(attr_ IN VARCHAR2 DEFAULT NULL, c_swift_payment## IN VARCHAR2) RETURN Entity_Small_Drr PIPELINED;

--@DataEntityServiceMethod
--@PoReadOnly(CRUD_Create)
FUNCTION CRUD_Create__(attr_ IN VARCHAR2, action_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec;

--@DataEntityServiceMethod
--@PoReadOnly(CRUD_Update)
FUNCTION CRUD_Update__(etag_ IN VARCHAR2, id_ IN NUMBER, attr_ IN VARCHAR2, action$_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec;

FUNCTION CRUD_Upload__(etag_ IN VARCHAR2, id_ IN NUMBER, payment_msg## IN CLOB, c_swift_payment## IN VARCHAR2) RETURN VARCHAR2;

FUNCTION CRUD_Upload__(etag_ IN VARCHAR2, id_ IN NUMBER, response_msg## IN CLOB, c_swift_payment## IN VARCHAR2) RETURN VARCHAR2;

--@DataEntityServiceMethod
--@PoReadOnly(CRUD_Delete)
FUNCTION CRUD_Delete__(etag_ IN VARCHAR2, id_ IN NUMBER, action$_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec;

END C_Swift_Payment_API;
/
CREATE OR REPLACE PACKAGE BODY C_Swift_Payment_API IS

-----------------------------------------------------------------------------
---------------------------- PRIVATE DECLARATIONS ---------------------------
-----------------------------------------------------------------------------

TYPE C_Swift_Payment_Entity_Rec IS RECORD (
   objid                          VARCHAR2(4000),
   objversion                     VARCHAR2(4000),
   objinfo                        VARCHAR2(4000),
   objgrants                      VARCHAR2(2000),
   id                             NUMBER,
   msg_id                         VARCHAR2(500),
   payment_msg                    CLOB,
   response_msg                   CLOB);

TYPE C_Swift_Payment_Entity_Default_Copy_Rec IS RECORD (
   objgrants                      VARCHAR2(2000),
   id                             NUMBER,
   msg_id                         VARCHAR2(500),
   payment_msg                    CLOB,
   response_msg                   CLOB);

TYPE C_Swift_Payment_Entity_Key IS RECORD (
   id                             NUMBER);


-----------------------------------------------------------------------------
-------------------- PRIVATE DECLARATIONS -----------------------------------
-----------------------------------------------------------------------------

TYPE Indicator_Rec IS RECORD
  (id                             BOOLEAN := FALSE,
   msg_id                         BOOLEAN := FALSE);


-----------------------------------------------------------------------------
-------------------- IMPLEMENTATION METHOD DECLARATIONS ---------------------
-----------------------------------------------------------------------------

FUNCTION Key_Message___ (
   id_ IN NUMBER ) RETURN VARCHAR2;

FUNCTION Formatted_Key___ (
   id_ IN NUMBER ) RETURN VARCHAR2;

PROCEDURE Raise_Too_Many_Rows___ (
   id_ IN NUMBER,
   methodname_ IN VARCHAR2 );

PROCEDURE Raise_Record_Not_Exist___ (
   id_ IN NUMBER );

PROCEDURE Raise_Record_Exist___ (
   rec_ IN c_swift_payment_tab%ROWTYPE );

PROCEDURE Raise_Constraint_Violated___ (
   rec_ IN c_swift_payment_tab%ROWTYPE,
   constraint_ IN VARCHAR2 );

PROCEDURE Raise_Item_Format___ (
   name_ IN VARCHAR2,
   value_ IN VARCHAR2 );

PROCEDURE Raise_Record_Modified___ (
   rec_ IN c_swift_payment_tab%ROWTYPE );

PROCEDURE Raise_Record_Locked___ (
   id_ IN NUMBER );

PROCEDURE Raise_Record_Removed___ (
   id_ IN NUMBER );

FUNCTION Lock_By_Id___ (
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Lock_By_Keys___ (
   id_ IN NUMBER) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Lock_By_Keys_Nowait___ (
   id_ IN NUMBER) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Get_Object_By_Id___ (
   objid_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Get_Object_By_Keys___ (
   id_ IN NUMBER ) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Check_Exist___ (
   id_ IN NUMBER ) RETURN BOOLEAN;

PROCEDURE Get_Version_By_Id___ (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2 );

PROCEDURE Get_Id_Version_By_Keys___ (
   objid_      IN OUT NOCOPY VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   id_ IN NUMBER );

PROCEDURE Unpack___ (
   newrec_   IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_   IN OUT NOCOPY Indicator_Rec,
   attr_     IN OUT NOCOPY VARCHAR2 );

FUNCTION Pack___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN VARCHAR2;

FUNCTION Pack___ (
   rec_ IN c_swift_payment_tab%ROWTYPE,
   indrec_ IN Indicator_Rec ) RETURN VARCHAR2;

FUNCTION Pack_Table___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN VARCHAR2;

FUNCTION Public_To_Table___ (
   public_ IN Public_Rec ) RETURN c_swift_payment_tab%ROWTYPE;

FUNCTION Table_To_Public___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Public_Rec;

PROCEDURE Reset_Indicator_Rec___ (
   indrec_ IN OUT NOCOPY Indicator_Rec );

FUNCTION Get_Indicator_Rec___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Indicator_Rec;

FUNCTION Get_Indicator_Rec___ (
   oldrec_ IN c_swift_payment_tab%ROWTYPE,
   newrec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Indicator_Rec;

PROCEDURE Check_Common___ (
   oldrec_ IN     c_swift_payment_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 );

PROCEDURE Prepare_Insert___ (
   attr_ IN OUT NOCOPY VARCHAR2 );

PROCEDURE Check_Insert___ (
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 );

PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   attr_       IN OUT NOCOPY VARCHAR2 );

PROCEDURE Prepare_New___ (
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE );

PROCEDURE New___ (
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE );

PROCEDURE Check_Update___ (
   oldrec_ IN     c_swift_payment_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 );

PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     c_swift_payment_tab%ROWTYPE,
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   attr_       IN OUT NOCOPY VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE );

PROCEDURE Modify___ (
   newrec_         IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE );

PROCEDURE Check_Delete___ (
   remrec_ IN c_swift_payment_tab%ROWTYPE );

PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN c_swift_payment_tab%ROWTYPE );

PROCEDURE Delete___ (
   remrec_ IN c_swift_payment_tab%ROWTYPE );

PROCEDURE Remove___ (
   remrec_         IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE );

-----------------------------------------------------------------------------
-------------------- BASE METHODS -------------------------------------------
-----------------------------------------------------------------------------

--@IgnoreMissingSysinit
FUNCTION Get_Key_By_Rowkey (
   rowkey_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE
IS
   rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (rowkey_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT id
      INTO  rec_.id
      FROM  c_swift_payment_tab
      WHERE rowkey = rowkey_;
   RETURN rec_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN rec_;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(rec_.id, 'Get_Key_By_Rowkey');
END Get_Key_By_Rowkey;


--@IgnoreMissingSysinit
PROCEDURE Exist (
   id_ IN NUMBER )
IS
BEGIN
   IF (NOT Check_Exist___(id_)) THEN
      Raise_Record_Not_Exist___(id_);
   END IF;
END Exist;


--@IgnoreMissingSysinit
FUNCTION Exists (
   id_ IN NUMBER ) RETURN BOOLEAN
IS
BEGIN
   RETURN Check_Exist___(id_);
END Exists;


--@IgnoreMissingSysinit
PROCEDURE Rowkey_Exist (
   rowkey_ IN VARCHAR2 )
IS
   id_ c_swift_payment_tab.id%TYPE;
BEGIN
   IF (rowkey_ IS NULL) THEN
      RAISE no_data_found;
   END IF;
   SELECT id
   INTO  id_
   FROM  c_swift_payment_tab
   WHERE rowkey = rowkey_;
EXCEPTION
   WHEN no_data_found THEN
      Raise_Record_Not_Exist___(id_);
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Rowkey_Exist___');
END Rowkey_Exist;


--@IgnoreMissingSysinit
FUNCTION Get_Msg_Id (
   id_ IN NUMBER ) RETURN VARCHAR2
IS
   temp_ c_swift_payment_tab.msg_id%TYPE;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT msg_id
      INTO  temp_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN temp_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Msg_Id');
END Get_Msg_Id;


--@IgnoreMissingSysinit
FUNCTION Get_Payment_Msg (
   id_ IN NUMBER ) RETURN CLOB
IS
   temp_ c_swift_payment_tab.payment_msg%TYPE;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT payment_msg
      INTO  temp_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN temp_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Payment_Msg');
END Get_Payment_Msg;


--@IgnoreMissingSysinit
FUNCTION Get_Response_Msg (
   id_ IN NUMBER ) RETURN CLOB
IS
   temp_ c_swift_payment_tab.response_msg%TYPE;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT response_msg
      INTO  temp_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN temp_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Response_Msg');
END Get_Response_Msg;


--@IgnoreMissingSysinit
FUNCTION Get_By_Rowkey (
   rowkey_ IN VARCHAR2 ) RETURN Public_Rec
IS
   rowrec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   rowrec_ := Get_Key_By_Rowkey(rowkey_);
   RETURN Get(rowrec_.id);
END Get_By_Rowkey;


--@IgnoreMissingSysinit
FUNCTION Get (
   id_ IN NUMBER ) RETURN Public_Rec
IS
   temp_ Public_Rec;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT id, rowid, rowversion, rowkey,
          msg_id, 
          payment_msg, 
          response_msg
      INTO  temp_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN temp_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get');
END Get;


--@IgnoreMissingSysinit
FUNCTION Get_Objkey (
   id_ IN NUMBER ) RETURN VARCHAR2
IS
   rowkey_ c_swift_payment_tab.rowkey%TYPE;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN NULL;
   END IF;
   SELECT rowkey
      INTO  rowkey_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN rowkey_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Objkey');
END Get_Objkey;


PROCEDURE Write_Payment_Msg__ (
   objversion_ IN OUT NOCOPY VARCHAR2,
   rowid_      IN     ROWID,
   lob_loc_    IN     CLOB )
IS
   rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Write_Payment_Msg__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Write_Payment_Msg__ (Base)', 'objversion_', objversion_, 'rowid_', '(ROWID)', 'lob_loc_', '(CLOB)');
   END IF;
   rec_ := Lock_By_Id___(rowid_, objversion_);
   UPDATE c_swift_payment_tab
   SET payment_msg = lob_loc_,
       rowversion = sysdate
   WHERE rowid = rowid_
   RETURNING rowversion INTO rec_.rowversion;
   objversion_ := to_char(rec_.rowversion,'YYYYMMDDHH24MISS');
END Write_Payment_Msg__;


PROCEDURE Write_Response_Msg__ (
   objversion_ IN OUT NOCOPY VARCHAR2,
   rowid_      IN     ROWID,
   lob_loc_    IN     CLOB )
IS
   rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Write_Response_Msg__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Write_Response_Msg__ (Base)', 'objversion_', objversion_, 'rowid_', '(ROWID)', 'lob_loc_', '(CLOB)');
   END IF;
   rec_ := Lock_By_Id___(rowid_, objversion_);
   UPDATE c_swift_payment_tab
   SET response_msg = lob_loc_,
       rowversion = sysdate
   WHERE rowid = rowid_
   RETURNING rowversion INTO rec_.rowversion;
   objversion_ := to_char(rec_.rowversion,'YYYYMMDDHH24MISS');
END Write_Response_Msg__;


--@IgnoreMissingSysinit
PROCEDURE Lock__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2 )
IS
   dummy_ c_swift_payment_tab%ROWTYPE;
BEGIN
   dummy_ := Lock_By_Id___(objid_, objversion_);
   info_ := Client_SYS.Get_All_Info;
END Lock__;


PROCEDURE New__ (
   info_       OUT    VARCHAR2,
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   attr_       IN OUT NOCOPY VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   newrec_   c_swift_payment_tab%ROWTYPE;
   indrec_   Indicator_Rec;
   attr_cf_  VARCHAR2(32000);
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'New__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.New__ (Base)', 'attr_', attr_, 'action_', action_);
   END IF;
   Custom_Object_Proxy_SYS.Detach_Custom_Attributes_(attr_, attr_cf_);
   IF (action_ = 'PREPARE') THEN
      Prepare_Insert___(attr_);
   ELSIF (action_ = 'CHECK') THEN
      Unpack___(newrec_, indrec_, attr_);
      Check_Insert___(newrec_, indrec_, attr_);
   ELSIF (action_ = 'DO') THEN
      Unpack___(newrec_, indrec_, attr_);
      Check_Insert___(newrec_, indrec_, attr_);
      Insert___(objid_, objversion_, newrec_, attr_);
   END IF;
   info_ := Client_SYS.Get_All_Info;
   Custom_Object_Proxy_SYS.Cf_New_(info_, attr_, lu_name_, objid_, attr_cf_, action_);
END New__;


PROCEDURE Modify__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   attr_       IN OUT NOCOPY VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   oldrec_     c_swift_payment_tab%ROWTYPE;
   newrec_     c_swift_payment_tab%ROWTYPE;
   indrec_     Indicator_Rec;
   attr_cf_    VARCHAR2(32000);
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Modify__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Modify__ (Base)', 'objid_', objid_, 'objversion_', objversion_, 'attr_', attr_, 'action_', action_);
   END IF;
   Custom_Object_Proxy_SYS.Detach_Custom_Attributes_(attr_, attr_cf_);
   IF (action_ = 'CHECK') THEN
      oldrec_ := Get_Object_By_Id___(objid_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
   ELSIF (action_ = 'DO') THEN
      oldrec_ := Lock_By_Id___(objid_, objversion_);
      newrec_ := oldrec_;
      Unpack___(newrec_, indrec_, attr_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_);
   END IF;
   info_ := Client_SYS.Get_All_Info;
   Custom_Object_Proxy_SYS.Cf_Modify_(info_, attr_, lu_name_, objid_, attr_cf_, action_);
END Modify__;


PROCEDURE Remove__ (
   info_       OUT VARCHAR2,
   objid_      IN  VARCHAR2,
   objversion_ IN  VARCHAR2,
   action_     IN  VARCHAR2 )
IS
   remrec_     c_swift_payment_tab%ROWTYPE;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Remove__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Remove__ (Base)', 'objid_', objid_, 'objversion_', objversion_, 'action_', action_);
   END IF;
   IF (action_ = 'CHECK') THEN
      remrec_ := Get_Object_By_Id___(objid_);
      Check_Delete___(remrec_);
   ELSIF (action_ = 'DO') THEN
      remrec_ := Lock_By_Id___(objid_, objversion_);
      Check_Delete___(remrec_);
      Delete___(objid_, remrec_);
   END IF;
   info_ := Client_SYS.Get_All_Info;
END Remove__;


FUNCTION Key_Message___ (
   id_ IN NUMBER ) RETURN VARCHAR2
IS
   msg_ VARCHAR2(4000) := Message_SYS.Construct('ERROR_KEY');
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Key_Message___ (Base)', 'id_', id_);
   END IF;
   Message_SYS.Add_Attribute(msg_, 'ID', id_);
   RETURN msg_;
END Key_Message___;


FUNCTION Formatted_Key___ (
   id_ IN NUMBER ) RETURN VARCHAR2
IS
   formatted_key_ VARCHAR2(4000) := Language_SYS.Translate_Item_Prompt_(lu_name_, 'ID', Fnd_Session_API.Get_Language) || ': ' || id_;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Formatted_Key___ (Base)', 'id_', id_);
   END IF;
   RETURN formatted_key_;
END Formatted_Key___;


PROCEDURE Raise_Too_Many_Rows___ (
   id_ IN NUMBER,
   methodname_ IN VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Too_Many_Rows___ (Base)', 'id_', id_, 'methodname_', methodname_);
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(id_),
                            Formatted_Key___(id_));
   Error_SYS.Fnd_Too_Many_Rows(C_Swift_Payment_API.lu_name_, methodname_, NULL);
END Raise_Too_Many_Rows___;


PROCEDURE Raise_Record_Not_Exist___ (
   id_ IN NUMBER )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Record_Not_Exist___ (Base)', 'id_', id_);
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(id_),
                            Formatted_Key___(id_));
   Error_SYS.Fnd_Record_Not_Exist(C_Swift_Payment_API.lu_name_);
END Raise_Record_Not_Exist___;


PROCEDURE Raise_Record_Exist___ (
   rec_ IN c_swift_payment_tab%ROWTYPE )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Record_Exist___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(rec_.id),
                            Formatted_Key___(rec_.id));
   Error_SYS.Fnd_Record_Exist(C_Swift_Payment_API.lu_name_);
END Raise_Record_Exist___;


PROCEDURE Raise_Constraint_Violated___ (
   rec_ IN c_swift_payment_tab%ROWTYPE,
   constraint_ IN VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Constraint_Violated___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)', 'constraint_', constraint_);
   END IF;
   Error_SYS.Fnd_Record_Exist(C_Swift_Payment_API.lu_name_);
END Raise_Constraint_Violated___;


PROCEDURE Raise_Item_Format___ (
   name_ IN VARCHAR2,
   value_ IN VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Item_Format___ (Base)', 'name_', name_, 'value_', value_);
   END IF;
   Error_SYS.Fnd_Item_Format(C_Swift_Payment_API.lu_name_, name_, value_);
END Raise_Item_Format___;


PROCEDURE Raise_Record_Modified___ (
   rec_ IN c_swift_payment_tab%ROWTYPE )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Record_Modified___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(rec_.id),
                            Formatted_Key___(rec_.id));
   Error_SYS.Fnd_Record_Modified(C_Swift_Payment_API.lu_name_);
END Raise_Record_Modified___;


PROCEDURE Raise_Record_Locked___ (
   id_ IN NUMBER )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Record_Locked___ (Base)', 'id_', id_);
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(id_),
                            Formatted_Key___(id_));
   Error_SYS.Fnd_Record_Locked(C_Swift_Payment_API.lu_name_);
END Raise_Record_Locked___;


PROCEDURE Raise_Record_Removed___ (
   id_ IN NUMBER )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Raise_Record_Removed___ (Base)', 'id_', id_);
   END IF;
   Error_SYS.Set_Key_Values(Key_Message___(id_),
                            Formatted_Key___(id_));
   Error_SYS.Fnd_Record_Removed(C_Swift_Payment_API.lu_name_);
END Raise_Record_Removed___;


FUNCTION Lock_By_Id___ (
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE
IS
   row_locked  EXCEPTION;
   PRAGMA      EXCEPTION_INIT(row_locked, -0054);
   rec_        c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Lock_By_Id___ (Base)', 'objid_', objid_, 'objversion_', objversion_);
   END IF;
   SELECT *
      INTO  rec_
      FROM  c_swift_payment_tab
      WHERE rowid = objid_
      AND    to_char(rowversion,'YYYYMMDDHH24MISS') = objversion_
      FOR UPDATE NOWAIT;
   RETURN rec_;
EXCEPTION
   WHEN row_locked THEN
      Error_SYS.Fnd_Record_Locked(lu_name_);
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(NULL, 'Lock_By_Id___');
   WHEN no_data_found THEN
      BEGIN
         SELECT *
            INTO  rec_
            FROM  c_swift_payment_tab
            WHERE rowid = objid_;
         Raise_Record_Modified___(rec_);
      EXCEPTION
         WHEN no_data_found THEN
            Error_SYS.Fnd_Record_Removed(lu_name_);
         WHEN too_many_rows THEN
            Raise_Too_Many_Rows___(NULL, 'Lock_By_Id___');
      END;
END Lock_By_Id___;


FUNCTION Lock_By_Keys___ (
   id_ IN NUMBER) RETURN c_swift_payment_tab%ROWTYPE
IS
   rec_        c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Lock_By_Keys___ (Base)', 'id_', id_);
   END IF;
   BEGIN
      SELECT *
         INTO  rec_
         FROM  c_swift_payment_tab
         WHERE id = id_
         FOR UPDATE;
      RETURN rec_;
   EXCEPTION
      WHEN no_data_found THEN
         Raise_Record_Removed___(id_);
      WHEN too_many_rows THEN
         Raise_Too_Many_Rows___(id_, 'Lock_By_Keys___');
   END;
END Lock_By_Keys___;


FUNCTION Lock_By_Keys_Nowait___ (
   id_ IN NUMBER) RETURN c_swift_payment_tab%ROWTYPE
IS
   row_locked  EXCEPTION;
   PRAGMA      EXCEPTION_INIT(row_locked, -0054);
   rec_        c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Lock_By_Keys_Nowait___ (Base)', 'id_', id_);
   END IF;
   BEGIN
      SELECT *
         INTO  rec_
         FROM  c_swift_payment_tab
         WHERE id = id_
         FOR UPDATE NOWAIT;
      RETURN rec_;
   EXCEPTION
      WHEN row_locked THEN
         Raise_Record_Locked___(id_);
      WHEN too_many_rows THEN
         Raise_Too_Many_Rows___(id_, 'Lock_By_Keys___');
      WHEN no_data_found THEN
         Raise_Record_Removed___(id_);
   END;
END Lock_By_Keys_Nowait___;


FUNCTION Get_Object_By_Id___ (
   objid_ IN VARCHAR2 ) RETURN c_swift_payment_tab%ROWTYPE
IS
   lu_rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Object_By_Id___ (Base)', 'objid_', objid_);
   END IF;
   SELECT *
      INTO  lu_rec_
      FROM  c_swift_payment_tab
      WHERE rowid = objid_;
   RETURN lu_rec_;
EXCEPTION
   WHEN no_data_found THEN
      Error_SYS.Fnd_Record_Removed(lu_name_);
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(NULL, 'Get_Object_By_Id___');
END Get_Object_By_Id___;


--@IgnoreMissingSysinit
FUNCTION Get_Object_By_Keys___ (
   id_ IN NUMBER ) RETURN c_swift_payment_tab%ROWTYPE
IS
   lu_rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   SELECT *
      INTO  lu_rec_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN lu_rec_;
EXCEPTION
   WHEN no_data_found THEN
      RETURN lu_rec_;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Object_By_Keys___');
END Get_Object_By_Keys___;


--@IgnoreMissingSysinit
FUNCTION Check_Exist___ (
   id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
BEGIN
   IF (id_ IS NULL) THEN
      RETURN FALSE;
   END IF;
   SELECT 1
      INTO  dummy_
      FROM  c_swift_payment_tab
      WHERE id = id_;
   RETURN TRUE;
EXCEPTION
   WHEN no_data_found THEN
      RETURN FALSE;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Check_Exist___');
END Check_Exist___;


PROCEDURE Get_Version_By_Id___ (
   objid_      IN     VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Version_By_Id___ (Base)', 'objid_', objid_, 'objversion_', objversion_);
   END IF;
   SELECT to_char(rowversion,'YYYYMMDDHH24MISS')
      INTO  objversion_
      FROM  c_swift_payment_tab
      WHERE rowid = objid_;
EXCEPTION
   WHEN no_data_found THEN
      objversion_ := NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(NULL, 'Get_Version_By_Id___');
END Get_Version_By_Id___;


PROCEDURE Get_Id_Version_By_Keys___ (
   objid_      IN OUT NOCOPY VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   id_ IN NUMBER )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Id_Version_By_Keys___ (Base)', 'objid_', objid_, 'objversion_', objversion_, 'id_', id_);
   END IF;
   SELECT rowid, to_char(rowversion,'YYYYMMDDHH24MISS')
      INTO  objid_, objversion_
      FROM  c_swift_payment_tab
      WHERE id = id_;
EXCEPTION
   WHEN no_data_found THEN
      objid_      := NULL;
      objversion_ := NULL;
   WHEN too_many_rows THEN
      Raise_Too_Many_Rows___(id_, 'Get_Id_Version_By_Keys___');
END Get_Id_Version_By_Keys___;


PROCEDURE Unpack___ (
   newrec_   IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_   IN OUT NOCOPY Indicator_Rec,
   attr_     IN OUT NOCOPY VARCHAR2 )
IS
   ptr_   NUMBER;
   name_  VARCHAR2(30);
   value_ VARCHAR2(32000);
   msg_   VARCHAR2(32000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Unpack___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'indrec_', '(Indicator_Rec)', 'attr_', attr_);
   END IF;
   Reset_Indicator_Rec___(indrec_);
   Client_SYS.Clear_Attr(msg_);
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      CASE name_
      WHEN ('ID') THEN
         newrec_.id := Client_SYS.Attr_Value_To_Number(value_);
         indrec_.id := TRUE;
      WHEN ('MSG_ID') THEN
         newrec_.msg_id := value_;
         indrec_.msg_id := TRUE;
      ELSE
         Client_SYS.Add_To_Attr(name_, value_, msg_);
      END CASE;
   END LOOP;
   attr_ := msg_;
EXCEPTION
   WHEN value_error THEN
      Raise_Item_Format___(name_, value_);
END Unpack___;


FUNCTION Pack___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN VARCHAR2
IS
   attr_ VARCHAR2(32000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Pack___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   Client_SYS.Clear_Attr(attr_);
   IF (rec_.id IS NOT NULL) THEN
      Client_SYS.Add_To_Attr('ID', rec_.id, attr_);
   END IF;
   IF (rec_.msg_id IS NOT NULL) THEN
      Client_SYS.Add_To_Attr('MSG_ID', rec_.msg_id, attr_);
   END IF;
   RETURN attr_;
END Pack___;


FUNCTION Pack___ (
   rec_ IN c_swift_payment_tab%ROWTYPE,
   indrec_ IN Indicator_Rec ) RETURN VARCHAR2
IS
   attr_ VARCHAR2(32000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Pack___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)', 'indrec_', '(Indicator_Rec)');
   END IF;
   Client_SYS.Clear_Attr(attr_);
   IF (indrec_.id) THEN
      Client_SYS.Add_To_Attr('ID', rec_.id, attr_);
   END IF;
   IF (indrec_.msg_id) THEN
      Client_SYS.Add_To_Attr('MSG_ID', rec_.msg_id, attr_);
   END IF;
   RETURN attr_;
END Pack___;


FUNCTION Pack_Table___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN VARCHAR2
IS
   attr_ VARCHAR2(32000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Pack_Table___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr('ID', rec_.id, attr_);
   Client_SYS.Add_To_Attr('MSG_ID', rec_.msg_id, attr_);
   Client_SYS.Add_To_Attr('ROWKEY', rec_.rowkey, attr_);
   RETURN attr_;
END Pack_Table___;


FUNCTION Public_To_Table___ (
   public_ IN Public_Rec ) RETURN c_swift_payment_tab%ROWTYPE
IS
   rec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Public_To_Table___ (Base)', 'public_', '(Public_Rec)');
   END IF;
   rec_.rowversion                     := public_.rowversion;
   rec_.rowkey                         := public_.rowkey;
   rec_.id                             := public_.id;
   rec_.msg_id                         := public_.msg_id;
   rec_.payment_msg                    := public_.payment_msg;
   rec_.response_msg                   := public_.response_msg;
   RETURN rec_;
END Public_To_Table___;


FUNCTION Table_To_Public___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Public_Rec
IS
   public_ Public_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Table_To_Public___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   public_.rowversion                     := rec_.rowversion;
   public_.rowkey                         := rec_.rowkey;
   public_.id                             := rec_.id;
   public_.msg_id                         := rec_.msg_id;
   public_.payment_msg                    := rec_.payment_msg;
   public_.response_msg                   := rec_.response_msg;
   RETURN public_;
END Table_To_Public___;


PROCEDURE Reset_Indicator_Rec___ (
   indrec_ IN OUT NOCOPY Indicator_Rec )
IS
   empty_indrec_ Indicator_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Reset_Indicator_Rec___ (Base)', 'indrec_', '(Indicator_Rec)');
   END IF;
   indrec_ := empty_indrec_;
END Reset_Indicator_Rec___;


FUNCTION Get_Indicator_Rec___ (
   rec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Indicator_Rec
IS
   indrec_ Indicator_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Indicator_Rec___ (Base)', 'rec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   indrec_.id := rec_.id IS NOT NULL;
   indrec_.msg_id := rec_.msg_id IS NOT NULL;
   RETURN indrec_;
END Get_Indicator_Rec___;


FUNCTION Get_Indicator_Rec___ (
   oldrec_ IN c_swift_payment_tab%ROWTYPE,
   newrec_ IN c_swift_payment_tab%ROWTYPE ) RETURN Indicator_Rec
IS
   indrec_ Indicator_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Indicator_Rec___ (Base)', 'oldrec_', '(c_swift_payment_tab%ROWTYPE)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   indrec_.id := Validate_SYS.Is_Changed(oldrec_.id, newrec_.id);
   indrec_.msg_id := Validate_SYS.Is_Changed(oldrec_.msg_id, newrec_.msg_id);
   RETURN indrec_;
END Get_Indicator_Rec___;


PROCEDURE Check_Common___ (
   oldrec_ IN     c_swift_payment_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Check_Common___ (Base)', 'oldrec_', '(c_swift_payment_tab%ROWTYPE)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'indrec_', '(Indicator_Rec)', 'attr_', attr_);
   END IF;
   Error_SYS.Check_Not_Null(lu_name_, 'ID', newrec_.id);
END Check_Common___;


PROCEDURE Check_Insert___ (
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
   oldrec_ c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Check_Insert___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'indrec_', '(Indicator_Rec)', 'attr_', attr_);
   END IF;
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Insert___;


PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   attr_       IN OUT NOCOPY VARCHAR2 )
IS
   value_too_large  EXCEPTION;
   PRAGMA           EXCEPTION_INIT(value_too_large, -12899);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Insert___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'attr_', attr_);
   END IF;
   newrec_.rowversion := sysdate;
   newrec_.rowkey := sys_guid();
   Client_SYS.Add_To_Attr('OBJKEY', newrec_.rowkey, attr_);
   INSERT
      INTO c_swift_payment_tab
      VALUES newrec_
      RETURNING rowid INTO objid_;
   objversion_ := to_char(newrec_.rowversion,'YYYYMMDDHH24MISS');
EXCEPTION
   WHEN dup_val_on_index THEN
      DECLARE
         constraint_ VARCHAR2(4000) := Utility_SYS.Get_Constraint_From_Error_Msg(sqlerrm);
      BEGIN
         IF (constraint_ = 'C_SWIFT_PAYMENT_RK') THEN
            Error_SYS.Fnd_Rowkey_Exist(lu_name_, newrec_.rowkey);
         ELSIF (constraint_ = 'C_SWIFT_PAYMENT_PK') THEN
            Raise_Record_Exist___(newrec_);
         ELSE
            Raise_Constraint_Violated___(newrec_, constraint_);
         END IF;
      END;
   WHEN value_too_large THEN
      Error_SYS.Fnd_Item_Length(lu_name_, sqlerrm);
END Insert___;


PROCEDURE Prepare_New___ (
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE )
IS
   attr_    VARCHAR2(32000);
   indrec_  Indicator_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Prepare_New___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   attr_ := Pack___(newrec_);
   Prepare_Insert___(attr_);
   Unpack___(newrec_, indrec_, attr_);
END Prepare_New___;


PROCEDURE New___ (
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE )
IS
   objid_         VARCHAR2(20);
   objversion_    VARCHAR2(100);
   attr_          VARCHAR2(32000);
   indrec_        Indicator_Rec;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.New___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   indrec_ := Get_Indicator_Rec___(newrec_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New___;


PROCEDURE Check_Update___ (
   oldrec_ IN     c_swift_payment_tab%ROWTYPE,
   newrec_ IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Check_Update___ (Base)', 'oldrec_', '(c_swift_payment_tab%ROWTYPE)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'indrec_', '(Indicator_Rec)', 'attr_', attr_);
   END IF;
   Validate_SYS.Item_Update(lu_name_, 'ID', indrec_.id);
   Validate_SYS.Item_Update(lu_name_, 'MSG_ID', indrec_.msg_id);
   Check_Common___(oldrec_, newrec_, indrec_, attr_);
END Check_Update___;


PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     c_swift_payment_tab%ROWTYPE,
   newrec_     IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   attr_       IN OUT NOCOPY VARCHAR2,
   objversion_ IN OUT NOCOPY VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   value_too_large  EXCEPTION;
   PRAGMA           EXCEPTION_INIT(value_too_large, -12899);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Update___ (Base)', 'objid_', objid_, 'oldrec_', '(c_swift_payment_tab%ROWTYPE)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'attr_', attr_, 'objversion_', objversion_, 'by_keys_', Log_SYS.Boolean_To_Varchar2(by_keys_));
   END IF;
   newrec_.rowversion := sysdate;
   IF newrec_.rowkey IS NULL THEN
      newrec_.rowkey := oldrec_.rowkey;
   END IF;
   IF by_keys_ THEN
      UPDATE c_swift_payment_tab
         SET ROW = newrec_
         WHERE id = newrec_.id;
   ELSE
      UPDATE c_swift_payment_tab
         SET ROW = newrec_
         WHERE rowid = objid_;
   END IF;
   objversion_ := to_char(newrec_.rowversion,'YYYYMMDDHH24MISS');
EXCEPTION
   WHEN dup_val_on_index THEN
      DECLARE
         constraint_ VARCHAR2(4000) := Utility_SYS.Get_Constraint_From_Error_Msg(sqlerrm);
      BEGIN
         IF (constraint_ = 'C_SWIFT_PAYMENT_RK') THEN
            Error_SYS.Fnd_Rowkey_Exist(C_Swift_Payment_API.lu_name_, newrec_.rowkey);
         ELSIF (constraint_ = 'C_SWIFT_PAYMENT_PK') THEN
            Raise_Record_Exist___(newrec_);
         ELSE
            Raise_Constraint_Violated___(newrec_, constraint_);
         END IF;
      END;
   WHEN value_too_large THEN
      Error_SYS.Fnd_Item_Length(lu_name_, sqlerrm);
END Update___;


PROCEDURE Modify___ (
   newrec_         IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
   objid_      VARCHAR2(20);
   objversion_ VARCHAR2(100);
   attr_       VARCHAR2(32000);
   indrec_     Indicator_rec;
   oldrec_     c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Modify___ (Base)', 'newrec_', '(c_swift_payment_tab%ROWTYPE)', 'lock_mode_wait_', Log_SYS.Boolean_To_Varchar2(lock_mode_wait_));
   END IF;
   IF (lock_mode_wait_) THEN
      oldrec_ := Lock_By_Keys___(newrec_.id);
   ELSE
      oldrec_ := Lock_By_Keys_Nowait___(newrec_.id);
   END IF;
   indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Modify___;


PROCEDURE Check_Delete___ (
   remrec_ IN c_swift_payment_tab%ROWTYPE )
IS
   key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Check_Delete___ (Base)', 'remrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   key_ := remrec_.id||'^';
   Reference_SYS.Check_Restricted_Delete(lu_name_, key_);
END Check_Delete___;


PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN c_swift_payment_tab%ROWTYPE )
IS
   key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Delete___ (Base)', 'objid_', objid_, 'remrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   key_ := remrec_.id||'^';
   Reference_SYS.Do_Cascade_Delete(lu_name_, key_);
   IF (objid_ IS NOT NULL) THEN
      DELETE
         FROM  c_swift_payment_tab
         WHERE rowid = objid_;
   ELSE
      DELETE
         FROM  c_swift_payment_tab
         WHERE id = remrec_.id;
   END IF;
END Delete___;


PROCEDURE Delete___ (
   remrec_ IN c_swift_payment_tab%ROWTYPE )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Delete___ (Base)', 'remrec_', '(c_swift_payment_tab%ROWTYPE)');
   END IF;
   Delete___(NULL, remrec_);
END Delete___;


PROCEDURE Remove___ (
   remrec_         IN OUT NOCOPY c_swift_payment_tab%ROWTYPE,
   lock_mode_wait_ IN     BOOLEAN DEFAULT TRUE )
IS
   oldrec_     c_swift_payment_tab%ROWTYPE;
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Remove___ (Base)', 'remrec_', '(c_swift_payment_tab%ROWTYPE)', 'lock_mode_wait_', Log_SYS.Boolean_To_Varchar2(lock_mode_wait_));
   END IF;
   IF (lock_mode_wait_) THEN
      oldrec_ := Lock_By_Keys___(remrec_.id);
   ELSE
      oldrec_ := Lock_By_Keys_Nowait___(remrec_.id);
   END IF;
   Check_Delete___(oldrec_);
   Delete___(NULL, oldrec_);
END Remove___;

-----------------------------------------------------------------------------
-------------------- LU CUST NEW METHODS ------------------------------------
-----------------------------------------------------------------------------

FUNCTION Store_Msg(
   in_payment_msg_ IN CLOB)
   RETURN VARCHAR2
IS
   info_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   attr_        VARCHAR2(2000);
   
   sequence_ NUMBER;
   
     incld_resp_info_ boolean := sys.diutil.int_to_bool(0);
  in_order_ boolean := sys.diutil.int_to_bool(0);
  fail_notify_ boolean := sys.diutil.int_to_bool(0);
  -- Non-scalar parameters require additional processing 
  url_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  query_parameters_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  header_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  auth_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  http_req_headers_ VARCHAR2(2000);
  xml_ CLOB ;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Store_Msg');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Store_Msg (Cust)', 'in_payment_msg_', '(CLOB)');
   END IF;
   
    
   sequence_ :=  C_SWIFT_PAYMENT_SEQ.NEXTVAL;
   client_sys.add_to_attr('ID' , sequence_ , attr_);
   
   C_Swift_Payment_API.New__ (
   info_       ,
   objid_      ,
   objversion_ ,
   attr_       ,
   'DO' );
   
   Write_Payment_Msg__(objversion_, objid_, in_payment_msg_);
   
   
 
  xml_ := JSF_PROPERTY_api.Get_Property_Value('Ifs' , 'ifs.Client_Id' );

http_req_headers_ := 'Content-Type: application/x-www-form-urlencoded';
  Plsql_Rest_Sender_API.Call_Rest_EndPoint2(rest_service_ => 'SWIFT_AUTH_SERVICE',
                                            xml_ => xml_,
                                            url_params_ => url_params_,
                                            callback_func_ => 'C_Swift_Payment_API.Call_Swift_Api',
                                            http_method_ => 'POST',
                                            http_req_headers_ => http_req_headers_,
                                            query_parameters_ => query_parameters_,
                                            header_params_ => header_params_,
                                            incld_resp_info_ => incld_resp_info_,
                                            fnd_user_ => 'IFSAPP',
                                            key_ref_ => sequence_,
                                            sender_ => 'SWIFT_AUTH_SENDER',
                                            receiver_ => 'SWIFT_AUTH_RECEIVER',
                                            message_type_ => '',
                                            subject_ => '',
                                            in_order_ => in_order_,
                                            fail_notify_ => fail_notify_,
                                            failed_callback_fun_ => '',
                                            accepted_res_codes_ => '',
                                            auth_params_ => auth_params_);
                                            
   
   RETURN 'Saved Successfully';
END Store_Msg;


PROCEDURE Call_Swift_Api(
   msg_ IN CLOB, 
   app_msg_id_  IN VARCHAR2 , 
   fnd_user_    IN VARCHAR2 , 
   key_ref_     IN VARCHAR2
   )
IS
   v_token_ CLOB;
   subscription_key_ VARCHAR2(2000);
     incld_resp_info_ boolean := sys.diutil.int_to_bool(0);
  in_order_ boolean := sys.diutil.int_to_bool(0);
  fail_notify_ boolean := sys.diutil.int_to_bool(0);
  -- Non-scalar parameters require additional processing 
  url_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  query_parameters_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  header_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  auth_params_ PLSQLAP_DOCUMENT_API.DOCUMENT;
  http_req_headers_ VARCHAR2(2000);
  xml_ CLOB ;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Call_Swift_Api');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Call_Swift_Api (Cust)', 'msg_', '(CLOB)', 'app_msg_id_', app_msg_id_, 'fnd_user_', fnd_user_, 'key_ref_', key_ref_);
   END IF;
   
    v_token_ := JSON_VALUE(msg_ , '$.access_token');
    subscription_key_ := JSF_PROPERTY_api.Get_Property_Value('Ifs' , 'ifs.Subscription_key' );
    http_req_headers_ := 'Content-Type:application/json,
                          Authorization:Bearer '||v_token_ ||',
                          Ocp-Apim-Subscription-Key: '||subscription_key_;
    
    
  --  error_sys.record_general('', http_req_headers_);
    SELECT Payment_Msg INTO xml_ FROM C_Swift_Payment WHERE ID = key_ref_;
    Plsql_Rest_Sender_API.Call_Rest_EndPoint2(rest_service_ => 'C_CALL_SWIFT_API',
                                            xml_ => xml_,
                                            url_params_ => url_params_,
                                            callback_func_ => 'C_Swift_Payment_API.Store_Response_Msg',
                                            http_method_ => 'POST',
                                            http_req_headers_ => http_req_headers_,
                                            query_parameters_ => query_parameters_,
                                            header_params_ => header_params_,
                                            incld_resp_info_ => incld_resp_info_,
                                            fnd_user_ => 'IFSAPP',
                                            key_ref_ => key_ref_,
                                            sender_ => 'SWIFT_AUTH_SENDER',
                                            receiver_ => 'SWIFT_AUTH_RECEIVER',
                                            message_type_ => '',
                                            subject_ => '',
                                            in_order_ => in_order_,
                                            fail_notify_ => fail_notify_,
                                            failed_callback_fun_ => '',
                                            accepted_res_codes_ => '',
                                            auth_params_ => auth_params_);
    
  -- error_sys.record_general('','app_msg_id_'||app_msg_id_||'-keyref-'||key_ref_ );
END Call_Swift_Api;


PROCEDURE Store_Response_Msg(
   msg_ IN CLOB, 
   app_msg_id_  IN VARCHAR2 , 
   fnd_user_    IN VARCHAR2 , 
   key_ref_     IN VARCHAR2)
IS
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
  
   CURSOR get_objid_version IS 
     SELECT  ROWID ,  to_char(rowversion,'YYYYMMDDHH24MISS')
      FROM  c_swift_payment_tab
      WHERE id = key_ref_;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Store_Response_Msg');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Store_Response_Msg (Cust)', 'msg_', '(CLOB)', 'app_msg_id_', app_msg_id_, 'fnd_user_', fnd_user_, 'key_ref_', key_ref_);
   END IF;
   
   OPEN get_objid_version;
   FETCH get_objid_version INTO objid_ , objversion_;
   CLOSE get_objid_version;
    
   Write_Response_Msg__(objversion_, objid_, msg_);
END Store_Response_Msg;


FUNCTION Store_Transformed_Msg(
   msg_ IN CLOB)
   RETURN VARCHAR2
IS
   info_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   attr_        VARCHAR2(2000);
   
   sequence_ NUMBER;
BEGIN
   General_SYS.Init_Method(C_Swift_Payment_API.lu_name_, 'C_Swift_Payment_API', 'Store_Transformed_Msg');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Store_Transformed_Msg (Cust)', 'msg_', '(CLOB)');
   END IF;
   
    
   sequence_ :=  C_SWIFT_PAYMENT_SEQ.NEXTVAL;
   client_sys.add_to_attr('ID' , sequence_ , attr_);
   
   C_Swift_Payment_API.New__ (
   info_       ,
   objid_      ,
   objversion_ ,
   attr_       ,
   'DO' );
   
   Write_Payment_Msg__(objversion_, objid_, msg_);
   
RETURN 'Msg Saved Successfully';
END Store_Transformed_Msg;

-----------------------------------------------------------------------------
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
-----------------------------------------------------------------------------

PROCEDURE Prepare_Insert___ (
   attr_ IN OUT NOCOPY VARCHAR2 )
IS
   
   PROCEDURE Base (
      attr_ IN OUT NOCOPY VARCHAR2 )
   IS
   BEGIN
      IF (Log_SYS.extended_trace_enabled_) THEN
         Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Prepare_Insert___ (Base)', 'attr_', attr_);
      END IF;
      Client_SYS.Clear_Attr(attr_);
   END Base;

   PROCEDURE Cust (
      attr_ IN OUT NOCOPY VARCHAR2 )
   IS
   BEGIN
      IF (Log_SYS.extended_trace_enabled_) THEN
         Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Prepare_Insert___ (Cust)', 'attr_', attr_);
      END IF;
      --Add pre-processing code here
      Base(attr_);
      --Add post-processing code here
      
   END Cust;

BEGIN
   Cust(attr_);
END Prepare_Insert___;

-----------------------------------------------------------------------------
-------------------- FOUNDATION1 METHODS ------------------------------------
-----------------------------------------------------------------------------


--@IgnoreMissingSysinit
PROCEDURE Init
IS
BEGIN
   NULL;
END Init;



-----------------------------------------------------------------------------
------------------------- METADATA PROVIDER METHODS -------------------------
-----------------------------------------------------------------------------

FUNCTION Verify_Metadata_Sql_Content_ (
   metadata_version_ IN VARCHAR2 ) RETURN VARCHAR2;

PROCEDURE Verify_Metadata_Plsql_Content_ (
   metadata_version_ IN VARCHAR2 );

FUNCTION Get_Metadata_Content_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN CLOB;

FUNCTION Get_Metadata_Version_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

FUNCTION Get_Metadata_Category_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

FUNCTION Get_Metadata_Service_Group_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

-----------------------------------------------------------------------------
------------------------------- GLOBAL METHODS ------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
------------------------- METADATA PROVIDER METHODS -------------------------
-----------------------------------------------------------------------------

FUNCTION Verify_Metadata_Sql_Content_ (
   metadata_version_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   Verify_Metadata_Plsql_Content_(metadata_version_);
   RETURN 'OK';
END Verify_Metadata_Sql_Content_;


PROCEDURE Verify_Metadata_Plsql_Content_ (
   metadata_version_ IN VARCHAR2 )
IS
BEGIN
   IF (metadata_version_ != Get_Metadata_Version_) THEN
      Raise_Application_Error(-20187, 'OLDMETA: Metadata mismatch, reload with C_Swift_Payment_API.Get_Metadata_Content_ and execute again.');
   END IF;
END Verify_Metadata_Plsql_Content_;


FUNCTION Get_Metadata_Content_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN CLOB
IS
BEGIN
   IF (context_ IS NULL) THEN
      RETURN Model_Design_SYS.Get_Data_Content_(Model_Design_SYS.SERVER_METADATA, 'projection', 'CSwiftPaymentEntity', language_ => Fnd_Session_API.Get_Language);
   ELSE
      RETURN Model_Design_SYS.Get_Data_Content_(Model_Design_SYS.SERVER_METADATA, 'projection', 'CSwiftPaymentEntity', language_ => Fnd_Session_API.Get_Language, scope_id_ => context_);
   END IF;
END Get_Metadata_Content_;


FUNCTION Get_Metadata_Category_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   projection_category_  VARCHAR2(100);
BEGIN
   projection_category_ := 'Integration';
   RETURN projection_category_;
END Get_Metadata_Category_;


FUNCTION Get_Metadata_Service_Group_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   projection_service_group_  VARCHAR2(100);
BEGIN
   projection_service_group_ := 'Default';
   RETURN projection_service_group_;
END Get_Metadata_Service_Group_;


FUNCTION Get_Metadata_Version_ (
   context_ IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
BEGIN
   RETURN Model_Design_SYS.Get_Data_Version_(Model_Design_SYS.SERVER_METADATA, 'projection', 'CSwiftPaymentEntity');
END Get_Metadata_Version_;


-----------------------------------------------------------------------------
--------------------- IMPLEMENTATION METHOD DECLARATIONS --------------------
-----------------------------------------------------------------------------

FUNCTION Get_Objid_From_Etag___ (
   etag_ IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION Get_Objversion_From_Etag___ (
   etag_ IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION Get_Etag___ (
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION Combine_Value_Unit___ (
   value_ IN VARCHAR2,
   unit_  IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION To_Boolean_Arr____ (
   arr_ IN Text_Arr ) RETURN Boolean_Arr;

PROCEDURE Add_To_Attr_From_Rec___ (
   rec_  IN     C_Swift_Payment_Entity_Rec,
   attr_ IN OUT NOCOPY VARCHAR2 );

PROCEDURE Add_To_Rec_From_Attr___ (
   attr_ IN     VARCHAR2,
   rec_  IN OUT NOCOPY C_Swift_Payment_Entity_Rec );

PROCEDURE Get_Objid_Objversion___ (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   key_        IN     C_Swift_Payment_Entity_Key );

PROCEDURE CRUD_Default___ (
   key_  IN     C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2 );

PROCEDURE CRUD_Default___ (
   rec_  IN OUT NOCOPY C_Swift_Payment_Entity_Rec );

PROCEDURE CRUD_Create___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN OUT NOCOPY C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 );

PROCEDURE CRUD_Update___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN OUT NOCOPY C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 );

PROCEDURE CRUD_Upload___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN C_Swift_Payment_Entity_Key,
   payment_msg##    IN     CLOB);

PROCEDURE CRUD_Upload___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN C_Swift_Payment_Entity_Key,
   response_msg##    IN     CLOB);

PROCEDURE CRUD_Delete___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN     C_Swift_Payment_Entity_Key,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 );

-----------------------------------------------------------------------------
-------------------- PRIVATE METHODS FOR C SWIFT PAYMENT ENTITY -------------
-----------------------------------------------------------------------------

FUNCTION CRUD_Default__(attr_ IN VARCHAR2 DEFAULT NULL, c_swift_payment## IN VARCHAR2 ) RETURN Entity_Small_Drr PIPELINED
IS
   ret_ Entity_Small_Dec;
   key_ C_Swift_Payment_Entity_Key;
BEGIN
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Default__');
   ret_.attr := attr_;
   CRUD_Default___(key_, ret_.attr, ret_.info);
   Client_SYS.Add_New_Items_From_Attr(attr_, ret_.attr);
   PIPE ROW (ret_);
END CRUD_Default__;



FUNCTION CRUD_Create__(attr_ IN VARCHAR2, action_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec
IS
   ret_ Entity_Dec;
   key_ C_Swift_Payment_Entity_Key;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   General_SYS.Init_Projection_Method(entity_projection_name_, 'C_Swift_Payment_API', 'CRUD_Create__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Create__ (Base)', 'attr_', attr_, 'action_', action_, 'c_swift_payment##', c_swift_payment##);
   END IF;
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Create__');
   ret_.attr := attr_;
   CRUD_Create___(ret_.etag, key_, ret_.attr, ret_.info, action_);
   IF (action_ = 'DO') THEN
      Get_Objid_Objversion___(objid_, objversion_, key_);
      Security_SYS.Check_Data_Access_For_Create('CSwiftPaymentEntity', 'CSwiftPayment', objid_);
   END IF;
   Client_SYS.Set_Item_Value('ID', key_.id, ret_.attr);
   return ret_;
END CRUD_Create__;


FUNCTION CRUD_Update__(etag_ IN VARCHAR2, id_ IN NUMBER, attr_ IN VARCHAR2, action$_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec
IS
   ret_ Entity_Dec;
   key_temp_ C_Swift_Payment_Entity_Key;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   General_SYS.Init_Projection_Method(entity_projection_name_, 'C_Swift_Payment_API', 'CRUD_Update__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Update__ (Base)', 'etag_', etag_, 'id_', id_, 'attr_', attr_, 'action$_', action$_, 'c_swift_payment##', c_swift_payment##);
   END IF;
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Update__');
   ret_.etag := etag_;
   ret_.attr := attr_;
   key_temp_.id := id_;
   IF (action$_ = 'DO') THEN
      Get_Objid_Objversion___(objid_, objversion_, key_temp_);
      Security_SYS.Check_Data_Access_For_Update('CSwiftPaymentEntity', 'CSwiftPayment', objid_);
   END IF;
   CRUD_Update___(ret_.etag, key_temp_, ret_.attr, ret_.info, action$_);
   IF (action$_ = 'DO') THEN
      Security_SYS.Check_Data_Access_For_Update('CSwiftPaymentEntity', 'CSwiftPayment', objid_);
   END IF;
   Client_SYS.Set_Item_Value('ID', key_temp_.id, ret_.attr);
   return ret_;
END CRUD_Update__;


--@IgnoreMissingSysinit
FUNCTION CRUD_Upload__(etag_ IN VARCHAR2, id_ IN NUMBER, payment_msg## IN CLOB, c_swift_payment## IN VARCHAR2) RETURN VARCHAR2
IS
   ret_etag_            VARCHAR2(100);
   key_temp_            C_Swift_Payment_Entity_Key;
BEGIN
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Upload__');
   ret_etag_ := etag_;
   key_temp_.id := id_;
   CRUD_Upload___(etag_ => ret_etag_, key_ => key_temp_, payment_msg## => payment_msg##);
   return ret_etag_;
END CRUD_Upload__;


--@IgnoreMissingSysinit
FUNCTION CRUD_Upload__(etag_ IN VARCHAR2, id_ IN NUMBER, response_msg## IN CLOB, c_swift_payment## IN VARCHAR2) RETURN VARCHAR2
IS
   ret_etag_            VARCHAR2(100);
   key_temp_            C_Swift_Payment_Entity_Key;
BEGIN
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Upload__');
   ret_etag_ := etag_;
   key_temp_.id := id_;
   CRUD_Upload___(etag_ => ret_etag_, key_ => key_temp_, response_msg## => response_msg##);
   return ret_etag_;
END CRUD_Upload__;


FUNCTION CRUD_Delete__(etag_ IN VARCHAR2, id_ IN NUMBER, action$_ IN VARCHAR2, c_swift_payment## IN VARCHAR2) RETURN Entity_Dec
IS
   ret_ Entity_Dec;
   key_temp_ C_Swift_Payment_Entity_Key;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   General_SYS.Init_Projection_Method(entity_projection_name_, 'C_Swift_Payment_API', 'CRUD_Delete__');
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Delete__ (Base)', 'etag_', etag_, 'id_', id_, 'action$_', action$_, 'c_swift_payment##', c_swift_payment##);
   END IF;
   Log_SYS.Init_Method('C_Swift_Payment_API', 'CRUD_Delete__');
   ret_.etag := etag_;
   key_temp_.id := id_;
   IF (action$_ = 'DO') THEN
      Get_Objid_Objversion___(objid_, objversion_, key_temp_);
      Security_SYS.Check_Data_Access_For_Delete('CSwiftPaymentEntity', 'CSwiftPayment', objid_);
   END IF;
   CRUD_Delete___(ret_.etag, key_temp_, ret_.info, action$_);
   return ret_;
END CRUD_Delete__;


PROCEDURE Add_To_Attr_From_Rec___ (
   rec_  IN     C_Swift_Payment_Entity_Rec,
   attr_ IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Add_To_Attr_From_Rec___ (Base)', 'rec_', '(C_Swift_Payment_Entity_Rec)', 'attr_', attr_);
   END IF;
   IF (rec_.objgrants IS NOT NULL) THEN
      Client_SYS.Set_Item_Value('OBJGRANTS', rec_.objgrants, attr_);
   END IF;
   IF (rec_.id IS NOT NULL) THEN
      Client_SYS.Set_Item_Value('ID', rec_.id, attr_);
   END IF;
   IF (rec_.msg_id IS NOT NULL) THEN
      Client_SYS.Set_Item_Value('MSG_ID', rec_.msg_id, attr_);
   END IF;
END Add_To_Attr_From_Rec___;


PROCEDURE Add_To_Rec_From_Attr___ (
   attr_ IN     VARCHAR2,
   rec_  IN OUT NOCOPY C_Swift_Payment_Entity_Rec )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Add_To_Rec_From_Attr___ (Base)', 'attr_', attr_, 'rec_', '(C_Swift_Payment_Entity_Rec)');
   END IF;
   IF (Client_SYS.Item_Exist('OBJGRANTS', attr_)) THEN
      rec_.objgrants := Client_SYS.Get_Item_Value('OBJGRANTS', attr_);
   END IF;
   IF (Client_SYS.Item_Exist('ID', attr_)) THEN
      rec_.id := Client_SYS.Get_Item_Value('ID', attr_);
   END IF;
   IF (Client_SYS.Item_Exist('MSG_ID', attr_)) THEN
      rec_.msg_id := Client_SYS.Get_Item_Value('MSG_ID', attr_);
   END IF;
END Add_To_Rec_From_Attr___;


PROCEDURE Get_Objid_Objversion___ (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   key_        IN     C_Swift_Payment_Entity_Key )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Objid_Objversion___ (Base)', 'key_', '(C_Swift_Payment_Entity_Key)');
   END IF;
   SELECT objid, objversion
      INTO  objid_, objversion_
      FROM  C_SWIFT_PAYMENT
      WHERE id = key_.id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      Error_SYS.Odp_Record_Not_Exist(C_Swift_Payment_API.lu_name_);
END Get_Objid_Objversion___;


PROCEDURE CRUD_Default___ (
   key_  IN     C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2 )
IS
   rec_        C_Swift_Payment_Entity_Rec;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Default___ (Base)', 'key_', '(C_Swift_Payment_Entity_Key)', 'attr_', attr_);
   END IF;
   C_Swift_Payment_API.New__(info_, objid_, objversion_, attr_, 'PREPARE');
   Add_To_Rec_From_Attr___(attr_, rec_);
   CRUD_Default___(rec_);
   Add_To_Attr_From_Rec___(rec_, attr_);
END CRUD_Default___;


PROCEDURE CRUD_Default___ (
   rec_  IN OUT NOCOPY C_Swift_Payment_Entity_Rec )
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Default___ (Base)', 'rec_', '(C_Swift_Payment_Entity_Rec)');
   END IF;
   NULL;
END CRUD_Default___;


PROCEDURE CRUD_Create___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN OUT NOCOPY C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 )
IS
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Create___ (Base)', 'etag_', etag_, 'key_', '(C_Swift_Payment_Entity_Key)', 'attr_', attr_, 'action_', action_);
   END IF;
   C_Swift_Payment_API.New__(info_, objid_, objversion_, attr_, action_);
   IF (action_ = 'DO') THEN
   etag_ := Get_Etag___(objid_, objversion_);
   BEGIN
      SELECT id
         INTO key_.id
         FROM C_SWIFT_PAYMENT
         WHERE objid = objid_;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         Error_SYS.Inaccessible_Record_Creation_(C_Swift_Payment_API.lu_name_);
   END;
   END IF;
END CRUD_Create___;


PROCEDURE CRUD_Update___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN OUT NOCOPY C_Swift_Payment_Entity_Key,
   attr_ IN OUT NOCOPY VARCHAR2,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 )
IS
   objid_               VARCHAR2(2000) := Get_Objid_From_Etag___(etag_);
   objversion_          VARCHAR2(2000) := Get_Objversion_From_Etag___(etag_);
   objid_from_key_      VARCHAR2(2000);
   objversion_from_key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Update___ (Base)', 'etag_', etag_, 'key_', '(C_Swift_Payment_Entity_Key)', 'attr_', attr_, 'action_', action_);
   END IF;
   IF (etag_ IS NULL) THEN
      Error_SYS.System_General('ODATA_TO_PLSQL_PROTOCOL: ETag must have a value');
   END IF;
   Get_Objid_Objversion___(objid_from_key_, objversion_from_key_, key_);
   IF (etag_ = '*') THEN
      objid_ := objid_from_key_;
      objversion_ := objversion_from_key_;
   ELSIF (objid_ IS NULL OR objid_from_key_ != objid_) THEN
      Error_SYS.Record_General(lu_name_,'ETAG_INCORRECT: ETag is incorrect');
   END IF;
   C_Swift_Payment_API.Modify__(info_, objid_, objversion_, attr_, action_);
   etag_ := Get_Etag___(objid_, objversion_);
END CRUD_Update___;


PROCEDURE CRUD_Upload___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN C_Swift_Payment_Entity_Key,
   payment_msg##    IN     CLOB)
IS
   objid_               VARCHAR2(2000) := Get_Objid_From_Etag___(etag_);
   objversion_          VARCHAR2(2000) := Get_Objversion_From_Etag___(etag_);
   objid_from_key_      VARCHAR2(2000);
   objversion_from_key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Upload___ (Base)', 'etag_', etag_, 'key_', '(C_Swift_Payment_Entity_Key)', 'payment_msg##', '(CLOB)');
   END IF;
   IF (etag_ IS NULL) THEN
      Error_SYS.System_General('ODATA_TO_PLSQL_PROTOCOL: ETag must have a value');
   END IF;
   Get_Objid_Objversion___(objid_from_key_, objversion_from_key_, key_);
   IF (etag_ = '*') THEN
      objid_ := objid_from_key_;
      objversion_ := objversion_from_key_;
   ELSIF (objid_from_key_ != objid_) THEN
       Error_SYS.Record_General(lu_name_,'ETAG_INCORRECT: ETag is incorrect');
   END IF;
   C_Swift_Payment_API.Write_Payment_Msg__(objversion_, objid_, payment_msg##);
   etag_ := Get_Etag___(objid_, objversion_);
END CRUD_Upload___;


PROCEDURE CRUD_Upload___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN C_Swift_Payment_Entity_Key,
   response_msg##    IN     CLOB)
IS
   objid_               VARCHAR2(2000) := Get_Objid_From_Etag___(etag_);
   objversion_          VARCHAR2(2000) := Get_Objversion_From_Etag___(etag_);
   objid_from_key_      VARCHAR2(2000);
   objversion_from_key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Upload___ (Base)', 'etag_', etag_, 'key_', '(C_Swift_Payment_Entity_Key)', 'response_msg##', '(CLOB)');
   END IF;
   IF (etag_ IS NULL) THEN
      Error_SYS.System_General('ODATA_TO_PLSQL_PROTOCOL: ETag must have a value');
   END IF;
   Get_Objid_Objversion___(objid_from_key_, objversion_from_key_, key_);
   IF (etag_ = '*') THEN
      objid_ := objid_from_key_;
      objversion_ := objversion_from_key_;
   ELSIF (objid_from_key_ != objid_) THEN
       Error_SYS.Record_General(lu_name_,'ETAG_INCORRECT: ETag is incorrect');
   END IF;
   C_Swift_Payment_API.Write_Response_Msg__(objversion_, objid_, response_msg##);
   etag_ := Get_Etag___(objid_, objversion_);
END CRUD_Upload___;


PROCEDURE CRUD_Delete___ (
   etag_ IN OUT NOCOPY VARCHAR2,
   key_  IN     C_Swift_Payment_Entity_Key,
   info_    OUT VARCHAR2,
   action_ IN VARCHAR2 )
IS
   objid_               VARCHAR2(2000) := Get_Objid_From_Etag___(etag_);
   objversion_          VARCHAR2(2000) := Get_Objversion_From_Etag___(etag_);
   objid_from_key_      VARCHAR2(2000);
   objversion_from_key_ VARCHAR2(2000);
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.CRUD_Delete___ (Base)', 'etag_', etag_, 'key_', '(C_Swift_Payment_Entity_Key)', 'action_', action_);
   END IF;
   IF (etag_ IS NULL) THEN
      Error_SYS.System_General('ODATA_TO_PLSQL_PROTOCOL: ETag must have a value');
   END IF;
   Get_Objid_Objversion___(objid_from_key_, objversion_from_key_, key_);
   IF (etag_ = '*') THEN
      objid_ := objid_from_key_;
      objversion_ := objversion_from_key_;
   ELSIF (objid_from_key_ != objid_) THEN
      Error_SYS.Record_General(lu_name_,'ETAG_INCORRECT: ETag is incorrect');
   END IF;
   C_Swift_Payment_API.Remove__(info_, objid_, objversion_, action_);
   etag_ := NULL;
END CRUD_Delete___;

-----------------------------------------------------------------------------
-------------------- HELPER METHODS -----------------------------------------
-----------------------------------------------------------------------------

FUNCTION Get_Objid_From_Etag___ (
   etag_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   delim_pos_ INTEGER := instr(etag_, ':');
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Objid_From_Etag___ (Base)', 'etag_', etag_);
   END IF;
   RETURN substr(etag_, 4, delim_pos_-4);
END Get_Objid_From_Etag___;


FUNCTION Get_Objversion_From_Etag___ (
   etag_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   delim_pos_ INTEGER := instr(etag_, ':');
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Objversion_From_Etag___ (Base)', 'etag_', etag_);
   END IF;
   RETURN substr(etag_, delim_pos_+1, length(etag_)-delim_pos_-1);
END Get_Objversion_From_Etag___;


FUNCTION Get_Etag___ (
   objid_      IN VARCHAR2,
   objversion_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Get_Etag___ (Base)', 'objid_', objid_, 'objversion_', objversion_);
   END IF;
   RETURN 'W/"'||objid_||':'||objversion_||'"';
END Get_Etag___;


FUNCTION Combine_Value_Unit___ (
   value_ IN VARCHAR2,
   unit_  IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.Combine_Value_Unit___ (Base)', 'value_', value_, 'unit_', unit_);
   END IF;
   IF (value_ IS NULL) THEN
      RETURN NULL;
   ELSE
      RETURN value_||'|'||unit_;
   END IF;
END Combine_Value_Unit___;

-----------------------------------------------------------------------------
-------------------- CONVERSION METHODS -------------------------------------
-----------------------------------------------------------------------------

FUNCTION To_Boolean_Arr____ (
   arr_ IN Text_Arr ) RETURN Boolean_Arr
IS
   ret_ Boolean_Arr := Boolean_Arr();
BEGIN
   IF (Log_SYS.extended_trace_enabled_) THEN
      Log_SYS.Put_Method_Trace('C_Swift_Payment_API.To_Boolean_Arr____ (Base)', 'arr_', '(Text_Arr)');
   END IF;
   IF (arr_.count > 0) THEN
      FOR i IN arr_.first .. arr_.last LOOP
      ret_.extend;
      ret_(ret_.last) := Fndcg_Projection_Svc_Util_API.To_Boolean(arr_(i));
      END LOOP;
   END IF;
   RETURN ret_;
END To_Boolean_Arr____;


BEGIN
   Init;
END C_Swift_Payment_API;
/
