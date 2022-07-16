using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http;

namespace NetworkLearningFuncApp
{
    public static class NetworkTest
    {
        [FunctionName("NetworkTest")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var client = new HttpClient();
            var response = await client.GetAsync(@"https://ifconfig.me");
            var responseMessage = await response.Content.ReadAsStringAsync();

            return new OkObjectResult(responseMessage);
        }
    }
}
