import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink, RouterOutlet, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { NzLayoutModule } from 'ng-zorro-antd/layout';
import { NzMenuModule } from 'ng-zorro-antd/menu';
import { NzIconModule } from 'ng-zorro-antd/icon';
import { NzBreadCrumbModule } from 'ng-zorro-antd/breadcrumb';
import { NzDropDownModule } from 'ng-zorro-antd/dropdown';
import { NzAvatarModule } from 'ng-zorro-antd/avatar';
import { NzBadgeModule } from 'ng-zorro-antd/badge';
import { NzTooltipModule } from 'ng-zorro-antd/tooltip';
import { NzButtonModule } from 'ng-zorro-antd/button';
import { NzInputModule } from 'ng-zorro-antd/input';
import { AuthService } from '@abp/ng.core';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterLink,
    RouterOutlet,
    NzLayoutModule,
    NzMenuModule,
    NzIconModule,
    NzBreadCrumbModule,
    NzDropDownModule,
    NzAvatarModule,
    NzBadgeModule,
    NzTooltipModule,
    NzButtonModule,
    NzInputModule,
  ],
  templateUrl: './admin-layout.component.html',
  styleUrls: ['./admin-layout.component.scss'],
})
export class AdminLayoutComponent {
  isCollapsed = false;
  searchQuery = '';
  currentRouteTitle = 'لوحة التحكم والتحليلات';

  // Submenu open states
  laundriesOpen = false;
  systemOpen = false;

  private routeTitles: { [key: string]: string } = {
    '/dashboard': 'لوحة التحكم والتحليلات',
    '/laundries-admin': 'إدارة المغاسل (الجهات)',
    '/laundries': 'إدارة شبكة المغاسل والخدمات',
    '/editions': 'إدارة الباقات والاشتراكات',
    '/editions-admin': 'إدارة الباقات والاشتراكات',
    '/services': 'كتالوج الخدمات والأسعار',
    '/services-catalog': 'كتالوج الخدمات والأسعار',
    '/customers': 'إدارة العملاء والعلاقات',
    '/drivers': 'أسطول المناديب والتوصيل',
    '/orders': 'إدارة الطلبات والشحنات',
    '/identity/users': 'إدارة المستخدمين',
    '/identity/roles': 'الأدوار والصلاحيات',
    '/tenant-management': 'إدارة المغاسل والشركات',
    '/account/manage': 'إدارة الملف الشخصي والحساب',
    '/setting-management': 'إعدادات النظام العامة',
  };

  constructor(
    private router: Router,
    private authService: AuthService
  ) {
    this.router.events
      .pipe(filter((event): event is NavigationEnd => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        const url = event.urlAfterRedirects || event.url;
        this.currentRouteTitle = this.routeTitles[url] || 'لوحة التحكم';
      });
  }

  matchesSearch(text: string): boolean {
    if (!this.searchQuery) return true;
    return text.toLowerCase().includes(this.searchQuery.trim().toLowerCase());
  }

  logout(): void {
    this.authService.logout().subscribe();
  }
}
