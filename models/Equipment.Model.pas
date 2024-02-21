unit Equipment.Model;

interface

uses
    Connection.model,
    System.SysUtils,
    Data.DB,
    FireDAC.Comp.Client,
    FireDAC.Stan.Param;

type
    TEquipment = class
    private
        FID_EQUIPMENT : INTEGER;
        FNAME         : STRING;
        FDESCRIPTION  : STRING;
        FIS_BORROWED  : STRING;
        FIS_ACTIVE    : STRING;

    public

        // Properties for accessing private fields...
        property ID_EQUIPMENT : Integer read FID_EQUIPMENT write FID_EQUIPMENT;
        property NAME         : String  read FNAME         write FNAME;
        property DESCRIPTION  : String  read FDESCRIPTION  write FDESCRIPTION;
        property IS_BORROWED  : String  read FIS_BORROWED  write FIS_BORROWED;
        property IS_ACTIVE    : String  read FIS_ACTIVE    write FIS_ACTIVE;

        // Contructor and destructor...
        constructor Create;
        destructor Destroy; override;

        // Methods for CRUD operations...
        function List_Equipments(order_by : String; out error : String) : TFDQuery;
        function Add_Equipment(out error : String) : Boolean;
        function Update_Equipment(out error : String) : TFDQuery;
        function Delete_Equipment(out error : String) : Boolean;

    end;

implementation

{ TEquipment }

// Constructor initializes the database connection...
constructor TEquipment.Create;
begin
    Connection.model.Connect;
end;

// Destructor disconnects from the database...
destructor TEquipment.Destroy;
begin
    Connection.model.Disconnect;
    inherited;
end;

// Method to retrieve a list of all or a specific equipment from the database...
function TEquipment.List_Equipments(order_by : String; out error : String): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Build SQL query to get all saved equipments...
        qry.SQL.Add('SELECT * FROM equipment');

        if ID_EQUIPMENT > 0 then
        begin
            qry.SQL.Add(' WHERE id_equipment = :ID_EQUIPMENT');
            qry.ParamByName('ID_EQUIPMENT').Value := ID_EQUIPMENT;
        end;

        if order_by <> '' then
            qry.SQL.Add(' order by ' + order_by)
        else
            qry.SQL.Add(' order by name_equipment');

        qry.Active := true;

        error := '';
        Result := qry

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when consulting equipments from the database: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to add a new equipment to the database...
function TEquipment.Add_Equipment(out error : String): Boolean;
var
    qry : TFDQuery;
begin

    if (NAME.IsEmpty) or (length(NAME) < 3) then
    begin
        error := 'Enter the equipment''s name';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Configure SQL for inserting a new equipment...
        qry.SQL.Add('INSERT INTO equipment(name_equipment, description_equipment)');
        qry.SQL.Add(' VALUES (:NAME, :DESCRIPTION)');

        qry.ParamByName('NAME').Value        := NAME;
        qry.ParamByName('DESCRIPTION').Value := DESCRIPTION;

        qry.ExecSQL;

        qry.Params.Clear;
        qry.SQL.Clear;

        // Retrieve the ID of the newly inserted equipment...
        qry.SQL.Add('SELECT MAX(id_equipment) AS ID_EQUIPMENT FROM equipment');
        qry.SQL.Add(' WHERE name_equipment = :NAME');
        qry.ParamByName('NAME').Value := NAME;

        qry.Active := true;

        ID_EQUIPMENT := qry.FieldByName('ID_EQUIPMENT').AsInteger;

        qry.Free;
        error := '';
        Result := true;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when registering equipment: ' + ex.Message;
            Result := false;
        end;
    end;
end;

// Method to update an existing equipment from the database...
function TEquipment.Update_Equipment(out error : String): TFDQuery;
var
    qry : TFDQuery;
begin

    if (NAME.IsEmpty) or (length(NAME) < 3) then
    begin
        error := 'Enter the equipment''s name';
        exit;
    end;

    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Configure SQL query for updating an existing equipment...
        qry.SQL.Add('UPDATE equipment SET name_equipment = :NAME,');
        qry.SQL.Add(' description_equipment = :DESCRIPTION,');
        qry.SQL.Add(' is_borrowed = :IS_BORROWED,');
        qry.SQL.Add(' is_active = :IS_ACTIVE');
        qry.SQL.Add(' WHERE id_equipment = :ID_EQUIPMENT');

        qry.ParamByName('NAME').Value         := NAME;
        qry.ParamByName('DESCRIPTION').Value  := DESCRIPTION;
        qry.ParamByName('IS_BORROWED').Value  := IS_BORROWED;
        qry.ParamByName('IS_ACTIVE').Value    := IS_ACTIVE;
        qry.ParamByName('ID_EQUIPMENT').Value := ID_EQUIPMENT;

        qry.ExecSQL;

        qry.SQL.Clear;
        qry.Params.Clear;

        qry.SQL.Add('SELECT * FROM equipment WHERE id_equipment = :ID_EQUIPMENT');
        qry.ParamByName('ID_EQUIPMENT').Value := ID_EQUIPMENT;

        qry.Active := true;

        error := '';
        Result := qry;

    except on ex:exception do
        begin
            // Handle exceptions and provide an error message...
            error := 'Error when editing the equipment: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

// Method to delete an equipment from the database...
function TEquipment.Delete_Equipment(out error : String): Boolean;
var
    qry : TFDQuery;
begin
    try
        // Create and configure a FireDAC query...
        qry := TFDQuery.Create(nil);
        qry.Connection := Connection.model.FConnection;

        qry.Active := false;
        qry.SQL.Clear;

        // Configure a SQL query to delete an equipment...
        qry.SQL.Add('DELETE FROM equipment WHERE id_equipment = :ID_EQUIPMENT');
        qry.ParamByName('ID_EQUIPMENT').Value := ID_EQUIPMENT;

        qry.ExecSQL;

        qry.Free;

        error := '';
        Result := true;

    except on ex:exception do
        begin
            error := 'Error when deleting the equipment: ' + ex.Message;
            Result := false;
        end;
    end;
end;

end.
