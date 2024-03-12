unit Borrow.Controller;

interface

uses
    System.SysUtils,
    Data.DB,
    Borrow.Model,
    Horse,
    Dataset.Serialize,
    System.JSON,
    FireDAC.Comp.Client;

// Procedure to register routes for borrow-related operation...
procedure Registry;

implementation

// List all borrow order's...
procedure ListBorrows(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    query       : TFDQuery;
    error       : String;
    borrowArray : TJSONArray;
    borrow      : TBorrow;
begin
    try
        // Write a separator and log that the request
        // to list all borrowed equipments from the database has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all borrows');

        // Attempt to create a TBorrow instance...
        borrow := TBorrow.Create;

        // Attempt to create a TFDQuery instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list all the borrowed equipments...
            query := borrow.List_Borrows('', error);

            if error <> '' then
                raise Exception.Create(error);

            // Convert the result to a JSON Array...
            borrowArray := query.ToJSONArray();

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONArray>(borrowArray).Status(200);

            // Log the succesful completion of the request...
            Writeln('Borrowed equipments succesfully listed - 200');

        finally
            // Free instance...
            query.Free;
            borrow.Free
        end;

    except
        begin
            // Handle exceptions during instance creation or
            // listing borrowed equipments...
            Res.Send('Error when querying borrow''s order from the database: ' + error)
            .Status(500);

            // Log when the operations fails and what caused it...
            Writeln('Error when querying borrow''s order from the database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// List a specific borrow order by ID...
procedure ListBorrowID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error     : String;
    objBorrow : TJSONObject;
    query     : TFDQuery;
    borrow    : TBorrow;
begin
    try
        // Write a separator and log that the request to list a
        // borrow order by ID from the database has started...
        Writeln('------------------------------');
        Writeln('Request GET - List a borrowed equipment by ID');

        // Attempt to create a TBorrow instance and set the ID_BORROW property
        // based on the request params...
        borrow := TBorrow.Create;
        borrow.ID_BORROW := Req.Params['id'].ToInteger;

        // Attempt to create a TFDQuery instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list the especified borrow order...
            query := borrow.List_Borrows('', error);

            if error <> '' then
                raise Exception.Create(error);

            if query.RecordCount > 0 then
            begin
                // Convert the result to a JSON object...
                objBorrow := query.ToJSONObject();

                // Send a response with a 200 status code (OK)...
                Res.Send<TJSONObject>(objBorrow).Status(200);

                // Log the succesfful completion of the request...
                Writeln('Borrow order successfully listed - 200');
            end
            else
            begin
                // Send a response with a 404 status code (Not Found)...
                Res.Send('Borrow order not found').Status(404);

                // Log that the borrow order was not found...
                Writeln('Borrow order not found - 404');
            end;

        finally
            // Free instances...
            query.Free;
            borrow.Free;
        end;

    except
        begin
            // Handle exceptions during instance creation or
            // listing especified borrow order...
            Res.Send('Error when querying borrow order from the database: ' + error)
            .Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error when querying borrow order from the database - 500');
            Writeln('Error Message: ' + error);
        end;
    end;
end;

// Add a new borrow order...
procedure AddBorrow(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    body      : TJSONValue;
    objBorrow : TJSONObject;
    borrow    : TBorrow;
    error     : String;
begin
    try
        // Write a separator and log when the request to add a new
        // borrow order has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new borrow order');

        // Attempt to create a TBorrow instance...
        borrow := TBorrow.Create;

        try
            // Attempt to parse the request body as JSON and extract
            // borrow order information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.body),
            0) as TJSONValue;

            borrow.ID_EQUIPMENT   := body.GetValue<String>('idEquipment', '').ToInteger;
            borrow.ID_CUSTOMER    := body.GetValue<String>('idCustomer', '').ToInteger;
            borrow.ID_WORKER      := body.GetValue<String>('idWorker', '').ToInteger;
            borrow.REQUESTER_NAME := body.GetValue<String>('requesterName', '');
            borrow.BORROW_DATE    := body.GetValue<String>('borrowDate', '');
            borrow.BORROW_REASON  := body.GetValue<String>('borrowReason', '');

            // Attempt to add new borrow order...
            borrow.Add_Borrow(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the new borrow order's ID...
            objBorrow := TJSONObject.Create;
            objBorrow.AddPair('idBorrow', borrow.ID_BORROW.ToString);

            // Send a response with a 201 status code (Created)...
            Res.Send<TJSONObject>(objBorrow).Status(201);

            // Log thhe success completion of the request...
            Writeln('Borrow added successfully - 201');

        finally
            // Free resources
            borrow.Free;
        end;

    except
        begin
            // Handle errors during instance creation or adding new borrow order...
            Res.Send('Error while adding new borrow order to the database: ' + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error while adding new borrow order to the database - 500');
            Writeln('Error message: ' + error);
        end;
    end;
end;

// Update an existing borrow order...
procedure UpdateBorrow(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error     : String;
    objBorrow : TJSONObject;
    borrow    : TBorrow;
    body      : TJSONValue;
    query     : TFDQuery;
begin

    try
        // Write a separator and log that the request to update an existing
        // borrow order has started...
        Writeln('------------------------------');
        Writeln('Request PUT - Update especific borrow''s order');

        // Attempt to create a TBorrow instance and set the ID_BORROW property
        // based on the request params...
        borrow := TBorrow.Create;
        borrow.ID_BORROW := req.Params['id'].ToInteger;

        // Create a FireDAC Query instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to parse the request body as JSON and extract
            // borrow order's new information to update...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.body),
            0) as TJSONValue;

            borrow.ID_EQUIPMENT   := body.GetValue<String>('idEquipment', '').ToInteger;
            borrow.ID_CUSTOMER    := body.GetValue<String>('idCustomer', '').ToInteger;
            borrow.ID_WORKER      := body.GetValue<String>('idWorker' ,'').ToInteger;
            borrow.REQUESTER_NAME := body.GetValue<String>('requesterName', '');
            borrow.BORROW_DATE    := body.GetValue<String>('borrowDate', '');
            borrow.RETURN_DATE    := body.GetValue<String>('returnDate', '');
            borrow.BORROW_REASON  := body.GetValue<String>('borrowReason', '');
            borrow.WAS_RETURNED   := body.GetValue<String>('wasReturned', '');

            // Attempt to update the borrow order's information...
            query := borrow.Update_Borrow(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object With the updated borrow order's information...
            objBorrow := query.ToJSONObject();

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objBorrow).Status(200);

            // Log the successfull completion of the request...
            Writeln('Borrow order succesfully updated - 200');

        finally
            // Free resources...
            borrow.Free;
            query.Free;
        end;

    except
        begin
            // Handle errors during instance creation or
            // updating borrow order's information...
            Res.Send('Error while updating borrow order information in database: ' + error)
            .Status(500);

            // Log when the operations fails and what caused it...
            Writeln('Error while updating borrow order information in database - 500');
            Writeln('Error message: ' + error);
        end;
    end;
end;

// Delete an existing borrow order...
procedure DeleteBorrow(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error     : String;
    borrow    : TBorrow;
    objBorrow : TJSONObject;
begin
    try
        // Write a separator and log that the request to delete an existing
        // borrow's order has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete an existing borrow''s order');

        // Attempt to create a TBorrow instance and set the ID_BORROW property
        // based on the request params...
        borrow := TBorrow.Create;
        borrow.ID_BORROW := Req.Params['id'].ToInteger;

        try
            // Attempt to delete an existing borrow's order...
            borrow.Delete_Borrow(error);

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the deleted borrow's order ID...
            objBorrow := TJSONObject.Create;
            objBorrow.AddPair('idBorrow', borrow.ID_BORROW.ToString);

            // Send a response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objBorrow).Status(200);

            // Log the successful completion of the request...
            Writeln('Borrow''s order successfully deleted - 200');
            
        finally
            // Free resources...
            borrow.Free;
        end;

    except
        begin
            // Handle errors during instance creation or while 
            // deleting borrow's order...
            Res.Send('Error while deleting borrow order from the database: ' + error).Status(500);

            // Log when the operation fails and what caused it...
            Writeln('Error while deleting borrow order from the database - 500');
            Writeln('Error message: ' + error);
        end;
    end;
end;

// Registering routes for borrow-related operations...
procedure Registry;
begin
    THorse
        .Get('/borrow', ListBorrows)
        .Get('/borrow/:id', ListBorrowID)
        .Post('/borrow', AddBorrow)
        .Put('/borrow/:id', UpdateBorrow)
        .Delete('/borrow/:id', DeleteBorrow);
end;

end.
