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
        // Set up PostgreSQL database connection parameters...
        FConn.Params.DriverID := 'PG';
        FConn.Params.Database := 'DevManager_API';
        FConn.Params.UserName := 'postgres';
        FConn.Params.Password := '.Punk4ever';
        FConn.Params.Add('Port=5432');
        FConn.Params.Add('Server=localhost');

        Result := 'OK';

        // Log success message if the setup is successful
        Writeln('Database configured successfully');

    except on ex:exception do
        begin
            Result := 'Error configuring the database: ' + ex.Message;

            // Log error message if an exception occurs during setup
            Writeln(Result);
        end;

    end;
end;

// Function to connect to the database...
function Connect : TFDConnection;
begin
    // Create a new FireDAC connection instance...
    FConnection := TFDConnection.Create(nil);

    // Set up the database connection using the SetupConnection function...
    SetupConnection(FConnection);

    // Attempt to connect to the database...
    FConnection.Connected := true;

    // Log success or failure message based on the connection status..
    if FConnection.Connected = true then
        Writeln('Server connected to the database')
    else
        Writeln('Server not connected to database');

    // Return the connected TFDConnection instance...
    Result := FConnection;
end;

// Procedure to disconnect from the database...
procedure Disconnect;
begin

    // Check if the TFDConnection instance is assigned
    if Assigned(FConnection) then
    begin
        // Check if the connection is currently active...
        if FConnection.Connected = true then
        begin
            // Disconnect from the database...
            FConnection.Connected := false;
            Writeln('Server disconnected from database');
        end;

        // Free the TFDConnection instance...
        FConnection.Free;
    end;
end;

end.
