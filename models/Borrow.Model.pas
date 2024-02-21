unit Borrow.Model;

interface

uses
    Data.DB,
    FireDAC.Comp.Client,
    FireDAC.Stan.Param,
    System.SysUtils,
    Connection.model,
    System.DateUtils;

type
    TBorrow = class
    private
        FID_BORROW      : Integer;
        FID_EQUIPMENT   : Integer;
        FID_CUSTOMER    : Integer;
        FID_WORKER      : Integer;
        FREQUESTER_NAME : String;
        FBORROW_DATE    : String;
        FRETURN_DATE    : String;
        FBORROW_REASON  : String;
        FWAS_RETURNED   : String;

    public
        // Properties to access class members...
        property ID_BORROW      : Integer read FID_BORROW      write FID_BORROW;
        property ID_EQUIPMENT   : Integer read FID_EQUIPMENT   write FID_EQUIPMENT;
        property ID_CUSTOMER    : Integer read FID_CUSTOMER    write FID_CUSTOMER;
        property ID_WORKER      : Integer read FID_WORKER      write FID_WORKER;
        property REQUESTER_NAME : String  read FREQUESTER_NAME write FREQUESTER_NAME;
        property BORROW_DATE    : String  read FBORROW_DATE    write FBORROW_DATE;
        property RETURN_DATE    : String  read FRETURN_DATE    write FRETURN_DATE;
        property BORROW_REASON  : String  read FBORROW_REASON  write FBORROW_REASON;
        property WAS_RETURNED   : String  read FWAS_RETURNED   write FWAS_RETURNED;

        // Constructor and Destructor...
        constructor Create;
        destructor Destroy;

        // Methods for CRUD operations...
        function List_Borrows(order_by : String; out error : String) : TFDQuery;
        function Add_Borrow(out error : String) : Boolean;
        function Update_Borrow(out error : String) : TFDQuery;
        function Delete_Borrow(out error : String) : Boolean;
    end;

implementation

{ TBorrow }

// Constructor initializes the database connection...
constructor TBorrow.Create;
begin
    Connection.model.Connect;
end;

// Destructor disconnects from the database...
destructor TBorrow.Destroy;
begin
    Connection.model.Disconnect;
end;

