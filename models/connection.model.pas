unit Connection.Model;

interface

uses
    System.SysUtils,
    System.Classes,
    Horse,
    FireDAC.Phys.Intf,
    FireDAC.Phys.PG,
    FireDAC.Phys.PGDef,
    FireDAC.Stan.Option,
    FireDAC.Stan.Intf,
    FireDAC.Stan.Error,
    FireDAC.Stan.Def,
    FireDAC.Stan.Pool,
    FireDAC.Stan.Async,
    FireDAC.Stan.ExprFuncs,
    FireDAC.UI.Intf,
    FireDAC.FMXUI.Wait,
    FireDAC.Comp.Client,
    FireDAC.DApt,
    Data.DB;

var
    FConnection : TFDConnection;

function SetupConnection(FConn : TFDConnection) : String;
function Connect : TFDConnection;
procedure Disconnect;

implementation

// Function to set up the database connection parameters...
function SetupConnection(FConn : TFDConnection) : String;
begin
    try
        FConn.Params.DriverID := 'PG';
        FConn.Params.Database := 'DevManager_API';
        FConn.Params.UserName := 'postgres';
        FConn.Params.Password := '.Punk4ever';
        FConn.Params.Add('Port=5432');
        FConn.Params.Add('Server=localhost');

        Result := 'OK';

    except on ex:exception do
        Result := 'Erro ao configurar o banco de dados: ' + ex.Message;

    end;
end;

// Function to connect to the database...
function Connect : TFDConnection;
begin
    FConnection := TFDConnection.Create(nil);
    SetupConnection(FConnection);
    FConnection.Connected := true;

    Result := FConnection;
end;

// Procedure to disconnect from the database...
procedure Disconnect;
begin
    if Assigned(FConnection) then
    begin
        if FConnection.Connected = true then
            FConnection.Connected := false;

        FConnection.Free;
    end;
end;

end.
