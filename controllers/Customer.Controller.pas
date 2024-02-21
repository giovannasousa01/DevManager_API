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
    customer       : TCustomer;
    error          : String;
    query          : TFDQuery;
begin
    try
        // Write a separator and log that the request
        // to list all customers has started...
        Writeln('------------------------------');
        Writeln('Request GET - List all customers');

        // Attempt to create a TCustomer instance...
        customer := TCustomer.Create();

        // Create a TFDQuery instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to list all customers...
            query := customer.List_Customers('', error);

            if error <> '' then
                raise Exception.Create(error);

            // Convert the result to a JSON array...
            arrayCustomers := query.ToJSONArray();

            // Send a response with a 200 status code (OK)
            Res.Send<TJSONArray>(arrayCustomers).Status(200);

            // Log the successful completion of the request...
            Writeln('Successfully listed customers - 200');

        finally
            // Free resources...
            query.Free;
            customer.Free
        end;

    except
        // Handle error during instance creation or listing customers...
        Res.Send('Error when querying customers from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when querying customers from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// List a specific customer by ID...
procedure ListCustomerID(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    qry         : TFDQuery;
    objCustomer : TJSONObject;
    customer    : TCustomer;
    error       : String;
begin
    try
        // Write a separator and log that the request
        // to list customer by ID has started...
        Writeln('------------------------------');
        Writeln('Request GET - List customer by ID');

        // Attempt to create an TCustomer instance and set its ID_CUSTOMER property
        // based on the request params...
        customer := TCustomer.Create();
        customer.ID_CUSTOMER := req.Params['id'].ToInteger;

        try
            // Attempt to list the specified customer
            // and convert the result to a JSON object...
            qry := customer.List_Customers('', error);

            if error <> '' then
                raise Exception.Create(error);

            if qry.RecordCount > 0 then
            begin
                // Convert the result to a JSON object...
                objCustomer := qry.ToJSONObject();

                // Send a response with a 200 status code (OK)...
                Res.Send<TJSONObject>(objCustomer).Status(200);

                // Log the successful completion of the request...
                Writeln('Customer listed successfully - 200');
            end
            else
            begin
                // Send a response with a 404 status code (Not Found)...
                Res.Send('Customer not found').Status(404);

                // Error log that caused the operation to fail...
                Writeln('Customer not found - 404');
            end;

        finally
            // Free resources...
            customer.Free;
            qry.Free;
        end;

    except
        // Handle error during instance creation or listing specified customer...
        Res.Send('Error while querying customer from the database: ' + error).Status(500);

        //Log when the operation fails and what caused it...
        Writeln('Error while querying customer from the database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Add a new customer...
procedure AddCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    error       : String;
    customer    : TCustomer;
    body        : TJSONValue;
    objCustomer : TJSONObject;
begin
    try
        // Write a separator and log that the request
        // to add new customer has started...
        Writeln('------------------------------');
        Writeln('Request POST - Add new customer');

        // Attempt to create a TCustomer instance...
        customer := TCustomer.Create();

        try
            // Attempt to parse the request body as JSON
            // and extract customer's information...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            customer.NAME          := body.GetValue<String>('nameCustomer', '');
            customer.ADDRESS       := body.GetValue<String>('addressCustomer', '');
            customer.NEIGHBOURHOOD := body.GetValue<String>('neighbourhoodCustomer', '');
            customer.CITY          := body.GetValue<String>('cityCustomer', '');
            customer.TELEPHONE     := body.GetValue<String>('telephoneCustomer', '');
            customer.PHONE         := body.GetValue<String>('phoneCustomer');

            // Attempt to add the new customer...
            customer.Add_Customer(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the new customer's ID...
            objCustomer := TJSONObject.Create;
            objCustomer.AddPair('idCustomer', customer.ID_CUSTOMER.ToString);

            // Send the response with a 201 status code (Created)...
            Res.Send<TJSONObject>(objCustomer).Status(201);

            // Log the successful completion of the request...
            Writeln('Customer successfully created - 201');

        finally
            // Free resources...
            customer.Free;
        end;

    except
        // Handle errors during instance creation or adding new customer...
        Res.Send('Error while adding new customer to the database').Status(500);

        // Log when the operations fails and what caused it...
        Writeln('Error while adding new customer to the database - 500');
        Writeln('Error Message: ' + error);
        exit;
    end;
end;

// Update an existing customer...
procedure UpdateCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    customer    : TCustomer;
    error       : String;
    body        : TJSONValue;
    objCustomer : TJSONObject;
    query       : TFDQuery;
begin
    try
        // Write a separator and log that the request
        // to update customer by ID has started...
        Writeln('------------------------------');
        Writeln('Request PUT - Editing customer');

        // Attempt to create a TCustomer instance and set the ID_CUSTOMER property
        // based on the request params...
        customer := TCustomer.Create;
        customer.ID_CUSTOMER := Req.Params['id'].ToInteger;

        // Create a FireDAC Query instance...
        query := TFDQuery.Create(nil);

        try
            // Attempt to parse the request body as JSON
            // and extract customer's new information to update...
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body),
             0) as TJsonValue;

            customer.NAME          := body.GetValue<String>('nameCustomer', '');
            customer.ADDRESS       := body.GetValue<String>('addressCustomer', '');
            customer.NEIGHBOURHOOD := body.GetValue<String>('neighbourhoodCustomer', '');
            customer.CITY          := body.GetValue<String>('cityCustomer', '');
            customer.TELEPHONE     := body.GetValue<String>('telephoneCustomer' ,'');
            customer.PHONE         := body.GetValue<String>('phoneCustomer', '');
            customer.IS_ACTIVE     := body.GetValue<String>('isActive', '');

            // Attempt to update the existing customer...
            query := customer.Update_Custome(error);

            body.Free;

            if error <> '' then
                raise Exception.Create(error);

            // Create a response JSON object with the updated customer information...
            objCustomer := query.ToJSONObject();

            // Send the response with a 200 status code (OK)...
            Res.Send<TJSONObject>(objCustomer).Status(200);

            // Log the successful completion of the request...
            Writeln('Customer successfully updated - 200');

        finally
            // Free resources...
            customer.Free;
            query.Free;
        end;

    except
        // Handle errors during instance creation ou customer's update...
        Res.Send('Error while updating customer information in database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error while updating customer information in database - 500');
        Writeln('Error Message: ' + error);
    end;
end;

// Delete an existing customer...
procedure DeleteCustomer(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
    customer    : TCustomer;
    error       : String;
    objCustomer : TJSONObject;
begin

    try
        // Write a separator and log that the request
        // to delete customer has started...
        Writeln('------------------------------');
        Writeln('Request DELETE - Delete customer');

        // Attempt to create a TCustomer instance and set the ID_CUSTOMER property
        // based on the request params...
        customer := TCustomer.Create;
        customer.ID_CUSTOMER := Req.Params['id'].ToInteger;

        try
            // Attempt to delete the existing customer...
            customer.Delete_Customer(error);

            if error <> '' then
                raise Exception.Create(error);

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

    except
        // Handle erros during instance creation or customer deleting...
        Res.Send('Error when deleting customer from the database: ' + error).Status(500);

        // Log when the operation fails and what caused it...
        Writeln('Error when deleting customer from the database - 500');
        Writeln('Error Message: ' + error);
        exit;
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
