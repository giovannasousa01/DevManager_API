unit Repair.Model;

interface

uses
    Data.DB,
    Connection.model,
    System.SysUtils,
    System.DateUtils,
    FireDAC.Comp.Client,
    FireDAC.Stan.Param;

type
    TRepair = class
    private
        FID_REPAIR             : Integer;
        FID_CUSTOMER           : Integer;
        FID_WORKER             : Integer;
        FTYPE_EQUIPMENT        : String;
        FDESCRIPTION_EQUIPMENT : String;
        FREQUESTER_NAME        : String;
        FENTRY_DATE            : String;
        FDELIVERY_DATE         : String;
        FREPAIR_REASON         : String;
        FREPAIR_COMPLETED      : String;
        FWAS_DELIVERED         : String;

    public
        // Properties to access class members...
        property ID_REPAIR             : Integer read FID_REPAIR             write FID_REPAIR;
        property ID_CUSTOMER           : Integer read FID_CUSTOMER           write FID_CUSTOMER;
        property ID_WORKER             : Integer read FID_WORKER             write FID_WORKER;
        property TYPE_EQUIPMENT        : String  read FTYPE_EQUIPMENT        write FTYPE_EQUIPMENT;
        property DESCRIPTION_EQUIPMENT : String  read FDESCRIPTION_EQUIPMENT write FDESCRIPTION_EQUIPMENT;
        property REQUESTER_NAME        : String  read FREQUESTER_NAME        write FREQUESTER_NAME;
        property ENTRY_DATE            : String  read FENTRY_DATE            write FENTRY_DATE;
        property DELIVERY_DATE         : String  read FDELIVERY_DATE         write FDELIVERY_DATE;
        property REPAIR_REASON         : String  read FREPAIR_REASON         write FREPAIR_REASON;
        property REPAIR_COMPLETED      : String  read FREPAIR_COMPLETED      write FREPAIR_COMPLETED;
        property WAS_DELIVERED         : String  read FWAS_DELIVERED         write FWAS_DELIVERED;

        // Constructor and destructor...
        constructor Create;
        destructor Destroy;

        // Methods for CRUD operations...
        function List_Repairs(order_by : String; out error : String) : TFDQuery;
        function Add_Repair(out error : String) : Boolean;
        function Update_Repair(out error : String) : TFDQuery;
        function Delete_Repair(out error : String) : Boolean;

    end;

implementation

{ TRepair }

// Constructor initializes the database connection...
constructor TRepair.Create;
begin
    Connection.model.Connect;
end;

// Destructor disconnects from the database...
destructor TRepair.Destroy;
begin
    Connection.model.Disconnect;
end;

// Method to retrieve a list of all or a specific repair order from the database...
function TRepair.List_Repairs(order_by: String; out error: String): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query to get all saved repair orders...
        qry.SQL.Add('SELECT * FROM repair');

        if ID_REPAIR > 0 then
        begin
            qry.SQL.Add(' WHERE id_repair = :ID_REPAIR');
            qry.ParamByName('ID_REPAIR').Value := ID_REPAIR;
        end;

        if order_by <> '' then
            qry.SQL.Add(' ORDER BY ' + order_by)
        else
            qry.SQL.Add(' ORDER BY entry_date');

        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when consulting repair orders from the database: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to add a new repair order to the database...
function TRepair.Add_Repair(out error: String): Boolean;
var
    qry : TFDQuery;
begin

    // Valid input data...
    if ID_CUSTOMER < 1 then
    begin
        error := 'Enter a valid customer';
        exit;
    end;

    if ID_WORKER < 1 then
    begin
        error := 'Enter a valid worker';
        exit;
    end;

    if (TYPE_EQUIPMENT.IsEmpty) or (Length(TYPE_EQUIPMENT) < 3)  then
    begin
        error := 'Enter a valid equipment''s type';
        exit;
    end;

    if (DESCRIPTION_EQUIPMENT.IsEmpty) or (Length(DESCRIPTION_EQUIPMENT) < 3) then
    begin
        error := 'Enter a valid equipment''s description';
        exit;
    end;

    if (REQUESTER_NAME.IsEmpty) or (Length(REQUESTER_NAME) < 3) then
    begin
        error := 'Enter a valid name of the applicant';
        exit;
    end;

    if ENTRY_DATE = '' then
    begin
        error := 'Enter a valid entry date';
        exit;
    end;

    if (REPAIR_REASON.IsEmpty) or (Length(REPAIR_REASON) < 3) then
    begin
        error := 'Enter the reason for the repair';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for inserting new repair order...
        qry.SQL.Add('INSERT INTO repair(id_customer, id_worker, type_equipment,');
        qry.SQL.Add(' description_equipment, requester_name, entry_date, repair_reason)');
        qry.SQL.Add(' VALUES (:ID_CUSTOMER, :ID_WORKER, :TYPE_EQUIPMENT,');
        qry.SQL.Add(' :DESCRIPTION_EQUIPMENT, :REQUESTER_NAME,');
        qry.SQL.Add(' :ENTRY_DATE, :REPAIR_REASON)');

        qry.ParamByName('ID_CUSTOMER').Value           := ID_CUSTOMER;
        qry.ParamByName('ID_WORKER').Value             := ID_WORKER;
        qry.ParamByName('TYPE_EQUIPMENT').Value        := TYPE_EQUIPMENT;
        qry.ParamByName('DESCRIPTION_EQUIPMENT').Value := DESCRIPTION_EQUIPMENT;
        qry.ParamByName('REQUESTER_NAME').Value        := REQUESTER_NAME;
        qry.ParamByName('ENTRY_DATE').Value            := StrToDateTime(ENTRY_DATE);
        qry.ParamByName('REPAIR_REASON').Value         := REPAIR_REASON;

        qry.ExecSQL;

        qry.SQL.Clear;
        qry.Params.Clear;

        // Retrieve the ID of the newly inserted repair order...
        qry.SQL.Add('SELECT MAX(id_repair) AS ID_REPAIR FROM repair');
        qry.SQL.Add(' WHERE description_equipment = :DESCRIPTION_EQUIPMENT');
        qry.ParamByName('DESCRIPTION_EQUIPMENT').Value := DESCRIPTION_EQUIPMENT;
        qry.Active := true;

        ID_REPAIR := qry.FieldByName('ID_REPAIR').AsInteger;

        qry.Free;
        error := '';
        Result := true;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when registering a repair order: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Method to update an existing repair order from the database...
