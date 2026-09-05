import { Component, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NzGridModule } from 'ng-zorro-antd/grid';
import { NzCardModule } from 'ng-zorro-antd/card';
import { NzStatisticModule } from 'ng-zorro-antd/statistic';
import { NzIconModule } from 'ng-zorro-antd/icon';
import { NzTableModule } from 'ng-zorro-antd/table';
import { NzTagModule } from 'ng-zorro-antd/tag';
import { NzButtonModule } from 'ng-zorro-antd/button';
import { NzSelectModule } from 'ng-zorro-antd/select';
import { NzRadioModule } from 'ng-zorro-antd/radio';
import { NzProgressModule } from 'ng-zorro-antd/progress';
import { NzRateModule } from 'ng-zorro-antd/rate';
import { NzAvatarModule } from 'ng-zorro-antd/avatar';
import { NzListModule } from 'ng-zorro-antd/list';
import { NzTooltipModule } from 'ng-zorro-antd/tooltip';
import { NzBadgeModule } from 'ng-zorro-antd/badge';
import { NgApexchartsModule, ChartComponent, ApexAxisChartSeries, ApexChart, ApexXAxis, ApexDataLabels, ApexStroke, ApexYAxis, ApexTitleSubtitle, ApexLegend, ApexFill, ApexTooltip, ApexNonAxisChartSeries, ApexResponsive } from 'ng-apexcharts';

export type AreaChartOptions = {
  series: ApexAxisChartSeries;
  chart: ApexChart;
  xaxis: ApexXAxis;
  stroke: ApexStroke;
  dataLabels: ApexDataLabels;
  yaxis: ApexYAxis;
  title: ApexTitleSubtitle;
  labels: string[];
  legend: ApexLegend;
  fill: ApexFill;
  tooltip: ApexTooltip;
  colors: string[];
};

export type DonutChartOptions = {
  series: ApexNonAxisChartSeries;
  chart: ApexChart;
  responsive: ApexResponsive[];
  labels: string[];
  colors: string[];
  legend: ApexLegend;
  dataLabels: ApexDataLabels;
  tooltip: ApexTooltip;
};

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    NzGridModule,
    NzCardModule,
    NzStatisticModule,
    NzIconModule,
    NzTableModule,
    NzTagModule,
    NzButtonModule,
    NzSelectModule,
    NzRadioModule,
    NzProgressModule,
    NzRateModule,
    NzAvatarModule,
    NzListModule,
    NzTooltipModule,
    NzBadgeModule,
    NgApexchartsModule,
  ],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss'],
})
export class HomeComponent {
  @ViewChild('areaChart') areaChart!: ChartComponent;
  @ViewChild('donutChart') donutChart!: ChartComponent;

  selectedPeriod: 'today' | 'week' | 'month' | 'year' = 'month';
  selectedLaundry: string = 'all';

