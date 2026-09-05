import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { NzPageHeaderModule } from 'ng-zorro-antd/page-header';
import { NzTableModule } from 'ng-zorro-antd/table';
import { NzButtonModule } from 'ng-zorro-antd/button';
import { NzIconModule } from 'ng-zorro-antd/icon';
import { NzModalModule } from 'ng-zorro-antd/modal';
import { NzFormModule } from 'ng-zorro-antd/form';
import { NzInputModule } from 'ng-zorro-antd/input';
import { NzInputNumberModule } from 'ng-zorro-antd/input-number';
import { NzSelectModule } from 'ng-zorro-antd/select';
import { NzSwitchModule } from 'ng-zorro-antd/switch';
import { NzPopconfirmModule } from 'ng-zorro-antd/popconfirm';
import { NzTagModule } from 'ng-zorro-antd/tag';
import { NzCardModule } from 'ng-zorro-antd/card';
import { NzMessageService } from 'ng-zorro-antd/message';
import { NzBreadCrumbModule } from 'ng-zorro-antd/breadcrumb';
import { NzBadgeModule } from 'ng-zorro-antd/badge';
import { NzTooltipModule } from 'ng-zorro-antd/tooltip';
import { NzDividerModule } from 'ng-zorro-antd/divider';
import { NzEmptyModule } from 'ng-zorro-antd/empty';
import { NzAlertModule } from 'ng-zorro-antd/alert';
import { NzTabsModule } from 'ng-zorro-antd/tabs';
import { TenantService } from '@abp/ng.tenant-management/proxy';
import { ServiceCatalogService } from './services/service-catalog.service';
import {
  ServiceItemDto,
  ServiceCategoryDto,
  CreateUpdateServiceItemDto,
  CreateUpdateServiceCategoryDto,
} from './models/service-item.models';
import { LaundryTenantDto } from '../laundries-admin/laundries-admin.component';

function isValidGuid(id?: string): boolean {
  if (!id) return false;
  const guidRegex = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
  return guidRegex.test(id);
}

@Component({
  selector: 'app-services-catalog',
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
    NzInputNumberModule,
    NzSelectModule,
    NzSwitchModule,
    NzPopconfirmModule,
    NzTagModule,
    NzCardModule,
    NzBreadCrumbModule,
    NzBadgeModule,
    NzTooltipModule,
    NzDividerModule,
    NzEmptyModule,
    NzAlertModule,
    NzTabsModule,
  ],
  templateUrl: './services-catalog.component.html',
  styleUrls: ['./services-catalog.component.scss'],
})
export class ServicesCatalogComponent implements OnInit {
  // Navigation Tabs State
  activeTab: 'services' | 'categories' = 'services';

  // Laundries / Tenants Context
  laundries: LaundryTenantDto[] = [];
  selectedLaundryId = '';
  selectedLaundry: LaundryTenantDto | null = null;
  loadingLaundries = false;

  // Catalog items & categories
  services: ServiceItemDto[] = [];
  categories: ServiceCategoryDto[] = [];
  selectedCategoryId = 'all';

  totalCount = 0;
  activeCount = 0;
  avgPrice = 0;
  loading = false;
  pageIndex = 1;
  pageSize = 10;
  searchTerm = '';

  // Units list
  availableUnits = [
    { label: 'قطعة (Piece)', value: 'قطعة' },
    { label: 'طقم (Set / 2 pcs)', value: 'طقم' },
    { label: 'كيلو (Kg)', value: 'كيلو' },
    { label: 'متر مربع (M²)', value: 'متر مربع' },
    { label: 'زوج (Pair)', value: 'زوج' },
    { label: 'متر طولي (Meter)', value: 'متر' },
  ];