function TRepair.Update_Repair(out error: String): TFDQuery;
var
    qry : TFDQuery;
begin
    // Valid input data...
    if ID_CUSTOMER < 1 then
    begin
        error := 'Enter a valid customer';
        exit;
    end;

    if ID_WORKER < 1 then
    begin
        error := 'Enter a valid worker';
        exit;
    end;

    if (TYPE_EQUIPMENT.IsEmpty) or (Length(TYPE_EQUIPMENT) < 3)  then
    begin
        error := 'Enter a valid equipment''s type';
        exit;
    end;

    if (DESCRIPTION_EQUIPMENT.IsEmpty) or (Length(DESCRIPTION_EQUIPMENT) < 3) then
    begin
        error := 'Enter a valid equipment''s description';
        exit;
    end;

    if (REQUESTER_NAME.IsEmpty) or (Length(REQUESTER_NAME) < 3) then
    begin
        error := 'Enter a valid name of the requestor';
        exit;
    end;

    if ENTRY_DATE = '' then
    begin
        error := 'Enter the entry date';
        exit;
    end;

    if (REPAIR_REASON.IsEmpty) or (Length(REPAIR_REASON) < 3) then
    begin
        error := 'Enter the reason for the repair';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query to update repair order's information...
        qry.SQL.Add('UPDATE repair SET id_customer = :ID_CUSTOMER, id_worker = :ID_WORKER,');
        qry.SQL.Add(' type_equipment = :TYPE_EQUIPMENT,');
        qry.SQL.Add(' description_equipment = :DESCRIPTION_EQUIPMENT,');
        qry.SQL.Add(' requester_name = :REQUESTER_NAME,');
        qry.SQL.Add(' entry_date = :ENTRY_DATE,');
        qry.SQL.Add(' delivery_date = :DELIVERY_DATE,');
        qry.SQL.Add(' repair_reason = :REPAIR_REASON,');
        qry.SQL.Add(' repair_completed = :REPAIR_COMPLETED,');
        qry.SQL.Add(' was_delivered = :WAS_DELIVERED');
        qry.SQL.Add(' WHERE id_repair = :ID_REPAIR');

        qry.ParamByName('ID_CUSTOMER').Value           := ID_CUSTOMER;
        qry.ParamByName('ID_WORKER').Value             := ID_WORKER;
        qry.ParamByName('TYPE_EQUIPMENT').Value        := TYPE_EQUIPMENT;
        qry.ParamByName('DESCRIPTION_EQUIPMENT').Value := DESCRIPTION_EQUIPMENT;
        qry.ParamByName('REQUESTER_NAME').Value        := REQUESTER_NAME;
        qry.ParamByName('ENTRY_DATE').Value            := StrToDateTime(ENTRY_DATE);
        qry.ParamByName('DELIVERY_DATE').Value         := StrToDateTime(DELIVERY_DATE);
        qry.ParamByName('REPAIR_REASON').Value         := REPAIR_REASON;
        qry.ParamByName('REPAIR_COMPLETED').Value      := REPAIR_COMPLETED;
        qry.ParamByName('WAS_DELIVERED').Value         := WAS_DELIVERED;
        qry.ParamByName('ID_REPAIR').Value             := ID_REPAIR;

        qry.ExecSQL;

        qry.SQL.Clear;

        qry.SQL.Add('SELECT * FROM repair WHERE id_repair = :ID_REPAIR');
        qry.ParamByName('ID_REPAIR').Value := ID_REPAIR;
        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when editing repair order: ' + error;
            Result := nil;
        end;
    end;
end;

// Method to delete an existing repair order from the database...
function TRepair.Delete_Repair(out error: String): Boolean;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query to delete a repair order from the database...
        qry.SQL.Add('DELETE FROM repair WHERE id_repair = :ID_REPAIR');
        qry.ParamByName('ID_REPAIR').Value := ID_REPAIR;

        qry.ExecSQL;

        qry.Free;
        error := '';
        Result := true;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when deleting the repair order: ' + error;
            Result := true;
        end;
    end;
end;

end.
