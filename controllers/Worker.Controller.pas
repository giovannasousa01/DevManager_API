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
    worker       : TWorker;
    query        : TFDQuery;
    error        : String;
    arrayWorkers : TJSONArray;
begin

    try
        // Write a separator and log that the request
        // to list all workers has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all workers');

        // Attempt to create a TWorker instance...
        worker := TWorker.Create();

        // Create a FireDAC query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list all workers...
            query := worker.List_Workers('', error);

            if error <> '' then
                raise Exception.Create(error);

            // Convert the result to a JSON array...
            arrayWorkers := query.ToJSONArray();

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONArray>(arrayWorkers).Status(200);

            // Log the successful completion of the request...
            Writeln('Successfully listed workers - 200');

        finally
            // Free resources...
            query.Free;
            worker.Free;
        end;

    except
        // Handle errors during instance creation or listing workers...
        Res.Send('Error when querying workers from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it
        Writeln('Error when quering workers from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// List a specific worker by ID...
procedure ListWorkersID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query     : TFDQuery;
    worker    : TWorker;
    objWorker : TJSONObject;
    error     : String;
begin

    try
        // Write a separator and log that the request
        // to list worker by ID has started...
        Writeln('------------------------------');
        Writeln('Request GET - List worker by ID');

        // Attempt to create a TWorker instance and set its ID_WORKER property
        // based on the request params...
        worker := TWorker.Create;
        worker.ID_WORKER := req.Params['id'].ToInteger;

        // Create a FireDAC Query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list the specified worker...
            query := worker.List_Workers('', error);

            if error <> '' then
                raise Exception.Create(error);

            if query.RecordCount > 0 then
            begin
                // Convert the result to a JSON object...
                objWorker := query.ToJSONObject();

                // Send a response with a 200 status code (OK)...
                res.Send<TJSONObject>(objWorker).Status(200);

                // Log the successful completion of the request...
                Writeln('Worker listed by ID successfully - 200');
            end
            else
            begin
                // Send a response with a 404 status code (Not found)...
                res.Send('Worker not found').Status(404);

                // Log that the worker was not found...
                Writeln('Worker not found - 404');
            end;

        finally
            // Free resources...
            query.Free;
            worker.Free;
        end;

    except
        // Handle errors during instance creation or listing specified worker...
        res.Send('Error while querying worker from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when quering worker from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Add a new worker...
procedure AddWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    worker    : TWorker;
    body      : TJSONValue;
    objWorker : TJSONObject;
    error     : String;
begin

    try
        // Write a separator and log that the request
        // to add new worker has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new worker');

        // Attempt to create a TWorker instance...
        worker := TWorker.Create;

        try
            // Attempt to parse the request body as JSON
            //  and extract worker's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            worker.NAME     := body.GetValue<String>('nameWorker', '');
            worker.PASSWORD := body.GetValue<String>('passwordWorker', '');

            // Attempt to add the new worker...
            worker.Add_Worker(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the new worker's ID...
            objWorker := TJSONObject.Create;
            objWorker.AddPair('idWorker', worker.ID_WORKER.ToString);

            // Send the response with a 201 status code (Created)...
            Res.Send<TJSONObject>(objWorker).Status(201);

            // Log the successful completion of the request...
            Writeln('Worker successfully created - 200');

        finally
            // Free resources...
            worker.Free;
        end;

    except
        // Handle errors during instance creation or adding new worker...
        res.Send('Error while adding new worker to the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error while adding new worker to the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Employee login to the system
procedure LoginWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query     : TFDQuery;
    objWorker : TJSONObject;
    error     : String;
    worker    : TWorker;
    body      : TJSONValue;
begin
    try
        // Write a separator and log that the request
        // to login worker has started...
        Writeln('------------------------------');
        Writeln('Request POST - Login Worker');

        // Attempt to create a TWorker instance...
        worker := TWorker.Create;

        // Create a FireDAC Query...
        query := TFDQuery.Create(nil);

        try
            // Attempt to parse the request body as JSON
            // and extract worker's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body),
            0) as TJsonValue;

            worker.ID_WORKER := body.GetValue<String>('idWorker', '').ToInteger;
            worker.PASSWORD  := body.GetValue<String>('passwordWorker', '');

            // Attempt to login with the worker's information...
            query := worker.Login_Worker(error);

            if error <> '' then
            begin
                // Send a response with a 401 status code (Unauthorized)...
                Res.Send('Error: ' + error).Status(401);

                // Log when the operations fails and what caused it...
                Writeln('Error when logging worker - 401');
                Writeln('Error Message: ' + error);
                exit;
            end;

            // Create a response JSON Object with the worker's information...
            objWorker := query.ToJSONObject();

            // Send the response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objWorker).Status(200);

            // Log the successful completion of the request...
            Writeln('Worker successfully logged - 200');

        finally
            // Free resources...
            worker.Free;
            query.Free;
        end;

    except
        // Handle errors during instance creation or worker's login...
        Res.Send('Error when loging worker: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when loging worker - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Update an existing worker...
procedure UpdateWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    objWorker : TJSONObject;
    error     : String;
    body      : TJSONValue;
    worker    : TWorker;
    query     : TFDQuery;
begin

    try
        // Write a separator and log that the request
        // to update worker has started...
        Writeln('------------------------------');
        Writeln('Request PUT - Editing worker');

        // Attempt to create a TWorker instance and set the ID_WORKER property based
        // on the request params...
        worker := TWorker.Create;
        worker.ID_WORKER := Req.Params['id'].ToInteger;

        // Create a FireDAC Query instance...
        query := tFDQUery.Create(nil);

        try
            // Attempt to parse the request body as JSON
            // and extract worker's new information to update...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            worker.NAME      := body.GetValue<String>('nameWorker', '');
            worker.PASSWORD  := body.GetValue<String>('passwordWorker', '');
            worker.IS_ACTIVE := body.GetValue<String>('isActive', '');

            // Attempt to update the existing worker...
            query := worker.Update_Worker(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the updated worker information...
            objWorker := query.ToJSONObject();

            // Send the response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objWorker).Status(200);

            // Log the successful completion of the request...
            Writeln('Worker successfully updated - 200');

        finally
            // Free resources
            worker.Free;
            query.Free;
        end;

    except on ex:exception do
        begin
            // Handle errors during instance creation or updating worker...
            Res.Send('Error while updanting worker information in database: ' + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error while updating worker information in database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Delete an existing worker...
procedure DeleteWorker(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    objWorker : TJSONObject;
    error     : String;
    worker    : TWorker;
begin

    try
        // Write a separator and log that the request
        // to delete worker has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete worker');

        // Attempt to create a TWorker instance and set the ID_WORKER property
        // based on the request params...
        worker := TWorker.Create;
        worker.ID_WORKER := Req.Params['id'].ToInteger;

        try
            // Attempt to delete the existing worker...
            worker.Delete_Worker(error);

            if error <> '' then
                raise Exception.Create(error);

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

    except
        // Handle errors during instance creation or deleting worker...
        Res.Send('Error when deleting worker from the database').Status(500);

        // Log errors during instance creation or deleting worker...
        Writeln('Error when deleting worker from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Register routes for worker-related operations...
procedure Registry;
begin
    THorse
        .Get('/workers', ListAllWorkers)
        .Get('/workers/:id', ListWorkersID)
        .Post('/workers', AddWorker)
        .Post('/workers/login', LoginWorker)
        .Put('/workers/:id', UpdateWorker)
        .Delete('/workers/:id', DeleteWorker);
end;

end.