// Method to retrieve a list of all or a specific borrow order from the database...
function TBorrow.List_Borrows(order_by: string; out error: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.SQL.Clear;
        qry.Active := false;

        // Build a SQL query to get all saved borrow order...
        qry.SQL.Add('SELECT * FROM borrowing');

        if ID_BORROW > 0 then
        begin
            qry.SQL.Add(' WHERE id_borrowing = :ID_BORROW');
            qry.ParamByName('ID_BORROW').Value := ID_BORROW;
        end;

        if order_by <> '' then
            qry.SQL.Add(' ORDER BY ' + order_by)
        else
            qry.SQL.Add(' ORDER BY id_borrowing DESC');

        qry.Active := true;

        Result := qry;
        error := '';

    except on ex:exception do
        begin
            // Handle errors and provide an error message...
            error := 'Error when consulting borrow orders from the database: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to add a new borrow order to the database...
function TBorrow.Add_Borrow(out error : String) : Boolean;
var
    qry : TFDQuery;
begin
    // Valid input data...
    if ID_EQUIPMENT < 1 then
    begin
        error := 'Enter the borrowed equipment';
        exit;
    end;

    if ID_CUSTOMER < 1 then
    begin
        error := 'Enter the customer';
        exit;
    end;

    if ID_WORKER < 1 then
    begin
        error := 'Enter the worker';
        exit;
    end;

    if (REQUESTER_NAME.IsEmpty) or (length(REQUESTER_NAME) < 3) then
    begin
        error := 'Enter a valid name of the applicant';
        exit;
    end;

    if BORROW_DATE.IsEmpty then
    begin
        error := 'Enter a valid borrow date';
        exit;
    end;

    if (BORROW_REASON.IsEmpty) or (length(BORROW_REASON) < 3) then
    begin
        error := 'Enter the borrow reason';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;
        qry.Params.Clear;

        // Build a SQL query for inserting new borrow order...
        qry.SQL.Add('INSERT INTO borrowing(id_equipment, id_customer, id_worker,');
        qry.SQL.Add(' requester_name, borrow_date, borrow_reason)');
        qry.SQL.Add(' VALUES (:ID_EQUIPMENT, :ID_CUSTOMER, :ID_WORKER,');
        qry.SQL.Add(' :REQUESTER_NAME, :BORROW_DATE, :BORROW_REASON)');

        qry.ParamByName('ID_EQUIPMENT').Value   := ID_EQUIPMENT;
        qry.ParamByName('ID_CUSTOMER').Value    := ID_CUSTOMER;
        qry.ParamByName('ID_WORKER').Value      := ID_WORKER;
        qry.ParamByName('REQUESTER_NAME').Value := REQUESTER_NAME;
        qry.ParamByName('BORROW_DATE').Value    := StrToDateTime(BORROW_DATE);
        qry.ParamByName('BORROW_REASON').Value  := BORROW_REASON;

        qry.ExecSQL;
        qry.SQL.Clear;

        // Retrieve the ID of the newly inserted borrow order...
        qry.SQL.Add('SELECT MAX(id_borrowing) AS ID_BORROW FROM borrowing');
        qry.SQL.Add(' WHERE id_equipment = :ID_EQUIPMENT');
        qry.ParamByName('ID_EQUIPMENT').Value := ID_EQUIPMENT;
        qry.Active := true;

        ID_BORROW := qry.FieldByName('ID_BORROW').AsInteger;

        qry.Free;
        Result := true;
        error := '';

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when registering a borrow order: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Method to update an existing borrow order from the database...
function TBorrow.Update_Borrow(out error : String) : TFDQuery;
var
    qry : TFDQuery;
begin
    // Valid input data...
    if ID_EQUIPMENT < 1 then
    begin
        error := 'Enter an equipment';
        exit;
    end;

    if ID_CUSTOMER < 1 then
    begin
        error := 'Enter a customer';
        exit;
    end;

    if ID_WORKER < 1 then
    begin
        error := 'Enter a worker';
        exit;
    end;

    if (REQUESTER_NAME.IsEmpty) or (length(REQUESTER_NAME) < 3) then
    begin
        error := 'Enter a requester name';
        exit;
    end;

    if BORROW_DATE.IsEmpty then
    begin
        error := 'Enter a borrow date';
        exit;
    end;

    if (BORROW_REASON.IsEmpty) or (length(BORROW_REASON) < 3) then
    begin
        error := 'Enter a borrow reason';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;
        qry.Params.Clear;

        // Build a SQL query to edit an existing borrow order...
        qry.SQL.Add('UPDATE borrowing SET id_customer = :ID_CUSTOMER,');
        qry.SQL.Add(' id_worker = :ID_WORKER, id_equipment = :ID_EQUIPMENT,');
        qry.SQL.Add(' requester_name = :REQUESTER_NAME, borrow_date = :BORROW_DATE,');
        qry.SQL.Add(' return_date = :RETURN_DATE, borrow_reason = :BORROW_REASON,');
        qry.SQL.Add(' was_returned = :WAS_RETURNED');
        qry.SQL.Add( 'WHERE id_borrowing = :ID_BORROW');

        qry.ParamByName('ID_CUSTOMER').Value    := ID_CUSTOMER;
        qry.ParamByName('ID_WORKER').Value      := ID_WORKER;
        qry.ParamByName('ID_EQUIPMENT').Value   := ID_EQUIPMENT;
        qry.ParamByName('REQUESTER_NAME').Value := REQUESTER_NAME;
        qry.ParamByName('BORROW_DATE').Value    := StrToDateTime(BORROW_DATE);
        qry.ParamByName('RETURN_DATE').Value    := StrToDateTime(RETURN_DATE);
        qry.ParamByName('BORROW_REASON').Value  := BORROW_REASON;
        qry.ParamByName('WAS_RETURNED').Value   := WAS_RETURNED;
        qry.ParamByName('ID_BORROW').Value      := ID_BORROW;

        qry.ExecSQL;
        qry.SQL.Clear;
        qry.Params.Clear;

        qry.SQL.Add('SELECT * FROM borrowing WHERE id_borrowing = :ID_BORROW');
        qry.ParamByName('ID_BORROW').Value := ID_BORROW;
        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            error := 'Error when editing the borrow order: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to delete an existing borrow order from the database...
function TBorrow.Delete_Borrow(out error : String) : Boolean;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;
        qry.Params.Clear;

        // Build a SQL query to delete a borrow order...
        qry.SQL.Add('DELETE FROM borrowing WHERE id_borrowing = :ID_BORROW');
        qry.ParamByName('ID_BORROW').Value := ID_BORROW;

        qry.ExecSQL;

        qry.Free;
        error := '';
        Result := true;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when deleting the borrow order: ' + ex.Message;
            Result := false;
        end;
    end;
end;

end.
