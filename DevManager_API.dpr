program devmanager_api;

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
  Customer.Controller in 'controllers\Customer.Controller.pas',
  Equipment.Model in 'models\Equipment.Model.pas',
  Equipment.Controller in 'controllers\Equipment.Controller.pas',
  Repair.Model in 'models\Repair.Model.pas',
  Repair.Controller in 'controllers\Repair.Controller.pas',
  Borrow.Model in 'models\Borrow.Model.pas',
  Borrow.Controller in 'controllers\Borrow.Controller.pas';

begin
    // Configure Horse to use the Jhonson middleware for JSON support...
    THorse.Use(Jhonson());

    // Register the controllers with the application...
    Worker.Controller.Registry;
    Customer.Controller.Registry;
    Equipment.Controller.Registry;
    Repair.Controller.Registry;
    Borrow.Controller.Registry;

    THorse.Port := 9000;

     // Display a message indicating that the server is running...
     Writeln('Server is running on port: ' + THorse.Port.ToString);
     Writeln('------ LOG ------');

     // Start the Horse server and listen on port 9000...
     THorse.Listen(THorse.Port);

end.
