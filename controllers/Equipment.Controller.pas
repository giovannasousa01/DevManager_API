unit Equipment.Controller;

interface

uses
    System.SysUtils,
    Data.DB,
    Horse,
    System.JSON,
    FireDAC.Comp.Client,
    DataSet.Serialize,
    Equipment.Model;

// Procedure to register routes for equipment-related operation...
procedure Registry;

implementation

// List all equipments...
procedure ListAllEquipments(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query           : TFDQuery;
    error           : String;
    arrayEquipments : TJSONArray;
    equipment       : TEquipment;
begin

    try
        // Write a separator and log that the request
        // to list all equipments has started...
        Writeln('-----------------------------');
        Writeln('Request GET - List all equipment');

        // Attempt to create a TEquipment instance...
        equipment := TEquipment.Create();

        // Create a FireDAC query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list all equipments...
            query := equipment.List_Equipments('', error);

            if error <> '' then
                raise Exception.Create(error);

            // Convert the result to a JSON array...
            arrayEquipments := query.ToJSONArray();

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONArray>(arrayEquipments).Status(200);

            // Log the successful completion of the request...
            Writeln('Equipment successfully listed - 200');

        finally
            // Free resources...
            query.Free;
            equipment.Free
        end;

    except
        // Handle error during instance creation or listing equipments...
        Res.Send('Error when querying equipments from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when querying equipments from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// List a specific equipment by ID
procedure ListEquipmentID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query        : TFDQuery;
    error        : String;
    equipment    :  TEquipment;
    objEquipment : TJSONObject;
begin

    try
        // Write a separator and log that the request to list a specific
        // equipment by ID has started...
        Writeln('---------------------------');
        Writeln('Request GET - List equipment by ID');

        // Attempt to create an TEquipment instance and
        // set its ID_EQUIPMENT property based on the request params...
        equipment := TEquipment.Create();
        equipment.ID_EQUIPMENT := Req.Params['id'].ToInteger;

        // Create a FireDAC query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list the specified equipment...
            query := equipment.List_Equipments('', error);

            if error <> '' then
                raise Exception.Create(error);

            if query.RecordCount > 0 then
            begin
                // Convert the result to a JSON object...
                objEquipment := query.ToJSONObject();

                // Send a response with a 200 status code (OK)...
                Res.Send<TJSONObject>(objEquipment).Status(200);

                // Log the successful completion of the request...
                Writeln('Equipment listed successfully - 200');
            end
            else
            begin
                // Send a response with a 404 status code (Not found)...
                Res.Send('Equipment not found').Status(404);

                // Log that the equipment was not found...
                Writeln('Equipment not found - 404');
            end;

        finally
            // Free resources...
            query.Free;
            equipment.Free;
        end;

    except
        // Handle error during instance creation or listing specified equipment...
        Res.Send('Error when querying equipment from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when querying equipment from the database - 500');
        Writeln('Error Message: ' + error);
        exit;
    end;
end;

// Add a new equipment...
procedure AddEquipment(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error        : String;
    equipment    : TEquipment;
    objEquipment : TJSONObject;
    body         : TJSONValue;
begin

    try
        // Write a separator and log that the request
        // to add equipment has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new equipment');

        // Attempt to create a TEquipment instance...
        equipment := TEquipment.Create;

        try
            // Attempt to parse the request body as JSON
            // and extract equipment's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body),
             0) as TJsonValue;

             equipment.NAME        := body.GetValue<String>('nameEquipment', '');
             equipment.DESCRIPTION := body.GetValue<String>('descriptionEquipment', '');

             // Attempt to add the new equipment...
             equipment.Add_Equipment(error);

             body.Free;

             if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the new equipment's ID...
            objEquipment := TJSONObject.Create();
            objEquipment.AddPair('idEquipment', equipment.ID_EQUIPMENT.ToString);

            // Send the response with a 201 status code (Created)...
            Res.Send<TJSONObject>(objEquipment).Status(201);

            // Log the successful completion of the request...
            Writeln('Equipment successfully created - 201');

        finally
            // Free resources...
            equipment.Free;
        end;

    except
        // Handle error during instance creation or adding new equipment...
        Res.Send('Error when adding new equipment to the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when adding new equipment to the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Update an existing equipment...
procedure UpdateEquipment(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error        : String;
    body         : TJSONValue;
    objEquipment : TJSONObject;
    equipment    : TEquipment;
    query        : TFDQuery;
begin

    try
        // Write a separator and log that the request
        // to update equipment has started...
        Writeln('-----------------------------');
        Writeln('Request PUT - Editing equipment');

        // Attempt to create an TEquipment instance and set its ID_EQUIPMENT property
        // based on the request params....
        equipment := TEquipment.Create;
        equipment.ID_EQUIPMENT := Req.Params['id'].ToInteger;

        // Create a FireDAC query instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to parse the request body as JSON
            // and extract equipment's new information to update...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body),
             0) as TJsonValue;

             equipment.NAME        := body.GetValue<String>('nameEquipment', '');
             equipment.DESCRIPTION := body.GetValue<String>('descriptionEquipment', '');
             equipment.IS_BORROWED := body.GetValue<String>('isBorrowed', '');
             equipment.IS_ACTIVE   := body.GetValue<String>('isActive', '');

             // Attempt to update the equipment...
             query := equipment.Update_Equipment(error);

             body.Free;

             if error <> '' then
                raise Exception.Create(error);

             // Create a response JSON object with the updated equipment information...
             objEquipment := query.ToJSONObject();

             // Send the response with a 200 status code (OK)...
             Res.Send<TJSONObject>(objEquipment).Status(200);

             // Log the successful completion of the request...
             Writeln('Equipment successfully updated - 200');

        finally
            // Free resources...
            equipment.Free;
            query.Free;
        end;

    except
        // Handle error during instance creation or updating equipment...
        Res.Send('Error while updating equipment information in database').Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error while updating equipment information in database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Delete an existing equipment...
procedure DeleteEquipment(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error : String;
    equipment : TEquipment;
    objEquipment : TJSONObject;
begin

    try
        // Write a separator and log that the request
        // to delete a customer has started...
        Writeln('----------------------------');
        Writeln('Request DELETE - Delete equipment');

        // Attempt to create a TEquipment instance and set the ID_EQUIPMENT property
        // based on the request params...
        equipment := TEquipment.Create;
        equipment.ID_EQUIPMENT := Req.Params['id'].ToInteger;

        try
            // Attempt to delete the existing equipment...
            equipment.Delete_Equipment(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the deleted equipment's ID...
            objEquipment := TJSONObject.Create;
            objEquipment.AddPair('idEquipment', equipment.ID_EQUIPMENT.toString);

            // Send the response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objEquipment).Status(200);

            // Log the successful completion of the request...
            Writeln('Equipment successfully deleted - 200');

        finally
            // Free resources...
            equipment.Free;
        end;

    except
        // Handle exceptiond during instance creation or deleting equipment...
        Res.Send('Error when deleting equipment from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when deleting equipment from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Registering routes for equipments-related operations...
procedure Registry;
begin
    THorse
        .Get('/equipments', ListAllEquipments)
        .Get('/equipments/:id', ListEquipmentID)
        .Post('/equipments', AddEquipment)
        .Put('/equipments/:id', UpdateEquipment)
        .Delete('/equipments/:id', DeleteEquipment);
end;

end.
