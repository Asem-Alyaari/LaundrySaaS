using LaundrySaaS.Editions;
using LaundrySaaS.Subscriptions;
using Microsoft.EntityFrameworkCore;
using Volo.Abp;
using Volo.Abp.EntityFrameworkCore.Modeling;

namespace LaundrySaaS.EntityFrameworkCore;

public static class LaundrySaaSDbContextModelCreatingExtensions
{
    public static void ConfigureLaundrySaaS(
        this ModelBuilder builder)
    {
        Check.NotNull(builder, nameof(builder));

        builder.Entity<Edition>(b =>
        {
            b.ToTable(LaundrySaaSDbProperties.DbTablePrefix + "Editions", LaundrySaaSDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(e => e.DisplayName)
                .IsRequired()
                .HasMaxLength(128);

            b.Property(e => e.Price)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(e => e.AnnualPrice)
                .IsRequired()
                .HasPrecision(18, 2);

            b.Property(e => e.PlanType)
                .IsRequired();

            b.Property(e => e.IsFree)
                .IsRequired();
        });

        builder.Entity<TenantSubscription>(b =>
        {
            b.ToTable(LaundrySaaSDbProperties.DbTablePrefix + "TenantSubscriptions", LaundrySaaSDbProperties.DbSchema);

            b.ConfigureByConvention();

            b.Property(s => s.EditionId)
                .IsRequired();

            b.Property(s => s.SubscriptionCycle)
                .IsRequired();

            b.Property(s => s.StartDate)
                .IsRequired();

            b.Property(s => s.ExpireDate)
                .IsRequired();

            b.Property(s => s.Status)
                .IsRequired();

            b.HasOne(s => s.Edition)
                .WithMany()
                .HasForeignKey(s => s.EditionId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasIndex(s => s.TenantId);
            b.HasIndex(s => s.Status);
        });
    }
}
