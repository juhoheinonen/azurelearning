using System.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

var config = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/customer", async () =>
{
    using (var client = new HttpClient())
    {
        var result = await client.SendAsync(new HttpRequestMessage(HttpMethod.Get, config["Uri"]));

        result.EnsureSuccessStatusCode();

        var content = await result.Content.ReadAsStringAsync();

        var customers = System.Text.Json.JsonSerializer.Deserialize<List<CustomerViewModel>>(content);

        return customers;
    }
})
.WithName("GetCustomers");

app.MapGet("/customersql", async () =>
{

    using (var connection = new SqlConnection(config.GetConnectionString("juhohedb")))
    {
        connection.Open();

        var command = new SqlCommand("select top 10 customerid, firstname, lastname, emailaddress, companyname from saleslt.customer", connection);

        var customers = new List<CustomerViewModel>();

        using (var reader = await command.ExecuteReaderAsync())
        {
            while (reader.Read())
            {
                customers.Add(new CustomerViewModel(int.Parse(reader[0] == null ? string.Empty : reader[0].ToString()), reader[1].ToString(), reader[2].ToString(), reader[3].ToString(), reader[4].ToString()));
            }
        }

        return customers;
    }
}).WithName("GetCustomerSql");

app.Run();

internal record CustomerViewModel(int CustomerID, string FirstName, string LastName, string EmailAddress, string CompanyName) { }