using System.Diagnostics;
using Microsoft.Extensions.Configuration;
using System.Security.Cryptography.X509Certificates;
using Daemon.Model;

IConfiguration config = new ConfigurationBuilder()
                            .AddJsonFile("appsettings.json")
                            .AddUserSecrets<Program>()
                            .AddEnvironmentVariables()
                            .Build();

AppConfiguration appConfiguration = config.GetRequiredSection("AppConfiguration").Get<AppConfiguration>();

await CallApiWithCertAsync();

async Task CallApiWithCertAsync()
{
    var timer = new Stopwatch();
    timer.Start();
    //"https://apimdevtesthg.azure-api.net/thumb/"
    var cert = new X509Certificate2(appConfiguration.CertificatePath,appConfiguration.CertificatePassword); // Cert with private key
    var handler = new HttpClientHandler();
    handler.ClientCertificates.Add(cert);
    var client = new HttpClient(handler);
    timer.Stop();

    TimeSpan timeTaken = timer.Elapsed;
    Console.WriteLine("Time taken load cert: " + timeTaken.ToString(@"m\:ss\.fff"));

    timer.Start();    
    var response = await client.PostAsync(appConfiguration.ApiEndpoint, new StringContent("Hello World"));
    timer.Stop();

    timeTaken = timer.Elapsed;
    Console.WriteLine("Time taken call API: " + timeTaken.ToString(@"m\:ss\.fff"));


    if (response.IsSuccessStatusCode)
    {
        Console.WriteLine(await response.Content.ReadAsStringAsync());
    }
    else 
    {
        Console.WriteLine($"Error: {response.StatusCode}");
        Console.WriteLine($"Reason: {response.ReasonPhrase}");
    }
}
