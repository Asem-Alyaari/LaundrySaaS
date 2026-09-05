import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
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
import { RouterModule } from '@angular/router';
import { EditionService } from './services/edition.service';
import { EditionDto, EditionCreateDto, EditionUpdateDto } from './models/edition.models';

@Component({
  selector: 'app-editions-admin',
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
  ],
  templateUrl: './editions-admin.component.html',
  styleUrls: ['./editions-admin.component.scss'],
})
export class EditionsAdminComponent implements OnInit {
  editions: EditionDto[] = [];
  totalCount = 0;
  loading = false;
  pageIndex = 1;
  pageSize = 10;
  searchTerm = '';

  // Modal State
  isModalVisible = false;
  isEditMode = false;
  selectedEditionId: string | null = null;
  isSubmitting = false;
  editionForm!: FormGroup;

  constructor(
    private fb: FormBuilder,
    private editionService: EditionService,
    private message: NzMessageService,
    private cdr: ChangeDetectorRef
  ) {
    this.initForm();
  }

  ngOnInit(): void {
    this.loadEditions();
  }

  private initForm(): void {
    this.editionForm = this.fb.group({
      displayName: ['', [Validators.required, Validators.maxLength(128)]],
      planType: ['Pro', [Validators.required]],
      price: [299, [Validators.required, Validators.min(0)]],
      annualPrice: [2990, [Validators.min(0)]],
      isFree: [false],
    });

    // Auto update prices when free toggle is switched
    this.editionForm.get('isFree')?.valueChanges.subscribe((isFree: boolean) => {
      if (isFree) {
        this.editionForm.patchValue({ price: 0, annualPrice: 0 });
        this.editionForm.get('price')?.disable();
        this.editionForm.get('annualPrice')?.disable();
      } else {
        this.editionForm.get('price')?.enable();
        this.editionForm.get('annualPrice')?.enable();
      }
      this.cdr.markForCheck();
    });
  }

