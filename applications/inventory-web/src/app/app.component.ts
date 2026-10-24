import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';

export interface Product {
  id: number;
  sku: string;
  name: string;
  category: string;
  price: number;
  quantity: number;
  available: boolean;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="header">
      <h2>Nexora Inventory Operations</h2>
      <span class="badge">ENV: {{ envName }}</span>
    </div>
    <div class="container">
      <div class="grid">
        <div class="card"><h3>Total Products</h3><p>{{ products.length }}</p></div>
        <div class="card"><h3>In Stock</h3><p style="color: #16a34a;">{{ inStockCount }}</p></div>
        <div class="card"><h3>Out of Stock</h3><p style="color: #dc2626;">{{ outOfStockCount }}</p></div>
      </div>
      <div class="table-container">
        <table>
          <thead>
            <tr><th>ID</th><th>SKU</th><th>Product Name</th><th>Category</th><th>Price</th><th>Quantity</th><th>Status</th></tr>
          </thead>
          <tbody>
            <tr *ngFor="let p of products">
              <td>{{ p.id }}</td>
              <td>{{ p.sku }}</td>
              <td>{{ p.name }}</td>
              <td>{{ p.category }}</td>
              <td>₹{{ p.price.toLocaleString() }}</td>
              <td>{{ p.quantity }}</td>
              <td><span [style.color]="p.available ? '#16a34a' : '#dc2626'">{{ p.available ? 'In Stock' : 'Out of Stock' }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class AppComponent implements OnInit {
  products: Product[] = [];
  envName = 'DEV';
  inStockCount = 0;
  outOfStockCount = 0;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    const env = (window as any).__env || { apiUrl: 'http://localhost:8101', environmentName: 'DEV' };
    this.envName = env.environmentName;
    this.http.get<Product[]>(`${env.apiUrl}/api/products`).subscribe({
      next: (data) => {
        this.products = data;
        this.inStockCount = data.filter(p => p.available).length;
        this.outOfStockCount = data.filter(p => !p.available).length;
      },
      error: () => {
        // Fallback deterministic sample
        this.products = Array.from({ length: 100 }, (_, i) => ({
          id: i + 1,
          sku: `SKU-${(i + 1).toString().padStart(3, '0')}`,
          name: `Enterprise Asset ${i + 1}`,
          category: 'Hardware',
          price: 50000 + (i * 500),
          quantity: 10,
          available: true
        }));
        this.inStockCount = 100;
        this.outOfStockCount = 0;
      }
    });
  }
}