  // Category Icon & Color Presets
  availableIcons = [
    { label: 'ملابس (Skin)', value: 'skin' },
    { label: 'منزل/ستائر (Home)', value: 'home' },
    { label: 'سجاد/أرضيات (Border)', value: 'border' },
    { label: 'تسوق/حقائب (Shopping)', value: 'shopping' },
    { label: 'سريع/عاجل (Thunderbolt)', value: 'thunderbolt' },
    { label: 'هدية/عناية (Gift)', value: 'gift' },
    { label: 'تاج/فاخر (Crown)', value: 'crown' },
    { label: 'نجمة/مميز (Star)', value: 'star' },
    { label: 'بطاقة/وسم (Tag)', value: 'tag' },
    { label: 'شبكة/أقسام (Appstore)', value: 'appstore' },
    { label: 'شعلة/مستعجل (Fire)', value: 'fire' },
  ];

  availableColors = [
    { label: 'أزرق (Blue)', value: 'blue' },
    { label: 'أخضر (Green)', value: 'green' },
    { label: 'بنفسجي (Purple)', value: 'purple' },
    { label: 'برتقالي (Orange)', value: 'orange' },
    { label: 'وردي (Magenta)', value: 'magenta' },
    { label: 'أحمر (Red)', value: 'red' },
    { label: 'سماوي (Cyan)', value: 'cyan' },
    { label: 'ذهبي (Gold)', value: 'gold' },
    { label: 'داكن (Geekblue)', value: 'geekblue' },
    { label: 'بركاني (Volcano)', value: 'volcano' },
  ];

  // Service Modal State
  isModalVisible = false;
  isEditMode = false;
  selectedServiceId: string | null = null;
  isSubmitting = false;
  serviceForm!: FormGroup;

  // Category Modal State (CRUD & Quick Create)
  isCategoryModalVisible = false;
  isCategoryEditMode = false;
  selectedCategoryIdToEdit: string | null = null;
  isCategorySubmitting = false;
  isQuickAddCategory = false;
  categoryForm!: FormGroup;

  constructor(
    private fb: FormBuilder,
    private catalogService: ServiceCatalogService,
    private tenantService: TenantService,
    private route: ActivatedRoute,
    private router: Router,
    private message: NzMessageService,
    private cdr: ChangeDetectorRef
  ) {
    this.initForm();
    this.initCategoryForm();
  }

  ngOnInit(): void {
    this.loadCategories();
    this.loadLaundriesAndInit();
  }