  loadEditions(): void {
    this.loading = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();

    this.editionService
      .getList({
        maxResultCount: this.pageSize,
        skipCount: (this.pageIndex - 1) * this.pageSize,
        filter: this.searchTerm ? this.searchTerm.trim() : undefined,
      })
      .subscribe({
        next: (res) => {
          this.editions = res.items || [];
          this.totalCount = res.totalCount || this.editions.length;
          this.loading = false;
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
        error: (err) => {
          this.loading = false;
          const errorMsg = err?.error?.error?.message || 'حدث خطأ أثناء تحميل الباقات الحقيقية من الخادم';
          this.message.error(errorMsg);
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
  }

  onSearch(): void {
    this.pageIndex = 1;
    this.loadEditions();
  }

  onPageIndexChange(index: number): void {
    this.pageIndex = index;
    this.loadEditions();
  }

  onPageSizeChange(size: number): void {
    this.pageSize = size;
    this.pageIndex = 1;
    this.loadEditions();
  }

  openCreateModal(): void {
    this.isEditMode = false;
    this.selectedEditionId = null;
    this.editionForm.reset({
      displayName: '',
      planType: 'Pro',
      price: 299,
      annualPrice: 2990,
      isFree: false,
    });
    this.editionForm.get('price')?.enable();
    this.editionForm.get('annualPrice')?.enable();
    this.isModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  openEditModal(edition: EditionDto): void {
    if (!edition?.id) return;
    this.isEditMode = true;
    this.selectedEditionId = edition.id;
    this.editionForm.reset({
      displayName: edition.displayName,
      planType: this.normalizePlanType(edition.planType),
      price: edition.price ?? 0,
      annualPrice: edition.annualPrice ?? 0,
      isFree: edition.isFree || false,
    });

    if (edition.isFree) {
      this.editionForm.get('price')?.disable();
      this.editionForm.get('annualPrice')?.disable();
    } else {
      this.editionForm.get('price')?.enable();
      this.editionForm.get('annualPrice')?.enable();
    }

    this.isModalVisible = true;
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  handleModalCancel(): void {
    this.isModalVisible = false;
    this.editionForm.reset();
    this.cdr.markForCheck();
    this.cdr.detectChanges();
  }

  handleFormSubmit(): void {
    if (this.editionForm.invalid) {
      Object.values(this.editionForm.controls).forEach((control) => {
        if (control.invalid) {
          control.markAsDirty();
          control.updateValueAndValidity({ onlySelf: true });
        }
      });
      return;
    }

    const formValues = this.editionForm.getRawValue();
    this.isSubmitting = true;
    this.cdr.markForCheck();

    if (this.isEditMode && this.selectedEditionId) {
      const updateInput: EditionUpdateDto = {
        displayName: formValues.displayName,
        planType: formValues.planType,
        price: formValues.price,
        annualPrice: formValues.annualPrice,
        isFree: formValues.isFree,
      };

      this.editionService.update(this.selectedEditionId, updateInput).subscribe({
        next: () => {
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.message.success('تم تحديث بيانات الباقة بنجاح');
          this.loadEditions();
        },
        error: (err) => {
          this.isSubmitting = false;
          this.message.error(err?.error?.error?.message || 'حدث خطأ أثناء تعديل الباقة');
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    } else {
      const createInput: EditionCreateDto = {
        displayName: formValues.displayName,
        planType: formValues.planType,
        price: formValues.price,
        annualPrice: formValues.annualPrice,
        isFree: formValues.isFree,
      };

      this.editionService.create(createInput).subscribe({
        next: () => {
          this.isSubmitting = false;
          this.isModalVisible = false;
          this.message.success('تمت إضافة الباقة الجديدة بنجاح');
          this.loadEditions();
        },
        error: (err) => {
          this.isSubmitting = false;
          this.message.error(err?.error?.error?.message || 'حدث خطأ أثناء إنشاء الباقة');
          this.cdr.markForCheck();
          this.cdr.detectChanges();
        },
      });
    }
  }

  deleteEdition(edition: EditionDto): void {
    if (!edition?.id) return;
    this.loading = true;
    this.cdr.markForCheck();

    this.editionService.delete(edition.id).subscribe({
      next: () => {
        this.message.success(`تم حذف باقة "${edition.displayName}" بنجاح`);
        this.loadEditions();
      },
      error: (err) => {
        this.loading = false;
        this.message.error(err?.error?.error?.message || `تعذر حذف باقة "${edition.displayName}"`);
        this.cdr.markForCheck();
        this.cdr.detectChanges();
      },
    });
  }

  normalizePlanType(type: any): string {
    if (type === 0 || type === '0' || String(type).toLowerCase() === 'trial') return 'trial';
    if (type === 1 || type === '1' || String(type).toLowerCase() === 'basic') return 'basic';
    if (type === 2 || type === '2' || String(type).toLowerCase() === 'pro') return 'pro';
    if (type === 3 || type === '3' || String(type).toLowerCase() === 'enterprise') return 'enterprise';
    return String(type ?? '').toLowerCase();
  }

  getPlanTypeColor(type?: any): string {
    const normalized = this.normalizePlanType(type);
    switch (normalized) {
      case 'enterprise':
        return 'purple';
      case 'pro':
        return 'geekblue';
      case 'basic':
        return 'blue';
      case 'trial':
        return 'orange';
      default:
        return 'default';
    }
  }

  getPlanTypeName(type?: any): string {
    const normalized = this.normalizePlanType(type);
    switch (normalized) {
      case 'enterprise':
        return 'مؤسسات وسلاسل';
      case 'pro':
        return 'متقدمة Pro';
      case 'basic':
        return 'أساسية Starter';
      case 'trial':
        return 'تجريبية Trial';
      default:
        return 'باقة مخصصة';
    }
  }
}
