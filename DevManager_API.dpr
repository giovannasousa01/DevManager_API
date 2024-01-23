program DevManager_API;

{$APPTYPE CONSOLE} // Specify the application type as console...

{$R *.res} // Include the compiled resource file...

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  connection.model in 'models\connection.model.pas',
  Worker.Model in 'models\Worker.Model.pas',
  Worker.Controller in 'controllers\Worker.Controller.pas',
  Customer.Model in 'models\Customer.Model.pas',
  Customer.Controller in 'controllers\Customer.Controller.pas';

begin
    // Configure Horse to use the Jhonson middleware for JSON support...
    THorse.Use(Jhonson());

    // Register the controllers with the application...
    Worker.Controller.Registry;
    Customer.Controller.Registry;

    // Start the Horse server and listen on port 9000...
    THorse.Listen(9000, procedure
    begin
        // Display a message indicating that the server is running...
        Writeln('Server is running on port: ' + Thorse.Port.ToString);
        Writeln('------ LOG ------');
    end);
end.
