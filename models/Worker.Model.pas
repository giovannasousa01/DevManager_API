unit Worker.Model;

interface

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Connection.Model;

type
  TWorker = class
  private
    FID_WORKER: Integer;
    FNAME: String;
    FPASSWORD: String;
    FIS_ACTIVE: String;

  public

    // Properties to access class members...
    property ID_WORKER: Integer read FID_WORKER write FID_WORKER;
    property NAME: String read FNAME write FNAME;
    property PASSWORD: String read FPASSWORD write FPASSWORD;
    property IS_ACTIVE: String read FIS_ACTIVE write FIS_ACTIVE;

    // Constructor and destructor...
    constructor Create;
    destructor Destroy; override;

    // Methods for CRUD operations...
    function List_Workers(order_by: String; out error: String): TFDQuery;
    function Add_Worker(out error: String): Boolean;
    function Update_Worker(out error: String): Boolean;
    function Delete_Worker(out error: String): Boolean;
  end;

implementation

{ TWorker }

// Constructor initializes the database connection...
constructor TWorker.Create;
begin
    Connection.Model.Connect;
end;

// Destructor disconnects from the database...
destructor TWorker.Destroy;
begin
    Connection.Model.Disconnect;
    inherited;
end;

// Method to retrieve a list of all or a specific worker from the database...
function TWorker.List_Workers(order_by: String; out error: String): TFDQuery;
var
    qry: TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query based on parameters...
        qry.SQL.Add('SELECT * FROM worker');

        if ID_WORKER > 0 then
        begin
            qry.SQL.Add(' WHERE id_worker = :ID_WORKER');
            qry.ParamByName('ID_WORKER').Value := ID_WORKER;
        end;

        if order_by <> '' then
            qry.SQL.Add(' ORDER BY ' + order_by)
        else
            qry.SQL.Add(' ORDER BY name_worker');

        qry.Active := true;

        error := '';
        Result := qry;

    except on ex: exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when consulting employees: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to add a new customer to the database...
function TWorker.Add_Worker(out error: String): Boolean;
var
    qry: TFDQuery;
begin
    // Validate input data...
    if NAME.IsEmpty then
    begin
        Result := false;
        error := 'Enter the employee''s name';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for inserting a new worker...
        qry.SQL.Add('INSERT INTO worker(name_worker, password_worker)');
        qry.SQL.Add(' VALUES(:NAME, :PASSWORD)');
        qry.ParamByName('NAME').Value := NAME;
        qry.ParamByName('PASSWORD').Value := PASSWORD;

        qry.ExecSQL;

        // Retrieve the ID of the newly inserted customer...
        qry.Params.Clear;
        qry.SQL.Clear;
        qry.SQL.Add('SELECT MAX(id_worker) AS ID_WORKER FROM worker');
        qry.SQL.Add(' WHERE name_worker = :NAME');
        qry.ParamByName('NAME').Value := NAME;
        qry.Active := true;

        ID_WORKER := qry.FieldByName('ID_WORKER').AsInteger;

        qry.Free;
        error := '';
        Result := true;

    except on ex: exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when registering an employee: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Function to update an existing worker...
function TWorker.Update_Worker(out error: String): Boolean;
var
    qry: TFDQuery;
begin

    // Validate input data...
    if NAME.IsEmpty then
    begin
        Result := false;
        error := 'Enter the employee''s name';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query for updating an existing customer...
        qry.SQL.Add('UPDATE worker SET name_worker = :NAME,');
        qry.SQL.Add(' password_worker = :PASSWORD, is_active = :IS_ACTIVE');
        qry.SQL.Add(' WHERE id_worker = :ID_WORKER');
        qry.ParamByName('NAME').Value := NAME;
        qry.ParamByName('PASSWORD').Value := PASSWORD;
        qry.ParamByName('IS_ACTIVE').Value := IS_ACTIVE;
        qry.ParamByName('ID_WORKER').Value := ID_WORKER;

        qry.ExecSQL;

        qry.Free;
        error := '';
        Result := true;

    except on ex: exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error editing employee: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Method to delete a customer from the database...
function TWorker.Delete_Worker(out error: String): Boolean;
var
    qry: TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.Model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query based on parameters...
        qry.SQL.Add('DELETE FROM worker WHERE id_worker = :ID_WORKER');
        qry.ParamByName('ID_WORKER').Value := ID_WORKER;

        qry.ExecSQL;

        qry.Free;
        error := '';
        Result := true;

    except on ex: exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error deleting employee: ' + ex.Message;
            Result := false;
        end;
    end;
end;

end.
