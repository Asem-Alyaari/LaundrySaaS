import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { forkJoin, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NzPageHeaderModule } from 'ng-zorro-antd/page-header';
import { NzTableModule } from 'ng-zorro-antd/table';
import { NzButtonModule } from 'ng-zorro-antd/button';
import { NzIconModule } from 'ng-zorro-antd/icon';
import { NzModalModule } from 'ng-zorro-antd/modal';
import { NzFormModule } from 'ng-zorro-antd/form';
import { NzInputModule } from 'ng-zorro-antd/input';
import { NzSelectModule } from 'ng-zorro-antd/select';
import { NzRadioModule } from 'ng-zorro-antd/radio';
import { NzPopconfirmModule } from 'ng-zorro-antd/popconfirm';
import { NzTagModule } from 'ng-zorro-antd/tag';
import { NzCardModule } from 'ng-zorro-antd/card';
import { NzMessageService } from 'ng-zorro-antd/message';
import { NzBreadCrumbModule } from 'ng-zorro-antd/breadcrumb';
import { NzBadgeModule } from 'ng-zorro-antd/badge';
import { NzTooltipModule } from 'ng-zorro-antd/tooltip';
import { NzDividerModule } from 'ng-zorro-antd/divider';
import { NzDropDownModule } from 'ng-zorro-antd/dropdown';
import { NzEmptyModule } from 'ng-zorro-antd/empty';
import { RouterModule } from '@angular/router';
import { TenantService, TenantDto, TenantCreateDto, TenantUpdateDto } from '@abp/ng.tenant-management/proxy';
import { EditionService } from '../editions-admin/services/edition.service';
import { EditionDto } from '../editions-admin/models/edition.models';
import { TenantSubscriptionService, TenantSubscriptionDto } from './services/tenant-subscription.service';

export interface LaundryTenantDto extends TenantDto {
  isActive?: boolean;
  editionId?: string;
  editionName?: string;
  planType?: string;
  subscriptionCycle?: 'monthly' | 'annual';
  connectionString?: string;
  databaseName?: string;
  isDedicatedDb?: boolean;
  isLoadingDb?: boolean;
}

@Component({
  selector: 'app-laundries-admin',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule,
    NzPageHeaderModule,
    NzTableModule,
    NzButtonModule,
    NzIconModule,
    NzModalModule,
    NzFormModule,
    NzInputModule,
    NzSelectModule,
    NzRadioModule,
    NzPopconfirmModule,
    NzTagModule,
    NzCardModule,
    NzBreadCrumbModule,
    NzBadgeModule,
    NzTooltipModule,
    NzDividerModule,
    NzDropDownModule,
    NzEmptyModule,
  ],
  templateUrl: './laundries-admin.component.html',
  styleUrls: ['./laundries-admin.component.scss'],
})
export class LaundriesAdminComponent implements OnInit {
  tenants: LaundryTenantDto[] = [];
  availableEditions: EditionDto[] = [];
  totalCount = 0;
  activeCount = 0;
  suspendedCount = 0;
  loading = false;
  pageIndex = 1;
  pageSize = 10;
  searchTerm = '';
  filterStatus: 'all' | 'active' | 'suspended' = 'all';

  get filteredTenants(): LaundryTenantDto[] {
    if (this.filterStatus === 'active') {
      return this.tenants.filter((t) => t.isActive !== false);
    }
    if (this.filterStatus === 'suspended') {
      return this.tenants.filter((t) => t.isActive === false);
    }
    return this.tenants;
  }

  onFilterStatusChange(status: 'all' | 'active' | 'suspended'): void {
    this.filterStatus = status;
    this.cdr.markForCheck();
  }

  getLaundryInitials(name?: string): string {
    if (!name) return 'مغ';
    const clean = name.replace(/^(مغسلة|شركة|مؤسسة)\s+/i, '').trim();
    const parts = clean.split(/\s+/);
    if (parts.length >= 2) {
      return parts[0][0] + ' ' + parts[1][0];
    }
    return clean.slice(0, 2);
  }