  // Revenue Area Chart Configuration
  public areaChartOptions: AreaChartOptions = {
    series: [
      {
        name: 'إجمالي المبيعات (ر.س)',
        data: [12400, 15800, 14200, 19500, 22100, 27400, 31200, 35800, 39400, 43200, 48500],
      },
      {
        name: 'عدد الطلبات',
        data: [420, 510, 480, 620, 710, 890, 940, 1120, 1280, 1410, 1540],
      },
    ],
    chart: {
      type: 'area',
      height: 320,
      toolbar: { show: false },
      fontFamily: 'Cairo, sans-serif',
    },
    colors: ['#1890ff', '#52c41a'],
    dataLabels: { enabled: false },
    stroke: { curve: 'smooth', width: 3 },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.45,
        opacityTo: 0.05,
        stops: [0, 90, 100],
      },
    },
    xaxis: {
      categories: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر'],
    },
    yaxis: {
      labels: {
        formatter: (val) => val.toLocaleString('ar-SA'),
      },
    },
    title: { text: '' },
    labels: [],
    legend: { position: 'top', horizontalAlign: 'right' },
    tooltip: {
      theme: 'light',
      x: { show: true },
    },
  };

  // Donut Chart for Order Statuses
  public donutChartOptions: DonutChartOptions = {
    series: [1196, 331, 184, 129],
    chart: {
      type: 'donut',
      height: 300,
      fontFamily: 'Cairo, sans-serif',
    },
    labels: ['مكتمل وسليم', 'قيد الغسيل والمعالجة', 'جاري التوصيل للعميل', 'بانتظار استلام المندوب'],
    colors: ['#52c41a', '#1890ff', '#13c2c2', '#fa8c16'],
    dataLabels: { enabled: true },
    legend: { position: 'bottom' },
    responsive: [
      {
        breakpoint: 480,
        options: {
          chart: { width: 280 },
          legend: { position: 'bottom' },
        },
      },
    ],
    tooltip: { theme: 'light' },
  };

  // Customer Surveys & Feedback Ratings Breakdown
  surveysData = [
    { title: 'جودة الغسيل والكي والتنظيف الجاف', score: 96, rating: 4.9, count: 420 },
    { title: 'التغليف، النظافة، والأمان', score: 94, rating: 4.8, count: 395 },
    { title: 'التزام وحسن تعامل المناديب', score: 92, rating: 4.7, count: 380 },
    { title: 'سرعة ودقة التوصيل في الموعد', score: 89, rating: 4.6, count: 410 },
  ];

  // Recent Customer Feedbacks & Reviews
  customerReviews = [
    { name: 'عبدالرحمن الشهري', laundry: 'مغسلة الصفا الممتازة', rating: 5, time: 'منذ 10 دقائق', comment: 'خدمة سريعة جداً وتغليف رائع للملابس الرسمية. أنصح بهم بشدة!' },
    { name: 'منيرة السبيعي', laundry: 'مغسلة النجوم الذكية', rating: 5, time: 'منذ 25 دقيقة', comment: 'وصل المندوب في الوقت المحدد تماماً، والكي بالبخار احترافي للغاية.' },
    { name: 'فهد العتيبي', laundry: 'مغسلة الأمل الحديثة', rating: 4, time: 'منذ ساعة', comment: 'خدمة ممتازة ونظافة عالية، شكراً لفريق الدعم والمناديب.' },
  ];

  // Top Performing Laundries
  topLaundries = [
    { name: 'مغسلة الصفا المركزية', city: 'الرياض - حي الملز', revenue: 14850, orders: 480, rating: 4.9, status: 'نشطة' },
    { name: 'مغسلة النجوم الذهبية', city: 'جدة - حي الروضة', revenue: 12300, orders: 390, rating: 4.8, status: 'نشطة' },
    { name: 'مغسلة الأمل للغسيل السريع', city: 'الرياض - حي الصحافة', revenue: 10400, orders: 310, rating: 4.7, status: 'نشطة' },
    { name: 'مغسلة الوفاء الحديثة', city: 'الدمام - حي الشاطئ', revenue: 8950, orders: 260, rating: 4.6, status: 'مزدحمة' },
  ];

  // Active Drivers Fleet
  driversStatus = {
    available: 14,
    delivering: 8,
    offline: 3,
    total: 25,
  };

  onPeriodChange(): void {
    // Dynamically adjust chart data according to period
    if (this.selectedPeriod === 'today') {
      this.areaChartOptions.series = [
        { name: 'إجمالي المبيعات (ر.س)', data: [1200, 2400, 3100, 4800, 5200, 6800] },
        { name: 'عدد الطلبات', data: [15, 30, 42, 65, 78, 92] },
      ];
    } else if (this.selectedPeriod === 'week') {
      this.areaChartOptions.series = [
        { name: 'إجمالي المبيعات (ر.س)', data: [6800, 7200, 8400, 9100, 10500, 11800, 14200] },
        { name: 'عدد الطلبات', data: [110, 130, 145, 160, 185, 210, 240] },
      ];
    } else {
      this.areaChartOptions.series = [
        { name: 'إجمالي المبيعات (ر.س)', data: [12400, 15800, 14200, 19500, 22100, 27400, 31200, 35800, 39400, 43200, 48500] },
        { name: 'عدد الطلبات', data: [420, 510, 480, 620, 710, 890, 940, 1120, 1280, 1410, 1540] },
      ];
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'نشطة': return 'success';
      case 'مزدحمة': return 'warning';
      default: return 'default';
    }
  }
}
