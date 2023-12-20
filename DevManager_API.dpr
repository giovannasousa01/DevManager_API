program DevManager_API;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson;

begin
    THorse.Listen(9000, procedure
    begin
        Writeln('Server is running on port: ' + Thorse.Port.ToString);
    end)
end.