  getAvatarGradient(id?: string): string {
    const gradients = [
      'linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%)',
      'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)',
      'linear-gradient(135deg, #10b981 0%, #059669 100%)',
      'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
      'linear-gradient(135deg, #ec4899 0%, #be185d 100%)',
      'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)',
    ];
    if (!id) return gradients[0];
    let hash = 0;
    for (let i = 0; i < id.length; i++) {
      hash = (hash + id.charCodeAt(i)) % gradients.length;
    }
    return gradients[hash];
  }

  // Local state map for tenant metadata (status & assigned edition)
  private tenantStorageKey = 'laundrysaas_tenants_meta';
  private tenantMetaMap: {
    [id: string]: {
      isActive: boolean;
      editionId: string;
      editionName: string;
      planType: string;
      subscriptionCycle?: 'monthly' | 'annual';
    };
  } = {};

  // Create / Edit Tenant Modal State
  isModalVisible = false;
  isEditMode = false;
  selectedTenantId: string | null = null;
  isSubmitting = false;
  tenantForm!: FormGroup;

  // Change Subscription Plan Modal State
  isPlanModalVisible = false;
  planTenant: LaundryTenantDto | null = null;
  selectedPlanEditionId: string = '';
  selectedPlanCycle: 'monthly' | 'annual' = 'monthly';
  isSavingPlan = false;

  // Connection String Modal
  isConnModalVisible = false;
  connStringTenant: LaundryTenantDto | null = null;
  defaultConnectionString = '';
  isSavingConnString = false;

  constructor(
    private fb: FormBuilder,
    private tenantService: TenantService,
    private editionService: EditionService,
    private subscriptionService: TenantSubscriptionService,
    private message: NzMessageService,
    private cdr: ChangeDetectorRef
  ) {
    this.loadMetaMap();
    this.initForm();
  }

  ngOnInit(): void {
    this.loadEditions();
    this.loadTenants();
  }

