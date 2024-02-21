unit Customer.Model;

interface

uses
    System.SysUtils,
    Data.DB,
    Connection.Model,
    FireDAC.Comp.Client,
    FireDAC.Stan.Param;

type
    TCustomer = class
    private
        FID_CUSTOMER   : Integer;
        FNAME          : String;
        FADDRESS       : String;
        FNEIGHBOURHOOD : String;
        FCITY          : String;
        FTELEPHONE     : String;
        FPHONE         : String;
        FIS_ACTIVE     : String;

    public

        // Properties for accessing private fields...
        property ID_CUSTOMER   : Integer read FID_CUSTOMER   write FID_CUSTOMER;
        property NAME          : String  read FNAME          write FNAME;
        property ADDRESS       : String  read FADDRESS       write FADDRESS;
        property NEIGHBOURHOOD : String  read FNEIGHBOURHOOD write FNEIGHBOURHOOD;
        property CITY          : String  read FCITY          write FCITY;
        property TELEPHONE     : String  read FTELEPHONE     write FTELEPHONE;
        property PHONE         : String  read FPHONE         write FPHONE;
        property IS_ACTIVE     : String  read FIS_ACTIVE     write FIS_ACTIVE;

        // Constructor and destructor...
        constructor Create;
        destructor Destroy; override;

        // Methods for CRUD operations...
        function List_Customers(order_by : String; out error : String) : TFDQuery;
        function Add_Customer(out error : String) : Boolean;
        function Update_Custome(out error : String) : TFDQuery;
        function Delete_Customer(out error : String) : Boolean;
end;

implementation

{ TCustomer }

// Constructor initializes the database connection...
constructor TCustomer.Create;
begin
    Connection.Model.Connect;
end;

// Destructor disconnects from the database...
destructor TCustomer.Destroy;
begin
    Connection.Model.Disconnect;
    inherited;
end;

// Method to retrieve a list of all or a specific customer from the database...
function TCustomer.List_Customers(order_by: String; out error: String): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query to get all saved customers...
        qry.SQL.Add('SELECT * FROM customer');

        if ID_CUSTOMER > 0 then
        begin
            qry.SQL.Add(' WHERE id_customer = :ID_CUSTOMER');
            qry.ParamByName('ID_CUSTOMER').Value := ID_CUSTOMER;
        end;

        if order_by <> '' then
            qry.SQL.Add(' ORDER BY ' + order_by)
        else
            qry.SQL.Add(' ORDER BY name_customer');

        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when consulting customers from the database: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to add a new customer to the database...
function TCustomer.Add_Customer(out error: String): Boolean;
var
    qry : TFDQuery;
begin

    // Validate input data...
    if (NAME.IsEmpty) OR (length(NAME) < 3) then
    begin
        error := 'Enter the customer''s name';
        exit;
    end;

    if (ADDRESS.IsEmpty) or (length(ADDRESS) < 3) then
    begin
        error := 'Enter the customer''s address';
        exit;
    end;

    if (NEIGHBOURHOOD.isEmpty) or (length(NEIGHBOURHOOD) < 3) then
    begin
        error := 'Enter the customer''s neighborhood';
        exit;
    end;

    if (CITY.isEmpty) or (length(CITY) < 3) then
    begin
        error := 'Enter the customer''s city';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for inserting a new customer...
        qry.SQL.Add('INSERT INTO customer(name_customer, address_customer,');
        qry.SQL.Add(' neighbourhood_customer, city_customer,');
        qry.SQL.Add(' telephone_customer, phone_customer)');
        qry.SQL.Add(' VALUES (:NAME, :ADDRESS, :NEIGHBOURHOOD, :CITY,');
        qry.SQL.Add(' :TELEPHONE, :PHONE)');

        qry.ParamByName('NAME').Value          := NAME;
        qry.ParamByName('ADDRESS').Value       := ADDRESS;
        qry.ParamByName('NEIGHBOURHOOD').Value := NEIGHBOURHOOD;
        qry.ParamByName('CITY').Value          := CITY;
        qry.ParamByName('TELEPHONE').Value     := TELEPHONE;
        qry.ParamByName('PHONE').Value         := PHONE;

        qry.ExecSQL;

        qry.Params.Clear;
        qry.SQL.Clear;

        // Retrieve the ID of the newly inserted customer...
        qry.SQL.Add('SELECT MAX(id_customer) AS ID_CUSTOMER FROM customer');
        qry.SQL.Add(' WHERE name_customer = :NAME');
        qry.ParamByName('NAME').Value := NAME;

        qry.Active := true;

        ID_CUSTOMER := qry.FieldByName('ID_CUSTOMER').AsInteger;

        qry.Free;
        error := '';
        Result := True;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when registering the customer: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Method to update an existing customer from the database...
function TCustomer.Update_Custome(out error: String): TFDQuery;
var
    qry : TFDQuery;
begin

    // Validate input data...
    if (NAME.IsEmpty) OR (length(NAME) < 3) then
    begin
        error := 'Enter the customer''s name';
        exit;
    end;

    if (ADDRESS.IsEmpty) or (length(ADDRESS) < 3) then
    begin
        error := 'Enter the customer''s address';
        exit;
    end;

    if (NEIGHBOURHOOD.isEmpty) or (length(NEIGHBOURHOOD) < 3) then
    begin
        error := 'Enter the customer''s neighbourhood';
        exit;
    end;

    if (CITY.isEmpty) or (length(CITY) < 3) then
    begin
        error := 'Enter the customer''s city';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for updating an existing customer...
        qry.SQL.Add('UPDATE customer SET name_customer = :NAME,');
        qry.SQL.Add(' address_customer = :ADDRESS,');
        qry.SQL.Add(' neighbourhood_customer = :NEIGHBOURHOOD,');
        qry.SQL.Add(' city_customer = :CITY,');
        qry.SQL.Add(' telephone_customer = :TELEPHONE,');
        qry.SQL.Add(' phone_customer = :PHONE,');
        qry.SQL.Add(' is_active = :IS_ACTIVE');
        qry.SQL.Add(' WHERE id_customer = :ID_CUSTOMER');

        qry.ParamByName('NAME').Value          := NAME;
        qry.ParamByName('ADDRESS').Value       := ADDRESS;
        qry.ParamByName('NEIGHBOURHOOD').Value := NEIGHBOURHOOD;
        qry.ParamByName('CITY').Value          := CITY;
        qry.ParamByName('TELEPHONE').Value     := TELEPHONE;
        qry.ParamByName('PHONE').Value         := PHONE;
        qry.ParamByName('IS_ACTIVE').Value     := IS_ACTIVE;
        qry.ParamByName('ID_CUSTOMER').Value   := ID_CUSTOMER;

        qry.ExecSQL;

        qry.SQL.Clear;
        qry.Params.Clear;

        qry.SQL.Add('SELECT * FROM customer WHERE id_customer = :ID_CUSTOMER');
        qry.ParamByName('ID_CUSTOMER').Value := ID_CUSTOMER;

        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when editing the customer: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to delete a customer from the database...
function TCustomer.Delete_Customer(out error: String): Boolean;
var
    qry : TFDQuery;
begin

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for deleting a customer...
        qry.SQL.Add('DELETE FROM customer WHERE id_customer = :ID_CUSTOMER');
        qry.ParamByName('ID_CUSTOMER').Value := ID_CUSTOMER;

        qry.ExecSQL;

        qry.Free;
        error := '';
        Result := true;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when deleting the customer: ' + ex.Message;
            Result := false;
        end;
    end;
end;

end.
