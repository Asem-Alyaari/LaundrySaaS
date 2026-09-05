namespace LaundrySaaS.Laundries;

public static class LaundriesDbProperties
{
    public static string DbTablePrefix { get; set; } = "Laundries";

    public static string? DbSchema { get; set; } = null;

    public const string ConnectionStringName = "Laundries";
}