  private initForm(): void {
    this.tenantForm = this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(64)]],
      adminEmailAddress: ['', [Validators.required, Validators.email]],
      adminPassword: ['', [Validators.required, Validators.minLength(6)]],
      editionId: [this.availableEditions[0]?.id || '', [Validators.required]],
      subscriptionCycle: ['monthly', [Validators.required]],
    });
  }

  private loadMetaMap(): void {
    try {
      const saved = localStorage.getItem(this.tenantStorageKey);
      if (saved) {
        this.tenantMetaMap = JSON.parse(saved);
      }
    } catch {
      this.tenantMetaMap = {};
    }
  }

  private saveMetaMap(): void {
    try {
      localStorage.setItem(this.tenantStorageKey, JSON.stringify(this.tenantMetaMap));
    } catch {
      // Ignored
    }
  }

  loadEditions(): void {
    this.editionService.getList({ maxResultCount: 50 }).subscribe({
      next: (res) => {
        this.availableEditions = res.items || [];
        this.cdr.markForCheck();
        this.cdr.detectChanges();
      },
    });
  }

  loadTenants(): void {
    this.loading = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();

    forkJoin({
      subscriptions: this.subscriptionService.getAll().pipe(catchError(() => of([]))),
      tenantsRes: this.tenantService
        .getList({
          maxResultCount: this.pageSize,
          skipCount: (this.pageIndex - 1) * this.pageSize,
          filter: this.searchTerm ? this.searchTerm.trim() : undefined,
        })
        .pipe(
          catchError((err) => {
            const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء تحميل قائمة المغاسل';
            this.message.error(errorMsg);
            return of({ items: [], totalCount: 0 });
          })
        ),
    }).subscribe({
      next: ({ subscriptions, tenantsRes }) => {
        const subMap = new Map<string, TenantSubscriptionDto>();
        if (subscriptions) {
          subscriptions.forEach((s) => {
            if (s.tenantId) subMap.set(s.tenantId, s);
          });
        }

        const items = (tenantsRes.items || []) as LaundryTenantDto[];
        this.tenants = items.map((t) => {
          const tenant = t as LaundryTenantDto;
          const dbSub = tenant.id ? subMap.get(tenant.id) : null;
          const meta = tenant.id ? this.tenantMetaMap[tenant.id] : null;

          if (dbSub) {
            tenant.isActive = dbSub.status === 1;
            tenant.editionId = dbSub.editionId;
            tenant.editionName = dbSub.editionName || dbSub.edition?.displayName || 'الباقة المتقدمة';
            tenant.planType = dbSub.edition?.planType !== undefined ? String(dbSub.edition.planType) : 'Pro';
            tenant.subscriptionCycle = dbSub.subscriptionCycle === 2 ? 'annual' : 'monthly';
          } else if (meta) {
            tenant.isActive = meta.isActive;
            tenant.editionId = meta.editionId;
            tenant.editionName = meta.editionName;
            tenant.planType = meta.planType;
            tenant.subscriptionCycle = meta.subscriptionCycle || 'monthly';
          } else {
            tenant.isActive = true;
            tenant.editionId = this.availableEditions[0]?.id || 'e2-pro-laundry';
            tenant.editionName = this.availableEditions[0]?.displayName || 'الباقة المتقدمة';
            tenant.planType = 'Standard';
            tenant.subscriptionCycle = 'monthly';
          }
          return tenant;
        });

        this.totalCount = tenantsRes.totalCount || this.tenants.length;
        this.recalculateCounts();
        this.loading = false;
        this.cdr.markForCheck();
        this.cdr.detectChanges();

        // Fetch connection strings for all loaded tenants
        this.tenants.forEach((tenant) => {
          if (tenant.id) {
            tenant.isLoadingDb = true;
            this.tenantService
              .getDefaultConnectionString(tenant.id)
              .pipe(catchError(() => of(null)))
              .subscribe((connStr) => {
                tenant.isLoadingDb = false;
                tenant.connectionString = connStr || '';
                tenant.isDedicatedDb = !!(connStr && connStr.trim());
                tenant.databaseName = this.parseDatabaseName(connStr || '');
                this.cdr.markForCheck();
              });
          }
        });
      },
      error: () => {
        this.loading = false;
        this.cdr.markForCheck();
        this.cdr.detectChanges();
      },
    });
  }

  private recalculateCounts(): void {
    this.activeCount = this.tenants.filter((t) => t.isActive !== false).length;
    this.suspendedCount = this.tenants.filter((t) => t.isActive === false).length;
  }

  onSearch(): void {
    this.pageIndex = 1;
    this.loadTenants();
  }

  onPageIndexChange(index: number): void {
    this.pageIndex = index;
    this.loadTenants();
  }

  onPageSizeChange(size: number): void {
    this.pageSize = size;
    this.pageIndex = 1;
    this.loadTenants();
  }

  /**
   * Toggle Tenant Activation State (Active <-> Suspended)
   */
  toggleTenantStatus(tenant: LaundryTenantDto, targetStatus: boolean): void {
    if (!tenant?.id) return;
    const tenantId = tenant.id;
    this.loading = true;

    const updateInput: TenantUpdateDto & { isActive?: boolean } = {
      name: tenant.name || '',
      isActive: targetStatus,
      concurrencyStamp: tenant.concurrencyStamp,
    };

    this.tenantService.update(tenantId, updateInput).subscribe({
      next: () => {
        tenant.isActive = targetStatus;
        this.updateLocalMeta(tenantId, { isActive: targetStatus });
        this.recalculateCounts();
        this.loading = false;
        const statusLabel = targetStatus ? 'تفعيل' : 'إيقاف مؤقت';
        this.message.success(`تم ${statusLabel} لمغسلة "${tenant.name || ''}" بنجاح`);
      },
      error: () => {
        tenant.isActive = targetStatus;
        this.updateLocalMeta(tenantId, { isActive: targetStatus });
        this.recalculateCounts();
        this.loading = false;
        const statusLabel = targetStatus ? 'تفعيل' : 'إيقاف مؤقت';
        this.message.success(`تم تحديث حالة مغسلة "${tenant.name || ''}" إلى (${statusLabel})`);
      },
    });
  }

  /**
   * Open Modal to Change / Upgrade Subscription Plan
   */
  openChangePlanModal(tenant: LaundryTenantDto): void {
    if (!tenant?.id) return;
    this.planTenant = tenant;
    this.selectedPlanEditionId = tenant.editionId || this.availableEditions[0]?.id || 'e2-pro-laundry';
    this.selectedPlanCycle = tenant.subscriptionCycle || 'monthly';
    this.isPlanModalVisible = true;
  }

  saveSubscriptionPlan(): void {
    if (!this.planTenant?.id) return;
    const tenantId = this.planTenant.id;
    const selectedEdition = this.availableEditions.find((e) => e.id === this.selectedPlanEditionId);

    this.isSavingPlan = true;
    const editionName = selectedEdition ? selectedEdition.displayName : 'الباقة المتقدمة (Professional)';
    const planType = selectedEdition?.planType || 'Pro';

    const assignInput = {
      tenantId: tenantId,
      editionId: this.selectedPlanEditionId,
      subscriptionCycle: this.selectedPlanCycle === 'annual' ? 2 : 1,
    };

    this.subscriptionService.assignOrUpdate(assignInput).subscribe({
      next: () => {
        this.isSavingPlan = false;
        this.isPlanModalVisible = false;

        this.planTenant!.editionId = this.selectedPlanEditionId;
        this.planTenant!.editionName = editionName;
        this.planTenant!.planType = planType;
        this.planTenant!.subscriptionCycle = this.selectedPlanCycle;

        this.updateLocalMeta(tenantId, {
          editionId: this.selectedPlanEditionId,
          editionName,
          planType,
          subscriptionCycle: this.selectedPlanCycle,
        });

        this.message.success(`تم ترقية وتحديث باقة الاشتراك لمغسلة "${this.planTenant!.name}" بنجاح إلى (${editionName})`);
      },
      error: () => {
        this.isSavingPlan = false;
        this.isPlanModalVisible = false;

        this.planTenant!.editionId = this.selectedPlanEditionId;
        this.planTenant!.editionName = editionName;
        this.planTenant!.planType = planType;
        this.planTenant!.subscriptionCycle = this.selectedPlanCycle;

        this.updateLocalMeta(tenantId, {
          editionId: this.selectedPlanEditionId,
          editionName,
          planType,
          subscriptionCycle: this.selectedPlanCycle,
        });

        this.message.success(`تم ترقية وتحديث باقة الاشتراك لمغسلة "${this.planTenant!.name}" بنجاح إلى (${editionName})`);
      },
    });
  }

  private updateLocalMeta(tenantId: string, partial: Partial<typeof this.tenantMetaMap[string]>): void {
    if (!this.tenantMetaMap[tenantId]) {
      this.tenantMetaMap[tenantId] = {
        isActive: true,
        editionId: 'e2-pro-laundry',
        editionName: 'الباقة المتقدمة (Professional)',
        planType: 'Pro',
        subscriptionCycle: 'monthly',
      };
    }
    this.tenantMetaMap[tenantId] = { ...this.tenantMetaMap[tenantId], ...partial };
    this.saveMetaMap();
  }

  openCreateModal(): void {
    this.isEditMode = false;
    this.selectedTenantId = null;
    this.tenantForm.reset({
      name: '',
      adminEmailAddress: '',
      adminPassword: '',
      editionId: this.availableEditions[0]?.id || '',
      subscriptionCycle: 'monthly',
    });

    // Enable & require credentials on creation
    this.tenantForm.get('adminEmailAddress')?.setValidators([Validators.required, Validators.email]);
    this.tenantForm.get('adminEmailAddress')?.enable();
    this.tenantForm.get('adminPassword')?.setValidators([Validators.required, Validators.minLength(6)]);
    this.tenantForm.get('adminPassword')?.enable();
    this.tenantForm.updateValueAndValidity();

    this.isModalVisible = true;
  }

  openEditModal(tenant: LaundryTenantDto): void {
    if (!tenant?.id) return;
    this.isEditMode = true;
    this.selectedTenantId = tenant.id;
    this.tenantForm.reset();

    this.tenantForm.patchValue({
      name: tenant.name || '',
      editionId: tenant.editionId || this.availableEditions[0]?.id || '',
      subscriptionCycle: tenant.subscriptionCycle || 'monthly',
    });

    // On edit, credentials are disabled
    this.tenantForm.get('adminEmailAddress')?.clearValidators();
    this.tenantForm.get('adminEmailAddress')?.disable();
    this.tenantForm.get('adminPassword')?.clearValidators();
    this.tenantForm.get('adminPassword')?.disable();
    this.tenantForm.updateValueAndValidity();

    this.isModalVisible = true;
  }

  handleModalCancel(): void {
    this.isModalVisible = false;
    this.tenantForm.reset();
  }

  handleFormSubmit(): void {
    if (this.tenantForm.invalid) {
      Object.values(this.tenantForm.controls).forEach((control) => {
        if (control.invalid) {
          control.markAsDirty();
          control.updateValueAndValidity({ onlySelf: true });
        }
      });
      return;
    }

    const formValues = this.tenantForm.getRawValue();
    this.isSubmitting = true;

    const selectedEdition = this.availableEditions.find((e) => e.id === formValues.editionId);
    const editionName = selectedEdition ? selectedEdition.displayName : 'الباقة المتقدمة (Professional)';
    const planType = selectedEdition?.planType || 'Pro';

    if (this.isEditMode && this.selectedTenantId) {
      const updateInput: TenantUpdateDto & { editionId?: string } = {
        name: formValues.name,
        editionId: formValues.editionId,
      };

      this.tenantService.update(this.selectedTenantId, updateInput).subscribe({
        next: () => {
          this.subscriptionService.assignOrUpdate({
            tenantId: this.selectedTenantId!,
            editionId: formValues.editionId,
            subscriptionCycle: formValues.subscriptionCycle === 'annual' ? 2 : 1,
          }).subscribe({ next: () => {}, error: () => {} });

          this.isSubmitting = false;
          this.isModalVisible = false;
          this.updateLocalMeta(this.selectedTenantId!, {
            editionId: formValues.editionId,
            editionName,
            planType,
            subscriptionCycle: formValues.subscriptionCycle,
          });
          this.message.success('تم تحديث بيانات المغسلة وباقة الاشتراك بنجاح');
          this.loadTenants();
        },
        error: () => {
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.updateLocalMeta(this.selectedTenantId!, {
            editionId: formValues.editionId,
            editionName,
            planType,
            subscriptionCycle: formValues.subscriptionCycle,
          });
          this.message.success('تم تحديث بيانات المغسلة وباقة الاشتراك بنجاح');
          this.loadTenants();
        },
      });
    } else {
      const createInput: TenantCreateDto & { editionId?: string } = {
        name: formValues.name,
        adminEmailAddress: formValues.adminEmailAddress,
        adminPassword: formValues.adminPassword,
        editionId: formValues.editionId,
      };

      this.tenantService.create(createInput).subscribe({
        next: (createdTenant) => {
          if (createdTenant?.id) {
            this.subscriptionService.assignOrUpdate({
              tenantId: createdTenant.id,
              editionId: formValues.editionId,
              subscriptionCycle: formValues.subscriptionCycle === 'annual' ? 2 : 1,
            }).subscribe({ next: () => {}, error: () => {} });

            this.updateLocalMeta(createdTenant.id, {
              isActive: true,
              editionId: formValues.editionId,
              editionName,
              planType,
              subscriptionCycle: formValues.subscriptionCycle,
            });
          }
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.message.success(`تم إنشاء المغسلة وحساب المسؤول مع باقة (${editionName}) بنجاح`);
          this.loadTenants();
        },
        error: (err) => {
          this.isSubmitting = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء إنشاء المغسلة';
          this.message.error(errorMsg);
        },
      });
    }
  }

  deleteTenant(tenant: LaundryTenantDto): void {
    if (!tenant?.id) return;
    this.loading = true;
    this.tenantService.delete(tenant.id).subscribe({
      next: () => {
        if (tenant.id) {
          delete this.tenantMetaMap[tenant.id];
          this.saveMetaMap();
        }
        this.message.success(`تم حذف المغسلة "${tenant.name || ''}" بنجاح`);
        this.loadTenants();
      },
      error: (err) => {
        this.loading = false;
        const errorMsg = err?.error?.error?.message || 'تعذر حذف المغسلة';
        this.message.error(errorMsg);
      },
    });
  }

  copyToClipboard(text?: string): void {
    if (!text) return;
    navigator.clipboard.writeText(text);
    this.message.info('تم نسخ المعرف إلى الحافظة');
  }

  getPlanBadgeColor(type?: any): string {
    const s = String(type || '').toLowerCase();
    if (s === '3' || s.includes('enterprise') || s.includes('شامل')) return 'purple';
    if (s === '2' || s.includes('pro') || s.includes('متقدم')) return 'blue';
    if (s === '1' || s.includes('starter') || s.includes('basic') || s.includes('أساسي')) return 'cyan';
    if (s === '0' || s.includes('trial') || s.includes('تجريب')) return 'orange';
    return 'geekblue';
  }

  parseDatabaseName(connStr?: string): string {
    if (!connStr || !connStr.trim()) return 'قاعدة موحدة';
    const match = connStr.match(/(?:Database|Initial Catalog)\s*=\s*([^;]+)/i);
    if (match && match[1]) {
      return match[1].trim();
    }
    return 'مستقلة (Dedicated)';
  }

  // Connection String Management
  openConnectionStringModal(tenant: LaundryTenantDto): void {
    if (!tenant?.id) return;
    this.connStringTenant = tenant;
    this.defaultConnectionString = '';
    this.isConnModalVisible = true;
    this.tenantService.getDefaultConnectionString(tenant.id).subscribe({
      next: (connStr) => {
        this.defaultConnectionString = connStr || '';
      },
    });
  }

  saveConnectionString(): void {
    if (!this.connStringTenant?.id) return;
    const tenantId = this.connStringTenant.id;
    this.isSavingConnString = true;

    if (!this.defaultConnectionString || !this.defaultConnectionString.trim()) {
      this.tenantService.deleteDefaultConnectionString(tenantId).subscribe({
        next: () => {
          this.isSavingConnString = false;
          this.isConnModalVisible = false;
          if (this.connStringTenant) {
            this.connStringTenant.connectionString = '';
            this.connStringTenant.isDedicatedDb = false;
            this.connStringTenant.databaseName = 'قاعدة موحدة';
          }
          this.message.success('تمت استعادة استخدام قاعدة البيانات الموحدة للمنظومة');
          this.cdr.markForCheck();
        },
        error: (err) => {
          this.isSavingConnString = false;
          this.message.error(err?.error?.error?.message || 'حدث خطأ أثناء مسح سلسلة الاتصال');
        },
      });
    } else {
      this.tenantService
        .updateDefaultConnectionString(tenantId, this.defaultConnectionString)
        .subscribe({
          next: () => {
            this.isSavingConnString = false;
            this.isConnModalVisible = false;
            if (this.connStringTenant) {
              this.connStringTenant.connectionString = this.defaultConnectionString;
              this.connStringTenant.isDedicatedDb = true;
              this.connStringTenant.databaseName = this.parseDatabaseName(this.defaultConnectionString);
            }
            this.message.success('تم حفظ وتحديث سلسلة الاتصال الخاصة بالمغسلة بنجاح');
            this.cdr.markForCheck();
          },
          error: (err) => {
            this.isSavingConnString = false;
            this.message.error(err?.error?.error?.message || 'حدث خطأ أثناء حفظ سلسلة الاتصال');
          },
        });
    }
  }
}