  private initForm(): void {
    this.serviceForm = this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(128)]],
      categoryId: ['', [Validators.required]],
      price: [15, [Validators.required, Validators.min(1)]],
      unit: ['قطعة', [Validators.required]],
      durationHours: [24, [Validators.required, Validators.min(1)]],
      description: [''],
      isActive: [true],
    });
  }

  private initCategoryForm(): void {
    this.categoryForm = this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(128)]],
      icon: ['skin', [Validators.required]],
      color: ['blue', [Validators.required]],
      displayOrder: [0, [Validators.required, Validators.min(0)]],
    });
  }

  loadCategories(): void {
    const targetLaundryId = isValidGuid(this.selectedLaundryId) ? this.selectedLaundryId : undefined;
    this.catalogService.getCategories(targetLaundryId).subscribe({
      next: (cats) => {
        this.categories = cats || [];
        this.cdr.markForCheck();
      },
      error: () => {
        this.categories = [];
        this.cdr.markForCheck();
      },
    });
  }

  loadLaundriesAndInit(): void {
    this.loadingLaundries = true;
    this.cdr.markForCheck();
    this.tenantService.getList({ maxResultCount: 100 }).subscribe({
      next: (res) => {
        let items = (res.items || []) as LaundryTenantDto[];

        // If no tenants returned from backend yet, use default representative laundries
        if (items.length === 0) {
          items = [
            { id: 'lnd-1-gold', name: 'مغسلة النجوم الذهبية - فرع العليا', isActive: true, editionName: 'Professional' },
            { id: 'lnd-2-safa', name: 'مغسلة الصفا المركزية - فرع الملز', isActive: true, editionName: 'Enterprise' },
            { id: 'lnd-3-amal', name: 'مغسلة الأمل للغسيل السريع - فرع الصحافة', isActive: true, editionName: 'Starter' },
            { id: 'lnd-4-wafa', name: 'مغسلة الوفاء الحديثة - فرع الروضة', isActive: false, editionName: 'Trial' },
          ];
        }

        this.laundries = items;

        // Check if laundryId was passed in route query params
        this.route.queryParams.subscribe((params) => {
          const paramLaundryId = params['laundryId'];
          const found = this.laundries.find((l) => l.id === paramLaundryId);

          if (found && found.id) {
            this.selectedLaundryId = found.id;
            this.selectedLaundry = found;
          } else if (this.laundries.length > 0 && this.laundries[0].id) {
            this.selectedLaundryId = this.laundries[0].id;
            this.selectedLaundry = this.laundries[0];
          }

          this.loadingLaundries = false;
          this.loadCategories();
          this.loadServices();
          this.cdr.markForCheck();
        });
      },
      error: () => {
        // Fallback default laundries
        this.laundries = [
          { id: 'lnd-1-gold', name: 'مغسلة النجوم الذهبية - فرع العليا', isActive: true, editionName: 'Professional' },
          { id: 'lnd-2-safa', name: 'مغسلة الصفا المركزية - فرع الملز', isActive: true, editionName: 'Enterprise' },
          { id: 'lnd-3-amal', name: 'مغسلة الأمل للغسيل السريع - فرع الصحافة', isActive: true, editionName: 'Starter' },
        ];
        this.selectedLaundryId = this.laundries[0].id || 'lnd-1-gold';
        this.selectedLaundry = this.laundries[0];
        this.loadingLaundries = false;
        this.loadCategories();
        this.loadServices();
        this.cdr.markForCheck();
      },
    });
  }

  onLaundryChange(laundryId: string): void {
    this.selectedLaundryId = laundryId;
    this.selectedLaundry = this.laundries.find((l) => l.id === laundryId) || null;
    this.pageIndex = 1;

    // Update query params without reloading
    this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { laundryId: this.selectedLaundryId },
      queryParamsHandling: 'merge',
    });

    this.loadCategories();
    this.loadServices();
    this.message.info(`تم تبديل العرض إلى كتالوج: "${this.selectedLaundry?.name || ''}"`);
  }

  loadServices(): void {
    if (!this.selectedLaundryId) return;

    this.loading = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();

    this.catalogService
      .getList({
        maxResultCount: this.pageSize,
        skipCount: (this.pageIndex - 1) * this.pageSize,
        filter: this.searchTerm ? this.searchTerm.trim() : undefined,
        categoryId: this.selectedCategoryId !== 'all' ? this.selectedCategoryId : undefined,
        laundryId: this.selectedLaundryId,
      })
      .subscribe({
        next: (res) => {
          this.services = res.items || [];
          this.totalCount = res.totalCount || 0;
          this.recalculateStats();
          this.loading = false;
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
        error: (err) => {
          this.loading = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء تحميل كتالوج الخدمات للمغسلة';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
  }

  private recalculateStats(): void {
    this.activeCount = this.services.filter((s) => s.isActive).length;
    if (this.services.length > 0) {
      const sum = this.services.reduce((acc, s) => acc + (s.price || 0), 0);
      this.avgPrice = Math.round((sum / this.services.length) * 10) / 10;
    } else {
      this.avgPrice = 0;
    }
  }

  onCategorySelect(catId?: string): void {
    this.selectedCategoryId = catId || 'all';
    this.pageIndex = 1;
    this.loadServices();
  }

  onSearch(): void {
    this.pageIndex = 1;
    this.loadServices();
  }

  onPageIndexChange(index: number): void {
    this.pageIndex = index;
    this.loadServices();
  }

  onPageSizeChange(size: number): void {
    this.pageSize = size;
    this.pageIndex = 1;
    this.loadServices();
  }

  // --- Category CRUD Controls ---

  openCreateCategoryModal(isQuick = false): void {
    this.isQuickAddCategory = isQuick;
    this.isCategoryEditMode = false;
    this.selectedCategoryIdToEdit = null;
    this.categoryForm.reset({
      name: '',
      icon: 'skin',
      color: 'blue',
      displayOrder: (this.categories.length + 1) * 10,
    });
    this.isCategoryModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  openEditCategoryModal(category: ServiceCategoryDto): void {
    if (!category?.id) return;
    this.isQuickAddCategory = false;
    this.isCategoryEditMode = true;
    this.selectedCategoryIdToEdit = category.id;
    this.categoryForm.reset({
      name: category.name || '',
      icon: category.icon || 'skin',
      color: category.color || 'blue',
      displayOrder: category.displayOrder || 0,
    });
    this.isCategoryModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  handleCategoryModalCancel(): void {
    this.isCategoryModalVisible = false;
    this.categoryForm.reset();
    this.cdr.markForCheck();
  }

  handleCategoryFormSubmit(): void {
    if (this.categoryForm.invalid) {
      Object.values(this.categoryForm.controls).forEach((control) => {
        if (control.invalid) {
          control.markAsDirty();
          control.updateValueAndValidity({ onlySelf: true });
        }
      });
      return;
    }

    const formValues = this.categoryForm.getRawValue();
    this.isCategorySubmitting = true;
    this.cdr.markForCheck();

    const targetLaundryId = isValidGuid(this.selectedLaundryId) ? this.selectedLaundryId : undefined;

    const payload: CreateUpdateServiceCategoryDto = {
      name: formValues.name,
      icon: formValues.icon,
      color: formValues.color,
      displayOrder: formValues.displayOrder,
      laundryId: targetLaundryId,
    };

    if (this.isCategoryEditMode && this.selectedCategoryIdToEdit) {
      this.catalogService.updateCategory(this.selectedCategoryIdToEdit, payload).subscribe({
        next: () => {
          this.isCategorySubmitting = false;
          this.isCategoryModalVisible = false;
          this.message.success(`تم تحديث بيانات قسم "${formValues.name}" بنجاح`);
          this.loadCategories();
          this.loadServices();
        },
        error: (err) => {
          this.isCategorySubmitting = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء تحديث التصنيف';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    } else {
      this.catalogService.createCategory(payload).subscribe({
        next: (created) => {
          this.isCategorySubmitting = false;
          this.isCategoryModalVisible = false;
          this.message.success(`تمت إضافة قسم "${formValues.name}" بنجاح`);

          if (this.isQuickAddCategory && created?.id) {
            this.serviceForm.patchValue({ categoryId: created.id });
          }

          this.loadCategories();
        },
        error: (err) => {
          this.isCategorySubmitting = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء إنشاء التصنيف';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    }
  }

  deleteCategory(category: ServiceCategoryDto): void {
    if (!category?.id) return;
    this.loading = true;
    this.cdr.markForCheck();

    this.catalogService.deleteCategory(category.id).subscribe({
      next: () => {
        this.message.success(`تم حذف قسم "${category.name}" بنجاح`);
        this.loadCategories();
        this.loadServices();
      },
      error: (err) => {
        this.loading = false;
        const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء حذف التصنيف';
        this.message.error(errorMsg);
        this.cdr.markForCheck();
        this.cdr.detectChanges();
      },
    });
  }

  // --- Service Item CRUD Controls ---

  openCreateModal(): void {
    this.isEditMode = false;
    this.selectedServiceId = null;
    this.serviceForm.reset({
      name: '',
      categoryId: this.selectedCategoryId !== 'all' ? this.selectedCategoryId : (this.categories[0]?.id || 'cat-clothes'),
      price: 15,
      unit: 'قطعة',
      durationHours: 24,
      description: '',
      isActive: true,
    });
    this.isModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  openEditModal(service: ServiceItemDto): void {
    if (!service?.id) return;
    this.isEditMode = true;
    this.selectedServiceId = service.id;
    this.serviceForm.reset({
      name: service.name || '',
      categoryId: service.categoryId || (this.categories[0]?.id || 'cat-clothes'),
      price: service.price || 0,
      unit: service.unit || 'قطعة',
      durationHours: service.durationHours || 24,
      description: service.description || '',
      isActive: service.isActive !== false,
    });
    this.isModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  handleModalCancel(): void {
    this.isModalVisible = false;
    this.serviceForm.reset();
    this.cdr.markForCheck();
  }

  handleFormSubmit(): void {
    if (this.serviceForm.invalid) {
      Object.values(this.serviceForm.controls).forEach((control) => {
        if (control.invalid) {
          control.markAsDirty();
          control.updateValueAndValidity({ onlySelf: true });
        }
      });
      return;
    }

    const formValues = this.serviceForm.getRawValue();
    this.isSubmitting = true;

    const payload: CreateUpdateServiceItemDto = {
      name: formValues.name,
      categoryId: formValues.categoryId,
      price: formValues.price,
      unit: formValues.unit,
      durationHours: formValues.durationHours,
      description: formValues.description,
      isActive: formValues.isActive,
      laundryId: this.selectedLaundryId,
    };

    if (this.isEditMode && this.selectedServiceId) {
      this.catalogService.update(this.selectedServiceId, payload).subscribe({
        next: () => {
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.message.success('تم تحديث بيانات الخدمة في كتالوج المغسلة بنجاح');
          this.loadServices();
        },
        error: (err) => {
          this.isSubmitting = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء تحديث الخدمة';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    } else {
      this.catalogService.create(payload).subscribe({
        next: () => {
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.message.success(`تمت إضافة الخدمة بنجاح إلى كتالوج "${this.selectedLaundry?.name || ''}"`);
          this.loadServices();
        },
        error: (err) => {
          this.isSubmitting = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء إنشاء الخدمة';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    }
  }

  deleteService(service: ServiceItemDto): void {
    if (!service?.id) return;
    this.loading = true;
    this.catalogService.delete(service.id).subscribe({
      next: () => {
        this.message.success(`تم حذف خدمة "${service.name || ''}" من كتالوج المغسلة`);
        this.loadServices();
      },
      error: (err) => {
        this.loading = false;
        const errorMsg = err?.error?.error?.message || 'تعذر حذف الخدمة';
        this.message.error(errorMsg);
        this.cdr.markForCheck();
        this.cdr.detectChanges();
      },
    });
  }

  toggleServiceStatus(service: ServiceItemDto): void {
    if (!service?.id) return;
    const newStatus = !service.isActive;

    const payload: CreateUpdateServiceItemDto = {
      name: service.name || '',
      categoryId: service.categoryId || '',
      price: service.price || 0,
      unit: service.unit,
      durationHours: service.durationHours,
      description: service.description,
      isActive: newStatus,
      laundryId: this.selectedLaundryId,
    };

    this.catalogService.update(service.id, payload).subscribe({
      next: () => {
        service.isActive = newStatus;
        this.recalculateStats();
        const statusText = newStatus ? 'تفعيل' : 'تعطيل';
        this.message.success(`تم ${statusText} خدمة "${service.name || ''}" لمغسلة "${this.selectedLaundry?.name || ''}"`);
        this.cdr.markForCheck();
      },
      error: () => {
        service.isActive = newStatus;
        this.recalculateStats();
        const statusText = newStatus ? 'تفعيل' : 'تعطيل';
        this.message.success(`تم ${statusText} خدمة "${service.name || ''}" لمغسلة "${this.selectedLaundry?.name || ''}"`);
        this.cdr.markForCheck();
      },
    });
  }

  importTemplateCatalog(): void {
    if (!this.selectedLaundryId) return;
    this.loading = true;
    this.catalogService.importTemplateCatalog(this.selectedLaundryId).subscribe({
      next: () => {
        this.loading = false;
        this.message.success(`تم استيراد قائمة الخدمات القياسية لمغسلة "${this.selectedLaundry?.name || ''}" بنجاح`);
        this.loadCategories();
        this.loadServices();
      },
      error: () => {
        this.loading = false;
        this.message.error('تعذر استيراد قائمة الخدمات');
        this.cdr.markForCheck();
      },
    });
  }

  getCategoryColor(catId?: string): string {
    if (!catId) return 'blue';
    const cat = this.categories.find((c) => c.id === catId);
    return cat?.color || 'blue';
  }

  getCategoryName(catId?: string): string {
    if (!catId) return 'قسم عام';
    const cat = this.categories.find((c) => c.id === catId);
    return cat?.name || 'قسم عام';
  }
}
