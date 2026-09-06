namespace LaundrySaaS.Accounting;

public static class AccountingErrorCodes
{
    public const string AccountCodeAlreadyExists = "Accounting:00001";
    public const string AccountNotFound = "Accounting:00002";
    public const string CannotPostToParentAccount = "Accounting:00003";
    public const string JournalEntryNotBalanced = "Accounting:00004";
    public const string FiscalPeriodClosed = "Accounting:00005";
    public const string JournalEntryAlreadyPosted = "Accounting:00006";
    public const string JournalEntryMustHaveAtLeastTwoLines = "Accounting:00007";
    public const string CannotDeleteAccountWithEntries = "Accounting:00008";
    public const string FiscalYearClosed = "Accounting:00009";
    public const string CostCenterNotFound = "Accounting:00010";
    public const string AccountLevelExceeded = "Accounting:00011";
    public const string InvalidAmount = "Accounting:00012";
}
