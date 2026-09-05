namespace LaundrySaaS;

public static class LaundrySaaSDbProperties
{
    public static string DbTablePrefix { get; set; } = "LaundrySaaS";

    public static string? DbSchema { get; set; } = null;

    public const string ConnectionStringName = "LaundrySaaS";
}
