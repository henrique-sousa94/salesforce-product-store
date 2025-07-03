import { LightningElement, track } from 'lwc';
import importProducts from '@salesforce/apex/ProductImporter.importProducts';
import getProducts from '@salesforce/apex/ProductImporter.getProducts';
import getExistingCategories from '@salesforce/apex/ProductImporter.getExistingCategories';
import getExistingBrands from '@salesforce/apex/ProductImporter.getExistingBrands';

export default class ProductStore extends LightningElement {
    @track products = [];
    @track categoryOptions = [];
    @track brandOptions = [];
    @track selectedCategory = '';
    @track selectedBrand = '';
    @track nameFilter = '';
    @track loading = false;
    @track totalStock = 0;

    connectedCallback() {
        this.loadAllData();
    }

    async loadAllData() {
        this.loading = true;
        try {
            const categories = await getExistingCategories();
            this.categoryOptions = [{ label: 'None', value: '' }, ...categories.map(c => ({ label: c, value: c }))];

            const brands = await getExistingBrands();
            this.brandOptions = [{ label: 'None', value: '' }, ...brands.map(b => ({ label: b, value: b }))];

            await this.loadFilteredProducts();
        } catch (error) {
            console.error('Error loading data:', JSON.stringify(error));
        } finally {
            this.loading = false;
        }
    }


    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.loadFilteredProducts();
    }

    handleBrandChange(event) {
        this.selectedBrand = event.detail.value;
        this.loadFilteredProducts();
    }

    handleNameInput(event) {
        this.nameFilter = event.target.value;
    }

    async loadFilteredProducts() {
        this.loading = true;
        try {
            const data = await getProducts({
                categoryFilter: this.selectedCategory || '',
                brandFilter: this.selectedBrand || '',
                nameFilter: this.nameFilter || ''
            });
            this.products = data;

            // Calculate total of Stock
            this.totalStock = this.products.reduce((sum, p) => sum + (p.Stock || 0), 0);
        } catch (error) {
            console.error('Error loading products:', JSON.stringify(error));
        } finally {
            this.loading = false;
        }
    }


    async refreshProducts() {
        this.loading = true;
        try {
            await importProducts();
            await this.loadFilteredProducts();
        } catch (error) {
            console.error('Error refreshing products:', JSON.stringify(error));
        } finally {
            this.loading = false;
        }
    }
}
