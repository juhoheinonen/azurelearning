using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace NetworkLearningFuncApp
{
    public static class GetCustomers
    {
        [FunctionName("GetCustomers")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            using (var connection = new SqlConnection(Environment.GetEnvironmentVariable("JuhoheDb")))
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

                return new OkObjectResult(customers);
            }
        }

        internal record CustomerViewModel(int CustomerID, string FirstName, string LastName, string EmailAddress, string CompanyName) { }
    }
}
