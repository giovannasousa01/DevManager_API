unit Repair.Controller;

interface

uses
    System.SysUtils,
    Data.DB,
    Repair.Model,
    System.JSON,
    Horse,
    FireDAC.Comp.Client,
    Dataset.Serialize;

// Procedure to register routes for repair_related operation...
procedure Registry;

implementation

// List all repair order's...
procedure ListRepairs(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query       : TFDQuery;
    error       : String;
    arrayRepair : TJSONArray;
    repair      : TRepair;
begin

    try
        // Write a separator and log that the request
        // to list all repairs from the database has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all repairs orders');

        // Attempt to create a TRepair instance...
        repair := TRepair.Create;

        // Create a FireDAC query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list all repairs...
            query := repair.List_Repairs('', error);

            if error <> '' then
                raise Exception.Create(error);

            // Convert the result to a JSON array...
            arrayRepair := query.ToJSONArray();

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONArray>(arrayRepair).Status(200) ;

            // Log the successful completion of the request...
            Writeln('Repairs listed successfully - 200');

        finally
            // Free resources...
            query.Free;
            repair.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation or listing repairs...
            Res.Send('Error when querying repair''s order from the database: '
             + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error when querying repair''s order from database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// List a specific repair order by ID...
procedure ListRepairID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query     : TFDQuery;
    error     : String;
    objRepair : TJSONObject;
    repair    : TRepair;
begin

    try
        // Write a separator and log that the request
        // to list a repair by ID has started...
        Writeln('-----------------------------');
        Writeln('Request GET - List repair order by ID');

        // Attempt to create a TRepair instance and set the ID_REPAIR property
        // based on the request params...
        repair := TRepair.Create;
        repair.ID_REPAIR := Req.Params['id'].ToInteger;

        // Create a FireDAC query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list the especified repair...
            query := repair.List_Repairs('', error);

            if error <> '' then
                raise Exception.Create(error);

            if query.RecordCount > 0 then
            begin
                // Convert the result to a JSON object...
                objRepair := query.ToJSONObject();

                // Send a response with a 200 status code (OK)...
                Res.Send<TJSONObject>(objRepair).Status(200);

                // Log the successful completion of the request...
                Writeln('Repair by ID successfully listed - 200');
            end
            else
            begin
                // Send a response with a 404 status code (Not Found)...
                Res.Send('Repair order not found').Status(404);

                // Log that the repair order was not found...
                Writeln('Repair order not found - 400');
            end;

        finally
            // Free resources...
            query.Free;
            repair.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation
            // or listing especified repair...
            Res.Send('Error when querying repair order from the database: ' + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error when querying repair order from the database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Add new repair order...
procedure AddRepair(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    repair    : TRepair;
    error     : String;
    objRepair : TJSONObject;
    body      : TJSONValue;
begin
    try
        // Write a separator and log that the request
        // to add a new repair order has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new repair order');

        // Attempt to create a TRepair instance...
        repair := TRepair.Create;

        try
            // Attempt to parse the request body as JSON and extract
            // repair order information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body),
            0) as TJSONValue;

            repair.ID_CUSTOMER           := body.GetValue<String>('idCustomer', '').ToInteger;
            repair.ID_WORKER             := body.GetValue<String>('idWorker', '').ToInteger;
            repair.TYPE_EQUIPMENT        := body.GetValue<String>('typeEquipment', '');
            repair.DESCRIPTION_EQUIPMENT := body.GetValue<String>('descriptionEquipment', '');
            repair.REQUESTER_NAME        := body.GetValue<String>('requesterName', '');
            repair.ENTRY_DATE            := body.GetValue<String>('entryDate', '');
            repair.REPAIR_REASON         := body.GetValue<String>('repairReason', '');

            // Attempt to add new repair order...
            repair.Add_Repair(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the new repair order's ID...
            objRepair := TJSONObject.Create;
            objRepair.AddPair('idRepair', repair.ID_REPAIR);

            // Send a response with a 201 status code (Created)...
            Res.Send<TJSONObject>(objRepair).Status(201);

            // Log the successfully completion of the request...
            Writeln('Repair added successfully - 201');

        finally
            // Free resources...
            repair.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation or adding repair order...
            Res.Send('Error when adding new repair order to the database: ' + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error when adding new repair order to the database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Update an existing repair order...
procedure UpdateRepair(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    repair    : TRepair;
    error     : String;
    objRepair : TJSONObject;
    body      : TJSONValue;
    query     : TFDQuery;
begin
    try
        // Write a separator and log that the request
        // to update an existing repair order has started...
        Writeln('------------------------------');
        Writeln('Request PUT - Update an existing repair''s order');

        // Attempt to create a TRepair instance and set ID_REPAIR property
        // based on the request params...
        repair := TRepair.Create;
        repair.ID_REPAIR := Req.Params['id'].ToInteger;

        // Create a FireDAC query instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to parse the request body as JSON and extract
            // repair order's new information to update...
            body := TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body),
            0) as TJSONValue;

            repair.ID_CUSTOMER           := body.GetValue<String>('idCustomer', '').ToInteger;
            repair.ID_WORKER             := body.GetValue<String>('idWorker', '').ToInteger;
            repair.TYPE_EQUIPMENT        := body.GetValue<String>('typeEquipment', '');
            repair.DESCRIPTION_EQUIPMENT := body.GetValue<String>('descriptionEquipment', '');
            repair.REQUESTER_NAME        := body.GetValue<String>('requesterName', '');
            repair.ENTRY_DATE            := body.GetValue<String>('entryDate', '');
            repair.DELIVERY_DATE         := body.GetValue<String>('deliveryDate', '');
            repair.REPAIR_REASON         := body.GetValue<String>('repairReason', '');
            repair.REPAIR_COMPLETED      := body.GetValue<String>('repairCompleted', '');
            repair.WAS_DELIVERED         := body.GetValue<String>('wasDelivered', '');

            // Attempt to update the existing repair order...
            query := repair.Update_Repair(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the updated repair order information...
            objRepair := query.ToJSONObject();

            // Send the response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objRepair).Status(200);

            // Log the succesful completion of the request...
            Writeln('Repair order successfully updated - 200');

        finally
            // Free resources...
            repair.Free;
            query.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation or updating repair order...
            Res.Send('Error while updating repair order information in database: ' + error)
            .Status(500);

            // log when the operation fails and what caused it...
            Writeln('Error while updating repair order information in database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Delete an existing repair order...
procedure DeleteRepair(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    repair    : TRepair;
    error     : String;
    objRepair : TJSONObject;
begin
    try
        // Write a separator and log that the request
        // to delete an existing repair order has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete a repair order by ID');

        // Attempt to create a TRepair instance and set the ID_REPAIR property
        // based on the request params...
        repair := TRepair.Create;
        repair.ID_REPAIR := Req.Params['id'].ToInteger;

        try
            // Attempt to delete the repair order...
            repair.Delete_Repair(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the deleted repair's order ID...
            objRepair := TJSONObject.Create;
            objRepair.AddPair('idCustomer', repair.ID_REPAIR);

            // Send response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objRepair).Status(200);

            // Log the successful completion of the request...
            Writeln('Repair successfully deleted - 200');

        finally
            // Free resources...
            repair.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation or deleting repair order...
            Res.Send('Error when deleting repair order from the database: ' + error).Status(500);

            // Log when the operations fails and what caused it...
            Writeln('Error when deleting repair order from the database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Registering routes for repair-related operations...
procedure Registry;
begin
    THorse
        .Get('/repair', ListRepairs)
        .Get('/repair/:id', ListRepairID)
        .Post('repair', AddRepair)
        .Put('/repair/:id', UpdateRepair)
        .Delete('/repair/:id', DeleteRepair);
end;

end.
