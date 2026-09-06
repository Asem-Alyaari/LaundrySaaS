namespace LaundrySaaS.Accounting;

public static class AccountingDbProperties
{
    public static string DbTablePrefix { get; set; } = "Accounting";

    public static string? DbSchema { get; set; } = null;

    public const string ConnectionStringName = "Accounting";
}
