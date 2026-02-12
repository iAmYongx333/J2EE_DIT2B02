<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CareConnect B2B – Partner Service Catalog</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
                    colors: {
                        brand: { DEFAULT: '#1e40af', light: '#3b82f6', dark: '#1e3a8a', 50: '#eff6ff' },
                        slate: { 750: '#293548' }
                    }
                }
            }
        }
    </script>
    <style>
        body { -webkit-font-smoothing: antialiased; }
        .fade-in { animation: fadeIn 0.5s ease both; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        .shimmer { background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%); background-size: 200% 100%; animation: shimmer 1.5s infinite; }
        @keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
    </style>
</head>

<body class="bg-slate-50 text-slate-800 font-sans">

    <!-- Top Bar -->
    <header class="bg-white border-b border-slate-200 sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-8 h-8 bg-brand rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                    </svg>
                </div>
                <div>
                    <span class="font-semibold text-lg text-slate-900">CareConnect</span>
                    <span class="text-xs bg-brand-50 text-brand px-2 py-0.5 rounded-full ml-2 font-medium">B2B Partner</span>
                </div>
            </div>
            <div class="flex items-center gap-4 text-sm">
                <span class="text-slate-500">Powered by SilverCare API</span>
                <a href="<%=request.getContextPath()%>/" class="text-brand hover:text-brand-dark font-medium transition-colors">
                    &larr; Main Site
                </a>
            </div>
        </div>
    </header>

    <main class="max-w-7xl mx-auto px-6 py-10">

        <!-- Hero Section -->
        <section class="mb-10">
            <h1 class="text-3xl font-bold text-slate-900 mb-2">Partner Service Catalog</h1>
            <p class="text-slate-500 max-w-2xl">
                Browse SilverCare's elderly care services via our B2B REST API integration.
                This portal dynamically fetches live service data for partner healthcare providers.
            </p>
        </section>

        <!-- API Info Banner -->
        <div class="bg-brand-50 border border-blue-200 rounded-xl p-5 mb-8 flex items-start gap-4">
            <svg class="w-6 h-6 text-brand mt-0.5 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <div class="text-sm">
                <p class="font-semibold text-brand mb-1">B2B REST API Integration</p>
                <p class="text-slate-600">
                    This page consumes the <code class="bg-white px-1.5 py-0.5 rounded text-xs font-mono text-brand">GET /api/b2b/services</code>
                    and <code class="bg-white px-1.5 py-0.5 rounded text-xs font-mono text-brand">GET /api/b2b/services/category/{id}</code>
                    endpoints from SilverCare's RESTful web service.
                </p>
            </div>
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-xl border border-slate-200 p-5 mb-8">
            <div class="flex flex-wrap items-end gap-4">
                <div>
                    <label class="block text-xs font-medium text-slate-500 mb-1.5">Category</label>
                    <select id="categoryFilter" onchange="filterByCategory()"
                            class="border border-slate-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-brand focus:border-brand outline-none min-w-[200px]">
                        <option value="all">All Categories</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-medium text-slate-500 mb-1.5">Min Price (SGD)</label>
                    <input type="number" id="minPrice" placeholder="0" min="0" step="5"
                           class="border border-slate-300 rounded-lg px-3 py-2 text-sm w-28 focus:ring-2 focus:ring-brand focus:border-brand outline-none">
                </div>
                <div>
                    <label class="block text-xs font-medium text-slate-500 mb-1.5">Max Price (SGD)</label>
                    <input type="number" id="maxPrice" placeholder="Any" min="0" step="5"
                           class="border border-slate-300 rounded-lg px-3 py-2 text-sm w-28 focus:ring-2 focus:ring-brand focus:border-brand outline-none">
                </div>
                <button onclick="applyPriceFilter()"
                        class="bg-brand text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-brand-dark transition-colors">
                    Apply Filter
                </button>
                <button onclick="resetFilters()"
                        class="text-slate-500 hover:text-slate-700 px-3 py-2 text-sm transition-colors">
                    Reset
                </button>
            </div>
        </div>

        <!-- Stats Bar -->
        <div id="statsBar" class="flex gap-6 mb-6 text-sm text-slate-500">
            <span id="totalCount">Loading...</span>
            <span id="apiEndpoint" class="font-mono text-xs bg-slate-100 px-2 py-1 rounded"></span>
        </div>

        <!-- Loading Skeleton -->
        <div id="loadingSkeleton" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <div class="bg-white rounded-xl border border-slate-200 p-5">
                <div class="shimmer h-5 w-3/4 rounded mb-3"></div>
                <div class="shimmer h-4 w-full rounded mb-2"></div>
                <div class="shimmer h-4 w-2/3 rounded mb-4"></div>
                <div class="shimmer h-8 w-1/3 rounded"></div>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 p-5">
                <div class="shimmer h-5 w-3/4 rounded mb-3"></div>
                <div class="shimmer h-4 w-full rounded mb-2"></div>
                <div class="shimmer h-4 w-2/3 rounded mb-4"></div>
                <div class="shimmer h-8 w-1/3 rounded"></div>
            </div>
            <div class="bg-white rounded-xl border border-slate-200 p-5">
                <div class="shimmer h-5 w-3/4 rounded mb-3"></div>
                <div class="shimmer h-4 w-full rounded mb-2"></div>
                <div class="shimmer h-4 w-2/3 rounded mb-4"></div>
                <div class="shimmer h-8 w-1/3 rounded"></div>
            </div>
        </div>

        <!-- Service Cards Grid -->
        <div id="servicesGrid" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6 hidden"></div>

        <!-- Error State -->
        <div id="errorState" class="hidden text-center py-16">
            <svg class="w-16 h-16 text-slate-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4.5c-.77-.833-2.694-.833-3.464 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
            <p class="text-slate-500 font-medium mb-1">Failed to load services</p>
            <p id="errorMessage" class="text-slate-400 text-sm mb-4"></p>
            <button onclick="loadAllServices()" class="text-brand hover:text-brand-dark text-sm font-medium">Try again</button>
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="hidden text-center py-16">
            <svg class="w-16 h-16 text-slate-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
            </svg>
            <p class="text-slate-500 font-medium">No services found</p>
            <p class="text-slate-400 text-sm">Try adjusting your filters</p>
        </div>

        <!-- Service Detail Modal -->
        <div id="detailModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 backdrop-blur-sm">
            <div class="bg-white rounded-2xl shadow-2xl max-w-lg w-full mx-4 max-h-[80vh] overflow-y-auto">
                <div class="p-6">
                    <div class="flex items-start justify-between mb-4">
                        <h3 id="modalServiceName" class="text-xl font-bold text-slate-900"></h3>
                        <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600 p-1">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                            </svg>
                        </button>
                    </div>
                    <div id="modalContent"></div>
                    <div class="mt-5 pt-4 border-t border-slate-100">
                        <p class="text-xs text-slate-400 font-mono" id="modalApiSource"></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- API Raw Response Section -->
        <section class="mt-12 mb-8">
            <div class="flex items-center justify-between mb-4">
                <h2 class="text-lg font-semibold text-slate-900">Raw API Response</h2>
                <button onclick="toggleRawResponse()" id="toggleRawBtn"
                        class="text-sm text-brand hover:text-brand-dark font-medium">
                    Show
                </button>
            </div>
            <pre id="rawResponse" class="hidden bg-slate-900 text-green-400 rounded-xl p-5 text-xs font-mono overflow-x-auto max-h-96 overflow-y-auto"></pre>
        </section>

    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 mt-12">
        <div class="max-w-7xl mx-auto px-6 py-8">
            <div class="flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-slate-500">
                <p>&copy; 2026 CareConnect B2B Portal &mdash; Powered by SilverCare REST API</p>
                <div class="flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-green-400"></span>
                    <span>API Status: Connected</span>
                </div>
            </div>
        </div>
    </footer>

    <script>
    const API_BASE = 'http://localhost:8081/api/b2b';
    const CATEGORY_API = 'http://localhost:8081/api/categories';
    let allServices = [];
    let lastEndpoint = '';

    /* ========== INITIALIZATION ========== */
    document.addEventListener('DOMContentLoaded', () => {
        loadCategories();
        loadAllServices();
    });

    /* ========== LOAD CATEGORIES ========== */
    async function loadCategories() {
        try {
            const res = await fetch(CATEGORY_API);
            const categories = await res.json();
            const sel = document.getElementById('categoryFilter');
            categories.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.categoryId;
                opt.textContent = c.categoryName;
                sel.appendChild(opt);
            });
        } catch (e) {
            console.error('Failed to load categories', e);
        }
    }

    /* ========== LOAD ALL SERVICES ========== */
    async function loadAllServices() {
        showLoading();
        lastEndpoint = API_BASE + '/services';

        try {
            const res = await fetch(lastEndpoint);
            const json = await res.json();
            showRawJson(json);

            if (json.success && json.data) {
                allServices = json.data;
                renderServices(allServices);
            } else {
                showError(json.message || 'Unknown error');
            }
        } catch (e) {
            showError('Cannot connect to SilverCare B2B API at ' + API_BASE);
        }
    }

    /* ========== FILTER BY CATEGORY ========== */
    async function filterByCategory() {
        const catId = document.getElementById('categoryFilter').value;
        showLoading();

        if (catId === 'all') {
            lastEndpoint = API_BASE + '/services';
        } else {
            lastEndpoint = API_BASE + '/services/category/' + catId;
        }

        try {
            const res = await fetch(lastEndpoint);
            const json = await res.json();
            showRawJson(json);

            if (json.success && json.data) {
                allServices = json.data;
                renderServices(allServices);
            } else if (!json.success) {
                allServices = [];
                renderServices([]);
            }
        } catch (e) {
            showError('Failed to fetch services');
        }
    }

    /* ========== PRICE FILTER ========== */
    function applyPriceFilter() {
        const min = parseFloat(document.getElementById('minPrice').value) || 0;
        const max = parseFloat(document.getElementById('maxPrice').value) || Infinity;
        const filtered = allServices.filter(s => s.price >= min && s.price <= max);
        renderServices(filtered);
    }

    function resetFilters() {
        document.getElementById('categoryFilter').value = 'all';
        document.getElementById('minPrice').value = '';
        document.getElementById('maxPrice').value = '';
        loadAllServices();
    }

    /* ========== RENDER SERVICES ========== */
    function renderServices(services) {
        const grid = document.getElementById('servicesGrid');
        const skeleton = document.getElementById('loadingSkeleton');
        const empty = document.getElementById('emptyState');
        const error = document.getElementById('errorState');

        skeleton.classList.add('hidden');
        error.classList.add('hidden');
        grid.classList.remove('hidden');

        document.getElementById('totalCount').textContent = services.length + ' service(s) found';
        document.getElementById('apiEndpoint').textContent = 'GET ' + lastEndpoint.replace(API_BASE, '/api/b2b');

        if (services.length === 0) {
            grid.classList.add('hidden');
            empty.classList.remove('hidden');
            return;
        }

        empty.classList.add('hidden');
        grid.innerHTML = services.map((s, i) => `
            <div class="bg-white rounded-xl border border-slate-200 hover:border-brand/30 hover:shadow-lg transition-all duration-200 cursor-pointer fade-in"
                 style="animation-delay: ${i * 0.05}s"
                 onclick="showDetail(${s.serviceId})">
                <div class="p-5">
                    <div class="flex items-start justify-between mb-3">
                        <h3 class="font-semibold text-slate-900 leading-tight">${escHtml(s.serviceName)}</h3>
                        <span class="text-xs font-mono bg-slate-100 text-slate-500 px-2 py-0.5 rounded shrink-0 ml-2">
                            ID:${s.serviceId}
                        </span>
                    </div>
                    <p class="text-sm text-slate-500 mb-4 line-clamp-2">${escHtml(s.description || '')}</p>
                    <div class="flex items-end justify-between">
                        <div>
                            <span class="text-2xl font-bold text-brand">$${s.price.toFixed(2)}</span>
                            <span class="text-xs text-slate-400 ml-1">SGD</span>
                        </div>
                        <div class="text-right text-xs text-slate-400">
                            <div>${s.durationMin} min</div>
                            ${s.ratingAvg ? `<div class="text-amber-500 mt-0.5">${'★'.repeat(Math.round(s.ratingAvg))} ${s.ratingAvg}</div>` : ''}
                        </div>
                    </div>
                </div>
                <div class="border-t border-slate-100 px-5 py-3 flex items-center justify-between">
                    <span class="text-xs ${s.active !== false ? 'text-green-600 bg-green-50' : 'text-red-600 bg-red-50'} px-2 py-0.5 rounded-full font-medium">
                        ${s.active !== false ? 'Available' : 'Unavailable'}
                    </span>
                    <span class="text-xs text-brand font-medium">View Details &rarr;</span>
                </div>
            </div>
        `).join('');
    }

    /* ========== SERVICE DETAIL MODAL ========== */
    async function showDetail(serviceId) {
        const endpoint = API_BASE + '/services/' + serviceId;
        try {
            const res = await fetch(endpoint);
            const json = await res.json();

            if (json.success && json.data) {
                const s = json.data;
                document.getElementById('modalServiceName').textContent = s.serviceName;
                document.getElementById('modalContent').innerHTML = `
                    <div class="space-y-4">
                        <p class="text-slate-600 text-sm">${escHtml(s.description || '')}</p>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Price</p>
                                <p class="text-lg font-bold text-brand">$${s.price.toFixed(2)} <span class="text-xs font-normal text-slate-400">SGD</span></p>
                            </div>
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Duration</p>
                                <p class="text-lg font-bold text-slate-700">${s.durationMin} <span class="text-xs font-normal text-slate-400">min</span></p>
                            </div>
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Category ID</p>
                                <p class="text-lg font-bold text-slate-700">${s.categoryId}</p>
                            </div>
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Service ID</p>
                                <p class="text-lg font-bold text-slate-700">${s.serviceId}</p>
                            </div>
                            ${s.ratingAvg ? `
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Rating</p>
                                <p class="text-lg font-bold text-amber-500">${s.ratingAvg} <span class="text-xs font-normal text-slate-400">(${s.ratingCount || 0} reviews)</span></p>
                            </div>` : ''}
                            ${s.totalBookings != null ? `
                            <div class="bg-slate-50 rounded-lg p-3">
                                <p class="text-xs text-slate-400 mb-0.5">Total Bookings</p>
                                <p class="text-lg font-bold text-slate-700">${s.totalBookings}</p>
                            </div>` : ''}
                        </div>
                        <div class="bg-slate-50 rounded-lg p-3">
                            <p class="text-xs text-slate-400 mb-0.5">Status</p>
                            <span class="text-sm font-medium ${s.active !== false ? 'text-green-600' : 'text-red-600'}">
                                ${s.active !== false ? '● Available' : '● Unavailable'}
                            </span>
                        </div>
                    </div>
                `;
                document.getElementById('modalApiSource').textContent = 'Source: GET ' + endpoint.replace('http://localhost:8081/api', '/api');

                const modal = document.getElementById('detailModal');
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            }
        } catch (e) {
            console.error('Failed to fetch detail', e);
        }
    }

    function closeModal() {
        const modal = document.getElementById('detailModal');
        modal.classList.add('hidden');
        modal.classList.remove('flex');
    }

    /* ========== HELPERS ========== */
    function showLoading() {
        document.getElementById('loadingSkeleton').classList.remove('hidden');
        document.getElementById('servicesGrid').classList.add('hidden');
        document.getElementById('emptyState').classList.add('hidden');
        document.getElementById('errorState').classList.add('hidden');
    }

    function showError(msg) {
        document.getElementById('loadingSkeleton').classList.add('hidden');
        document.getElementById('servicesGrid').classList.add('hidden');
        document.getElementById('emptyState').classList.add('hidden');
        document.getElementById('errorState').classList.remove('hidden');
        document.getElementById('errorMessage').textContent = msg;
        document.getElementById('totalCount').textContent = 'Error';
    }

    function showRawJson(json) {
        document.getElementById('rawResponse').textContent = JSON.stringify(json, null, 2);
    }

    function toggleRawResponse() {
        const el = document.getElementById('rawResponse');
        const btn = document.getElementById('toggleRawBtn');
        if (el.classList.contains('hidden')) {
            el.classList.remove('hidden');
            btn.textContent = 'Hide';
        } else {
            el.classList.add('hidden');
            btn.textContent = 'Show';
        }
    }

    function escHtml(str) {
        const d = document.createElement('div');
        d.textContent = str;
        return d.innerHTML;
    }

    // Close modal on outside click
    document.getElementById('detailModal').addEventListener('click', function(e) {
        if (e.target === this) closeModal();
    });
    </script>

</body>
</html>
