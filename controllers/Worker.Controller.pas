unit Worker.Controller;

interface

uses
    System.SysUtils,
    Data.DB,
    Horse,
    System.JSON,
    FireDAC.Comp.Client,
    DataSet.Serialize,
    Worker.Model;

// Procedure to register routes for worker-related operations...
procedure Registry;

implementation

// List all workers...
procedure ListAllWorkers(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    worker : TWorker;
    qry : TFDQuery;
    error : String;
    arrayWorkers : TJSONArray;
begin

    // Attempt to create a TWorker instance...
    try
        // Write a separator and log that the request
        // to list all workers has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all workers');

        worker := TWorker.Create();
    except
        // Handle errors during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when quering the database - 500');
        exit;
    end;

    try
        // Attempt to list all workers and
        //convert the result to a JSON array...
        qry := worker.List_Workers('', error);
        arrayWorkers := qry.ToJSONArray();
        Res.Send<TJSONArray>(arrayWorkers);

        // Log the successful completion of the request...
        Writeln('Successfully listed workers - 200');

    finally
        // Free resources...
        qry.Free;
        worker.Free;
    end;

end;

// List a specific worker by ID...
procedure ListWorkersID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    qry : TFDQuery;
    worker : TWorker;
    objWorker : TJSONObject;
    error : String;
begin

    // Attempt to create a TWorker instance and set its ID_WORKER property...
    try
        // Write a separator and log that the request
        // to list worker by ID has started...
        Writeln('------------------------------');
        Writeln('Request GET - List worker by ID');

        worker := TWorker.Create;
        worker.ID_WORKER := req.Params['id'].ToInteger;
    except
        // Handle errors during instance creation or ID extraction...
        res.Send('Error when querying the database').Status(500);
        Writeln('Error when quering the database - 500');
        exit;
    end;

    try
        // Attempt to list the specified worker
        // and convert the result to a JSON object...
        qry := worker.List_Workers('', error);

        if qry.RecordCount > 0 then
        begin
            objWorker := qry.ToJSONObject;
            res.Send<TJSONObject>(objWorker);

            // Log the successful completion of the request...
            Writeln('Worker listed by ID successfully - 200');
        end
        else
        begin
            res.Send('Worker not found').Status(404);

            // Error log that caused the operation to fail...
            Writeln('Worker not found - 404');
        end;

    finally
        // Free resources...
        qry.Free;
        worker.Free;
    end;

end;

// Add a new worker...
procedure AddWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    worker : TWorker;
    body : TJSONValue;
    objWorker : TJSONObject;
    error : String;
begin
    // Attempt to create a TWorker instance...
    try
        // Write a separator and log that the request
        // to add new worker has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new worker');

        worker := TWorker.Create;
    except
        // Handle errors during instance creation...
        res.Send('Error when querying the database').Status(500);
        Writeln('Error when quering the database - 500');
        exit;
    end;

    try
        try
            // Attempt to parse the request body as JSON
            //  and extract worker's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            worker.NAME := body.GetValue<String>('nameWorker', '');
            worker.PASSWORD := body.GetValue<String>('passwordWorker', '');

            // Attempt to add the new worker...
            worker.Add_Worker(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
            begin
                // Handle exceptions during JSON parsing or worker addition...
                res.Send(ex.Message).Status(400);

                // Error log that caused the operation to fail...
                Writeln('Error when registering worker - 400');
                Writeln('Error Message: ' + ex.Message);
                exit;
            end;
        end;

        // Create a response JSON object with the new worker's ID...
        objWorker := TJSONObject.Create;
        objWorker.AddPair('idWorker', worker.ID_WORKER.ToString);

        // Send the response with a 201 status code (Created)...
        res.Send<TJSONObject>(objWorker).Status(201);

        // Log the successful completion of the request...
        Writeln('Worker successfully created - 200');

    finally
        // Free resources...
        worker.Free;
    end;

end;

// Update an existing worker...
procedure UpdateWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    objWorker : TJSONObject;
    error : String;
    body : TJSONValue;
    worker : TWorker;
begin

    try
        // Attempt to create a TWorker instance...
        Writeln('------------------------------');
        Writeln('Request PUT - Editing worker');
        worker := TWorker.Create;
    except
        // Handle errors during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when querying the database - 500');
        exit;
    end;

    try
        try
            // Set the ID_WORKER property based on the request parameter...
            worker.ID_WORKER := Req.Params['id'].ToInteger;

            // Attempt to parse the request body as JSON
            // and extract update worker information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            worker.NAME := body.GetValue<String>('nameWorker', '');
            worker.PASSWORD := body.GetValue<String>('passwordWorker', '');
            worker.IS_ACTIVE := body.GetValue<String>('isActive', '');

            // Attempt to update the existing worker...
            worker.Update_Worker(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
            begin
                // Handle exceptions during JSON parsing or worker update...
                Res.Send(ex.Message).Status(400);

                // Error log that caused the operation to fail...
                Writeln('Error editing worker - 400');
                Writeln('Error Message: ' + ex.Message);
                exit;
            end;
        end;

        // Create a response JSON object with the updated worker information...
        objWorker := TJSONObject.Create;
        objWorker.AddPair('idWorker', worker.ID_WORKER.ToString);
        objWorker.AddPair('nameWorker', worker.NAME);
        objWorker.AddPair('passwordWorker', worker.PASSWORD);
        objWorker.AddPair('isActive', worker.IS_ACTIVE);

        // Send the response with a 200 status code (OK)...
        Res.Send<TJSONObject>(objWorker).Status(200);

        // Log the successful completion of the request...
        Writeln('Worker edited successfully - 200');

    finally
        // Free resources...
        worker.Free;
    end;

end;

// Delete an existing worker...
procedure DeleteWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    objWorker : TJSONObject;
    error : String;
    worker : TWorker;
begin

    // Attempt to create a TWorker instance...
    try
        // Write a separator and log that the request
        // to delete worker has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete worker');

        worker := TWorker.Create;
    except
        // Handle errors during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when quering the database - 500');
        exit;
    end;

    try
        try
            // Set the ID_WORKER property based on the request parameter...
            worker.ID_WORKER := Req.Params['id'].ToInteger;

            // Attempt to delete the existing worker...
            worker.Delete_Worker(error);

            if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
            begin
                // Handle exceptions during worker deletion...
                Res.Send(ex.Message).Status(400);

                // Error log that caused the operation to fail...
                Writeln('Error deleting worker - 400');
                Writeln('Error Message: ' + ex.Message);
            end;
        end;

        // Create a response JSON object with the deleted worker's ID...
        objWorker := TJSONObject.Create;
        objWorker.AddPair('idWorker', worker.ID_WORKER.ToString);

        // Send the response with a 200 status code (OK)...
        Res.Send<TJSONObject>(objWorker).Status(200);

        // Log the successful completion of the request...
        Writeln('Worker successfully deleted - 200');

    finally
        // Free resources...
        worker.Free;
    end;

end;

// Register routes for worker-related operations...
procedure Registry;
begin
    THorse.Get('/workers', ListAllWorkers);
    THorse.Get('/workers/:id', ListWorkersID);
    THorse.Post('/workers', AddWorker);
    THorse.Put('/workers/:id', UpdateWorker);
    THorse.Delete('/workers/:id', DeleteWorker);
end;

end.
