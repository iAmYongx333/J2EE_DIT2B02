<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics – SilverCare</title>

    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        String userRoleString = userRole.toString();
        if (!"admin".equals(userRoleString)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }
    %>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
    tailwind.config = {
        theme: {
            extend: {
                fontFamily: {
                    serif: ['Cormorant', 'Georgia', 'serif'],
                    sans: ['Outfit', 'system-ui', 'sans-serif'],
                },
                colors: {
                    stone: { warm: '#f5f3ef', mid: '#e8e4dc', deep: '#d4cec3' },
                    ink: { DEFAULT: '#2c2c2c', light: '#5a5a5a', muted: '#8a8a8a' },
                    copper: { DEFAULT: '#b87a4b', light: '#d4a574' },
                }
            }
        }
    }
    </script>
    <style>
    html { scroll-behavior: smooth; }
    body { -webkit-font-smoothing: antialiased; }

    .loader {
        position: fixed; inset: 0; background: #f5f3ef;
        display: flex; align-items: center; justify-content: center;
        z-index: 9999; transition: opacity 0.5s ease, visibility 0.5s ease;
    }
    .loader.hidden { opacity: 0; visibility: hidden; }
    .loader-bar {
        width: 120px; height: 2px; background: #e8e4dc; overflow: hidden;
    }
    .loader-bar::after {
        content: ''; display: block; width: 40%; height: 100%;
        background: #2c2c2c; animation: loadingBar 1s ease-in-out infinite;
    }
    @keyframes loadingBar {
        0% { transform: translateX(-100%); }
        100% { transform: translateX(350%); }
    }

    .page-content { opacity: 0; transition: opacity 0.6s ease; }
    .page-content.visible { opacity: 1; }

    .report-card {
        transition: transform 0.2s ease, border-color 0.2s ease;
        cursor: pointer;
    }
    .report-card:hover {
        transform: translateY(-2px);
        border-color: #2c2c2c;
    }

    .tab-btn {
        transition: all 0.2s ease;
    }
    .tab-btn.active {
        background-color: #2c2c2c;
        color: #f5f3ef;
    }

    .data-table {
        width: 100%;
        border-collapse: collapse;
    }
    .data-table th {
        background-color: #e8e4dc;
        padding: 12px;
        text-align: left;
        font-weight: 500;
        border-bottom: 2px solid #2c2c2c;
    }
    .data-table td {
        padding: 12px;
        border-bottom: 1px solid #e8e4dc;
    }
    .data-table tr:hover {
        background-color: #f5f3ef;
    }
    </style>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <!-- Loading Screen -->
    <div class="loader" id="loader">
        <div class="text-center">
            <p class="font-serif text-2xl text-ink mb-6">SilverCare</p>
            <div class="loader-bar"></div>
        </div>
    </div>

    <div class="page-content" id="pageContent">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-7xl mx-auto">

            <!-- Page Header -->
            <header class="mb-12">
                <span class="text-copper text-xs uppercase tracking-[0.2em]">Administration</span>
                <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4">
                    Reports & Analytics
                </h1>
                <p class="text-ink-light text-base md:text-lg max-w-2xl">
                    Comprehensive reporting and insights for service management, customer analytics, and sales performance.
                </p>
            </header>

            <!-- Report Categories -->
            <div class="mb-8">
                <div class="flex gap-4 flex-wrap">
                    <button onclick="showReportSection('services')" class="tab-btn active px-6 py-3 border border-ink-muted rounded-sm" id="tab-services">
                        Service Reports
                    </button>
                    <button onclick="showReportSection('customers')" class="tab-btn px-6 py-3 border border-ink-muted rounded-sm" id="tab-customers">
                        Customer Reports
                    </button>
                    <button onclick="showReportSection('sales')" class="tab-btn px-6 py-3 border border-ink-muted rounded-sm" id="tab-sales">
                        Sales Reports
                    </button>
                </div>
            </div>

            <!-- Service Reports Section -->
            <div id="section-services" class="report-section">
                <div class="grid md:grid-cols-3 gap-6 mb-8">
                    <div class="report-card border border-ink-muted p-6" onclick="loadBestRatedServices()">
                        <h3 class="font-serif text-xl font-medium mb-2">Best Rated Services</h3>
                        <p class="text-ink-light text-sm">Services with highest customer ratings</p>
                    </div>
                    <div class="report-card border border-ink-muted p-6" onclick="loadLowestRatedServices()">
                        <h3 class="font-serif text-xl font-medium mb-2">Lowest Rated Services</h3>
                        <p class="text-ink-light text-sm">Services needing improvement</p>
                    </div>
                    <div class="report-card border border-ink-muted p-6" onclick="loadHighDemandServices()">
                        <h3 class="font-serif text-xl font-medium mb-2">High Demand Services</h3>
                        <p class="text-ink-light text-sm">Most booked services</p>
                    </div>
                </div>

                <div id="service-report-results" class="hidden">
                    <div class="bg-white border border-ink-muted p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="font-serif text-2xl font-medium" id="service-report-title"></h3>
                            <button onclick="closeReport('service')" class="text-ink-light hover:text-ink">✕</button>
                        </div>
                        <div id="service-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

            <!-- Customer Reports Section -->
            <div id="section-customers" class="report-section hidden">
                <div class="grid md:grid-cols-2 gap-6 mb-8">
                    <div class="report-card border border-ink-muted p-6">
                        <h3 class="font-serif text-xl font-medium mb-4">Customers by Area</h3>
                        <div class="flex gap-2">
                            <input type="text" id="postal-code-input" placeholder="Enter postal code"
                                   class="flex-1 px-4 py-2 border border-ink-muted focus:outline-none focus:border-ink">
                            <button onclick="loadCustomersByArea()" class="px-6 py-2 bg-ink text-stone-warm hover:bg-ink-light">
                                Search
                            </button>
                        </div>
                    </div>
                    <div class="report-card border border-ink-muted p-6">
                        <h3 class="font-serif text-xl font-medium mb-4">Customers by Service</h3>
                        <div class="flex gap-2">
                            <select id="service-select" class="flex-1 px-4 py-2 border border-ink-muted focus:outline-none focus:border-ink">
                                <option value="">Select a service...</option>
                            </select>
                            <button onclick="loadCustomersByService()" class="px-6 py-2 bg-ink text-stone-warm hover:bg-ink-light">
                                Search
                            </button>
                        </div>
                    </div>
                </div>

                <div id="customer-report-results" class="hidden">
                    <div class="bg-white border border-ink-muted p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="font-serif text-2xl font-medium" id="customer-report-title"></h3>
                            <button onclick="closeReport('customer')" class="text-ink-light hover:text-ink">✕</button>
                        </div>
                        <div id="customer-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

            <!-- Sales Reports Section -->
            <div id="section-sales" class="report-section hidden">
                <div class="grid md:grid-cols-2 gap-6 mb-8">
                    <div class="report-card border border-ink-muted p-6" onclick="loadTopCustomers()">
                        <h3 class="font-serif text-xl font-medium mb-2">Top Customers</h3>
                        <p class="text-ink-light text-sm">Customers by total spending</p>
                    </div>
                    <div class="report-card border border-ink-muted p-6">
                        <h3 class="font-serif text-xl font-medium mb-4">Bookings by Date Range</h3>
                        <div class="space-y-2">
                            <input type="date" id="start-date" class="w-full px-4 py-2 border border-ink-muted focus:outline-none focus:border-ink">
                            <input type="date" id="end-date" class="w-full px-4 py-2 border border-ink-muted focus:outline-none focus:border-ink">
                            <button onclick="loadBookingsByDate()" class="w-full px-6 py-2 bg-ink text-stone-warm hover:bg-ink-light">
                                Generate Report
                            </button>
                        </div>
                    </div>
                </div>

                <div id="sales-report-results" class="hidden">
                    <div class="bg-white border border-ink-muted p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="font-serif text-2xl font-medium" id="sales-report-title"></h3>
                            <button onclick="closeReport('sales')" class="text-ink-light hover:text-ink">✕</button>
                        </div>
                        <div id="sales-report-content" class="overflow-x-auto"></div>
                    </div>
                </div>
            </div>

        </div>
    </main>

    </div>

    <script>
    const API_BASE = '<%= request.getContextPath() %>';

    // Tab switching
    function showReportSection(section) {
        document.querySelectorAll('.report-section').forEach(s => s.classList.add('hidden'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        
        document.getElementById('section-' + section).classList.remove('hidden');
        document.getElementById('tab-' + section).classList.add('active');
        
        // Close any open reports
        closeReport('service');
        closeReport('customer');
        closeReport('sales');
    }

    function closeReport(type) {
        document.getElementById(type + '-report-results').classList.add('hidden');
    }

    // Service Reports
    async function loadBestRatedServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/best-rated?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('Best Rated Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadLowestRatedServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/lowest-rated?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('Lowest Rated Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadHighDemandServices() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/services/high-demand?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displayServiceReport('High Demand Services', data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displayServiceReport(title, services) {
        document.getElementById('service-report-title').textContent = title;
        
        let html = '<table class="data-table"><thead><tr>';
        html += '<th>Service Name</th><th>Category</th><th>Avg Rating</th><th>Total Feedback</th><th>Price</th>';
        html += '</tr></thead><tbody>';
        
        services.forEach(service => {
            html += `<tr>
                <td>\${service.serviceName}</td>
                <td>\${service.categoryName || 'N/A'}</td>
                <td>\${service.avgRating !== null ? service.avgRating.toFixed(2) + ' ⭐' : 'N/A'}</td>
                <td>\${service.totalFeedback}</td>
                <td>$\${service.price.toFixed(2)}</td>
            </tr>`;
        });
        
        html += '</tbody></table>';
        document.getElementById('service-report-content').innerHTML = html;
        document.getElementById('service-report-results').classList.remove('hidden');
    }

    // Customer Reports
    async function loadCustomersByArea() {
        const postalCode = document.getElementById('postal-code-input').value.trim();
        if (!postalCode) {
            alert('Please enter a postal code');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/by-area?postalCode=\${encodeURIComponent(postalCode)}`);
            const data = await response.json();
            
            if (data.success) {
                displayCustomerReport(`Customers in Area: \${postalCode}`, data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadCustomersByService() {
        const serviceId = document.getElementById('service-select').value;
        if (!serviceId) {
            alert('Please select a service');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/by-service?serviceId=\${serviceId}`);
            const data = await response.json();
            
            if (data.success) {
                const serviceName = document.getElementById('service-select').selectedOptions[0].text;
                displayCustomerReport(`Customers who booked: \${serviceName}`, data.data);
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displayCustomerReport(title, customers) {
        document.getElementById('customer-report-title').textContent = title;
        
        let html = '<table class="data-table"><thead><tr>';
        html += '<th>Name</th><th>Email</th><th>Phone</th><th>Postal Code</th><th>City</th><th>Country</th>';
        html += '</tr></thead><tbody>';
        
        customers.forEach(customer => {
            html += `<tr>
                <td>\${customer.name}</td>
                <td>\${customer.email}</td>
                <td>\${customer.phone || 'N/A'}</td>
                <td>\${customer.postalCode || 'N/A'}</td>
                <td>\${customer.city || 'N/A'}</td>
                <td>\${customer.countryName || 'N/A'}</td>
            </tr>`;
        });
        
        html += '</tbody></table>';
        document.getElementById('customer-report-content').innerHTML = html;
        document.getElementById('customer-report-results').classList.remove('hidden');
    }

    // Sales Reports
    async function loadTopCustomers() {
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/customers/top?limit=10`);
            const data = await response.json();
            
            if (data.success) {
                displaySalesReport('Top Customers by Spending', data.data, 'customers');
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    async function loadBookingsByDate() {
        const startDate = document.getElementById('start-date').value;
        const endDate = document.getElementById('end-date').value;
        
        if (!startDate || !endDate) {
            alert('Please select both start and end dates');
            return;
        }
        
        try {
            const response = await fetch(`\${API_BASE}/api/admin/reports/bookings/by-date?startDate=\${startDate}&endDate=\${endDate}`);
            const data = await response.json();
            
            if (data.success) {
                displaySalesReport(`Bookings from \${startDate} to \${endDate}`, data.data, 'bookings');
            } else {
                alert('Failed to load report: ' + data.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to load report');
        }
    }

    function displaySalesReport(title, data, type) {
        document.getElementById('sales-report-title').textContent = title;
        
        let html = '<table class="data-table"><thead><tr>';
        
        if (type === 'customers') {
            html += '<th>Name</th><th>Email</th><th>Phone</th><th>Total Bookings</th><th>Total Spent</th>';
            html += '</tr></thead><tbody>';
            
            data.forEach(customer => {
                html += `<tr>
                    <td>\${customer.name}</td>
                    <td>\${customer.email}</td>
                    <td>\${customer.phone || 'N/A'}</td>
                    <td>\${customer.totalBookings}</td>
                    <td class="font-medium">$\${customer.totalSpent.toFixed(2)}</td>
                </tr>`;
            });
        } else if (type === 'bookings') {
            html += '<th>Booking ID</th><th>Customer</th><th>Scheduled Date</th><th>Status</th><th>Total Services</th><th>Total Amount</th>';
            html += '</tr></thead><tbody>';
            
            data.forEach(booking => {
                const scheduledDate = new Date(booking.scheduledAt).toLocaleString();
                html += `<tr>
                    <td>\${booking.bookingId}</td>
                    <td>\${booking.customerName}</td>
                    <td>\${scheduledDate}</td>
                    <td>\${booking.status}</td>
                    <td>\${booking.totalServices}</td>
                    <td class="font-medium">$\${booking.totalAmount.toFixed(2)}</td>
                </tr>`;
            });
        }
        
        html += '</tbody></table>';
        document.getElementById('sales-report-content').innerHTML = html;
        document.getElementById('sales-report-results').classList.remove('hidden');
    }

    // Load services for dropdown
    async function loadServicesDropdown() {
        try {
            const response = await fetch(`\${API_BASE}/api/services`);
            const services = await response.json();
            
            const select = document.getElementById('service-select');
            services.forEach(service => {
                const option = document.createElement('option');
                option.value = service.serviceId;
                option.textContent = service.serviceName;
                select.appendChild(option);
            });
        } catch (error) {
            console.error('Error loading services:', error);
        }
    }

    // Initialize
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 500);
        
        loadServicesDropdown();
    });
    </script>

</body>
</html>
