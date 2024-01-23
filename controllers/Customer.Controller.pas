unit Customer.Controller;

interface

uses
    System.SysUtils,
    Data.DB,
    Horse,
    System.JSON,
    FireDAC.Comp.Client,
    DataSet.Serialize,
    Customer.Model;

// Procedure to register routes for customer-related operations...
procedure Registry;

implementation

// List all customers...
procedure ListAllCustomers(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    arrayCustomers : TJSONArray;
    customer : TCustomer;
    error : String;
    qry : TFDQuery;
begin

    // Attempt to create a TCustomer instance...
    try
        // Write a separator and log that the request
        // to list all customers has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all customers');

        customer := TCustomer.Create();
    except
        // Handle error during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when querying the database - 500');
        exit;
    end;

    try
        // Attempt to list all customers and
        // convert the result to a JSON array...
        qry := customer.List_Customers('', error);
        arrayCustomers := qry.ToJSONArray();
        Res.Send<TJSONArray>(arrayCustomers);

        // Log the successful completion of the request...
        Writeln('Successfully listed customers - 200');

    finally
        // Free resources...
        qry.Free;
        customer.Free
    end;

end;

// List a specific worker by ID...
procedure ListCustomerID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    qry : TFDQuery;
    objCustomer : TJSONObject;
    customer : TCustomer;
    error : String;
begin

    // Attempt to create an TCustomer instance...
    try
        // Write a separator and log that the request
        // to list worker by ID has started...
        Writeln('------------------------------');
        Writeln('Request GET - List customer by ID');

        customer := TCustomer.Create();
        customer.ID_CUSTOMER := req.Params['id'].ToInteger;
    except
        // Handle error during instance creation or ID extraction...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when querying the database - 500');
        exit;
    end;

    try
        // Attempt to list the specified customer
        // and convert the result to a JSON object...
        qry := customer.List_Customers('', error);

        if qry.RecordCount > 0 then
        begin
            objCustomer := qry.ToJSONObject();
            Res.Send<TJSONObject>(objCustomer).Status(200);

            // Log the successful completion of the request...
            Writeln('Customer listed successfully - 200');
        end
        else
        begin
            Res.Send('Customer not found').Status(404);

            // Error log that caused the operation to fail...
            Writeln('Customer not found - 404');
        end;

    finally
        // Free resources...
        customer.Free;
        qry.Free;
    end;

end;

// Add a new customer...
procedure AddCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error : String;
    customer : TCustomer;
    body : TJSONValue;
    objCustomer : TJSONObject;
begin
    // Attempt to create a TCustomer instance...
    try
        // Write a separator and log that the request
        // to add new customer has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new customer');

        customer := TCustomer.Create();
    except
        // Handle errors during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when querying the database - 500');
        exit;
    end;

    try

        try
            // Attempt to parse the request body as JSON
            // and extract customer's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            customer.NAME := body.GetValue<String>('nameCustomer', '');
            customer.ADDRESS := body.GetValue<String>('addressCustomer', '');
            customer.NEIGHBOURHOOD := body.GetValue<String>('neighbourhoodCustomer', '');
            customer.CITY := body.GetValue<String>('cityCustomer', '');
            customer.TELEPHONE := body.GetValue<String>('telephoneCustomer', '');
            customer.PHONE := body.GetValue<String>('phoneCustomer');

            // Attempt to add the new customer...
            customer.Add_Customer(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
          begin
              // Handle exceptions during JSON parsing or customer addition...
              Res.Send(ex.Message).Status(400);

              // Error log that caused the operation to fail...
              Writeln('Error when registering customer - 400');
              Writeln('Error Message: ' + ex.Message);
              exit;
          end;
        end;

        // Create a response JSON object with the new customer's ID...
        objCustomer := TJSONObject.Create;
        objCustomer.AddPair('idWorker', customer.ID_CUSTOMER.ToString);

        // Send the response with a 201 status code (Created)...
        Res.Send<TJSONObject>(objCustomer).Status(201);

        // Log the successful completion of the request...
        Writeln('Customer successfully created - 201');

    finally
        // Free resources...
        customer.Free;
    end;
end;

// Update an existing customer...
procedure UpdateCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    customer : TCustomer;
    error : String;
    body : TJSONValue;
    objCustomer : TJSONObject;
begin
    // Attempt to create a TCustomer instance...
    try
        // Write a separator and log that the request
        // to edit customer by ID has started...
        Writeln('------------------------------');
        Writeln('Request PUT - Editing customer');

        customer := TCustomer.Create;
    except
        // Handle errors during instance creation...
        Res.Send('Error when querying the database').Status(500);
        Writeln('Error when querying the database - 500');
        exit;
    end;

    try
        try
            // Set the ID_CUSTOMER property based on the request params...
            customer.ID_CUSTOMER := Req.Params['id'].ToInteger;

            // Attempt to parse the request body as JSON
            // and update customer's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

             customer.NAME := body.GetValue<String>('nameCustomer', '');
             customer.ADDRESS := body.GetValue<String>('addressCustomer', '');
             customer.NEIGHBOURHOOD := body.GetValue<String>('neighbourhoodCustomer', '');
             customer.CITY := body.GetValue<String>('cityCustomer', '');
             customer.TELEPHONE := body.GetValue<String>('telephoneCustomer' ,'');
             customer.PHONE := body.GetValue<String>('phoneCustomer', '');
             customer.IS_ACTIVE := body.GetValue<String>('isActive', '');

             // Attempt to update the existing customer...
             customer.Update_Custome(error);

             body.Free;

             if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
            begin
                // Handle exceptions during JSON parsing or customer update...
                Res.Send(ex.Message).Status(400);

                // Error log that caused the operation to fail...
                Writeln('Error editing customer - 400');
                Writeln('Error Message: ' + ex.Message);
                exit;
            end;
        end;

        // Create a response JSON object with the updated customer information...
        objCustomer := TJSONObject.Create;
        objCustomer.AddPair('idCustomer', customer.ID_CUSTOMER.ToString);
        objCustomer.AddPair('nameCustomer', customer.NAME);
        objCustomer.AddPair('addressCustomer', customer.ADDRESS);
        objCustomer.AddPair('neighbourhoodCustomer', customer.NEIGHBOURHOOD);
        objCustomer.AddPair('cityCustomer', customer.CITY);
        objCustomer.AddPair('telephoneCustomer', customer.TELEPHONE);
        objCustomer.AddPair('isActive', customer.IS_ACTIVE);

        // Send the response with a 200 status code (OK)...
        Res.Send<TJSONObject>(objCustomer).Status(200);

        // Log the successful completion of the request...
        Writeln('Customer edited successfully');

    finally
        // Free resources...
        customer.Free;
    end;
end;

// Delete an existing customer...
procedure DeleteCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    customer : TCustomer;
    error : String;
    objCustomer : TJSONObject;
begin
    // Attempt to create a TCustomer instance...
    try
        // Write a separator and log that the request
        // to delete customer has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete customer');

        customer := TCustomer.Create;
    except
        // Handle erros during instance creation...
        Res.Send('Error when querying to the database').Status(500);
        Writeln('Error when querying to the database - 500');
        exit;
    end;

    try
        try
            // Set the ID_CUSTOMER property based on the request params...
            customer.ID_CUSTOMER := Req.Params['id'].ToInteger;

            // Attempt to delete the existing customer...
            customer.Delete_Customer(error);

            if error <> '' then
                raise Exception.Create(error);

        except on ex:exception do
            begin
                // Handle exceptions during customer deletion...
                Res.Send(ex.Message).Status(400);

                // Error log that caused the operation to fail...
                Writeln('Error deleting customer - 400');
                Writeln('Error Message: ' + ex.Message);
            end;
        end;

        // Create a response JSON object with the deleted customer's ID...
        objCustomer := TJSONObject.Create;
        objCustomer.AddPair('idCustomer', customer.ID_CUSTOMER);

        // Send the response with a 200 status code (OK)...
        Res.Send<TJSONObject>(objCustomer).Status(200);

        // Log the successful completion of the request...
        Writeln('Customer successfully deleted - 200');

    finally
        // Free resources...
        customer.Free;
    end;
end;

// Registering routes for customer-related operations...
procedure Registry;
begin
    THorse.Get('/customers', ListAllCustomers);
    THorse.Get('/customers/:id', ListCustomerID);
    THorse.Post('/customers', AddCustomer);
    THorse.Put('/customers/:id', UpdateCustomer);
    THorse.Delete('/customers/:id', DeleteCustomer);
end;

end.
