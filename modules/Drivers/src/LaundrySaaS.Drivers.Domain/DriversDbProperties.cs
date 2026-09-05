namespace LaundrySaaS.Drivers;

public static class DriversDbProperties
{
    public static string DbTablePrefix { get; set; } = "Drivers";

    public static string? DbSchema { get; set; } = null;

    public const string ConnectionStringName = "Drivers";
}
