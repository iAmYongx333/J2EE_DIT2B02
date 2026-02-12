<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Client Inquiry & Reporting – SilverCare</title>

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
                    forest: '#3d4f3d',
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

    @keyframes fadeSlideIn {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .stagger-1 { animation: fadeSlideIn 0.6s ease 0.1s both; }
    .stagger-2 { animation: fadeSlideIn 0.6s ease 0.2s both; }
    .stagger-3 { animation: fadeSlideIn 0.6s ease 0.3s both; }

    .inquiry-card {
        transition: transform 0.2s ease, border-color 0.2s ease;
    }
    .inquiry-card:hover {
        transform: translateY(-2px);
        border-color: #2c2c2c;
    }

    .data-table { width: 100%; border-collapse: collapse; }
    .data-table th {
        background-color: #e8e4dc; padding: 12px; text-align: left;
        font-weight: 500; border-bottom: 2px solid #2c2c2c;
        font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em;
    }
    .data-table td { padding: 12px; border-bottom: 1px solid #e8e4dc; font-size: 0.875rem; }
    .data-table tr:hover { background-color: #f5f3ef; }

    .tab-btn { transition: all 0.2s ease; }
    .tab-btn.active { background-color: #2c2c2c; color: #f5f3ef; }

    .stat-pill {
        display: inline-flex; align-items: center; gap: 6px;
        padding: 4px 12px; background: #e8e4dc; font-size: 0.75rem; color: #5a5a5a;
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
            <header class="mb-10">
                <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Administration</span>
                        <h1 class="font-serif text-4xl md:text-5xl font-medium text-ink leading-tight mt-3 mb-4 stagger-2">
                            Client Inquiry
                        </h1>
                        <p class="text-ink-light text-base max-w-2xl stagger-3">
                            Search and filter clients by residential area code, specific care needs, or service history. Export client data for analysis and planning.
                        </p>
                    </div>
                    <div class="stagger-3">
                        <button onclick="exportResults()" id="exportBtn" class="px-5 py-2 bg-ink text-stone-warm text-sm hover:bg-ink-light transition-colors" style="display:none;">
                            Export CSV
                        </button>
                    </div>
                </div>
            </header>

            <!-- Search Tabs -->
            <div class="mb-8 stagger-3">
                <div class="flex gap-3 flex-wrap">
                    <button onclick="showSearchMode('area')" class="tab-btn active px-5 py-2 border border-stone-mid text-sm" id="tab-area">
                        By Area Code
                    </button>
                    <button onclick="showSearchMode('care')" class="tab-btn px-5 py-2 border border-stone-mid text-sm" id="tab-care">
                        By Care Needs
                    </button>
                    <button onclick="showSearchMode('service')" class="tab-btn px-5 py-2 border border-stone-mid text-sm" id="tab-service">
                        By Service Booked
                    </button>
                </div>
            </div>

            <!-- Search Panels -->
            <div class="mb-8">

                <!-- Area Code Search -->
                <div id="search-area" class="search-panel">
                    <div class="bg-white border border-stone-mid p-6">
                        <h3 class="font-serif text-xl font-medium mb-2">Search by Residential Area</h3>
                        <p class="text-ink-light text-sm mb-4">
                            Enter a postal code or partial postal code to find clients in that area.
                        </p>
                        <div class="flex flex-col md:flex-row gap-3">
                            <input type="text" id="areaInput" placeholder="e.g. 530, 680, 310"
                                   class="flex-1 px-4 py-2.5 border border-stone-mid focus:outline-none focus:border-ink text-sm"
                                   onkeypress="if(event.key==='Enter') searchByArea()">
                            <button onclick="searchByArea()" class="px-6 py-2.5 bg-ink text-stone-warm text-sm hover:bg-ink-light transition-colors">
                                Search Clients
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Care Needs Search -->
                <div id="search-care" class="search-panel" style="display:none;">
                    <div class="bg-white border border-stone-mid p-6">
                        <h3 class="font-serif text-xl font-medium mb-2">Search by Care Needs</h3>
                        <p class="text-ink-light text-sm mb-4">
                            Find clients based on their specific care preferences or medical requirements.
                        </p>
                        <div class="flex flex-col md:flex-row gap-3">
                            <input type="text" id="careInput" placeholder="e.g. dementia, physiotherapy, wheelchair"
                                   class="flex-1 px-4 py-2.5 border border-stone-mid focus:outline-none focus:border-ink text-sm"
                                   onkeypress="if(event.key==='Enter') searchByCareNeeds()">
                            <button onclick="searchByCareNeeds()" class="px-6 py-2.5 bg-ink text-stone-warm text-sm hover:bg-ink-light transition-colors">
                                Search Clients
                            </button>
                        </div>
                        <!-- Quick filters -->
                        <div class="mt-4 flex flex-wrap gap-2">
                            <span class="text-xs text-ink-muted mr-2">Quick filters:</span>
                            <button onclick="setCareFilter('dementia care')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Dementia</button>
                            <button onclick="setCareFilter('physiotherapy')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Physiotherapy</button>
                            <button onclick="setCareFilter('wheelchair')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Wheelchair</button>
                            <button onclick="setCareFilter('medication')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Medication</button>
                            <button onclick="setCareFilter('palliative')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Palliative</button>
                            <button onclick="setCareFilter('companionship')" class="text-xs px-3 py-1 border border-stone-mid text-ink-light hover:border-ink hover:text-ink transition-colors">Companionship</button>
                        </div>
                    </div>
                </div>

                <!-- Service Search -->
                <div id="search-service" class="search-panel" style="display:none;">
                    <div class="bg-white border border-stone-mid p-6">
                        <h3 class="font-serif text-xl font-medium mb-2">Search by Service Booked</h3>
                        <p class="text-ink-light text-sm mb-4">
                            Find clients who have booked a specific care service.
                        </p>
                        <div class="flex flex-col md:flex-row gap-3">
                            <select id="serviceSelect" class="flex-1 px-4 py-2.5 border border-stone-mid focus:outline-none focus:border-ink text-sm">
                                <option value="">Select a service...</option>
                            </select>
                            <button onclick="searchByService()" class="px-6 py-2.5 bg-ink text-stone-warm text-sm hover:bg-ink-light transition-colors">
                                Search Clients
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Results Summary -->
            <div id="resultsSummary" class="mb-4" style="display:none;">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                    <div class="flex items-center gap-3">
                        <h2 class="font-serif text-2xl font-medium text-ink" id="resultsTitle">Search Results</h2>
                        <span class="stat-pill" id="resultsCount">0 clients</span>
                    </div>
                    <button onclick="clearResults()" class="text-sm text-ink-light hover:text-ink transition-colors">
                        Clear Results
                    </button>
                </div>
            </div>

            <!-- Results Table -->
            <div id="resultsContainer" style="display:none;">
                <div class="bg-white border border-stone-mid overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="data-table" id="resultsTable">
                            <thead id="resultsHead"></thead>
                            <tbody id="resultsBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div id="emptyState" style="display:none;">
                <div class="bg-white border border-stone-mid p-8 md:p-12 text-center">
                    <svg class="w-12 h-12 mx-auto text-stone-deep mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                    </svg>
                    <h3 class="font-serif text-xl font-medium text-ink mb-2">No clients found</h3>
                    <p class="text-sm text-ink-light max-w-md mx-auto" id="emptyMessage">
                        No clients match your search criteria. Try adjusting your search terms.
                    </p>
                </div>
            </div>

            <!-- Quick Stats Section -->
            <div class="mt-12 stagger-3">
                <h2 class="font-serif text-xl font-medium text-ink mb-5">Area Overview</h2>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-5" id="areaStats">
                    <div class="inquiry-card bg-white border border-stone-mid p-5">
                        <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2">Total Clients</p>
                        <p class="font-serif text-3xl font-medium text-ink" id="statTotalClients">—</p>
                    </div>
                    <div class="inquiry-card bg-white border border-stone-mid p-5">
                        <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2">With Care Preferences</p>
                        <p class="font-serif text-3xl font-medium text-ink" id="statWithPrefs">—</p>
                    </div>
                    <div class="inquiry-card bg-white border border-stone-mid p-5">
                        <p class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-2">Active Bookings</p>
                        <p class="font-serif text-3xl font-medium text-ink" id="statActiveBookings">—</p>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    const API_BASE = '<%= request.getContextPath() %>';
    let currentResults = [];
    let currentSearchMode = 'area';

    // ── Tab switching ──
    function showSearchMode(mode) {
        currentSearchMode = mode;
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + mode).classList.add('active');
        document.querySelectorAll('.search-panel').forEach(p => p.style.display = 'none');
        document.getElementById('search-' + mode).style.display = 'block';
    }

    function setCareFilter(value) {
        document.getElementById('careInput').value = value;
        searchByCareNeeds();
    }

    // ── Search by Area Code ──
    async function searchByArea() {
        const postalCode = document.getElementById('areaInput').value.trim();
        if (!postalCode) { alert('Please enter a postal code'); return; }

        showLoading();
        try {
            const response = await fetch(API_BASE + '/api/admin/clients/by-area?postalCode=' + encodeURIComponent(postalCode));
            const data = await response.json();
            if (data.success) {
                displayResults('Clients in Area: ' + postalCode, data.data, 'area');
            } else {
                showEmpty('No clients found for postal code: ' + postalCode);
            }
        } catch (error) {
            console.error('Error:', error);
            showEmpty('Failed to search. Please try again.');
        }
    }

    // ── Search by Care Needs ──
    async function searchByCareNeeds() {
        const keyword = document.getElementById('careInput').value.trim();
        if (!keyword) { alert('Please enter a care need keyword'); return; }

        showLoading();
        try {
            const response = await fetch(API_BASE + '/api/admin/clients/by-care-needs?keyword=' + encodeURIComponent(keyword));
            const data = await response.json();
            if (data.success) {
                displayResults('Clients with care needs: "' + keyword + '"', data.data, 'care');
            } else {
                showEmpty('No clients found with care needs: ' + keyword);
            }
        } catch (error) {
            console.error('Error:', error);
            showEmpty('Failed to search. Please try again.');
        }
    }

    // ── Search by Service ──
    async function searchByService() {
        const serviceId = document.getElementById('serviceSelect').value;
        if (!serviceId) { alert('Please select a service'); return; }

        showLoading();
        try {
            const response = await fetch(API_BASE + '/api/admin/clients/by-service?serviceId=' + serviceId);
            const data = await response.json();
            if (data.success) {
                const serviceName = document.getElementById('serviceSelect').selectedOptions[0].text;
                displayResults('Clients who booked: ' + serviceName, data.data, 'service');
            } else {
                showEmpty('No clients found for this service.');
            }
        } catch (error) {
            console.error('Error:', error);
            showEmpty('Failed to search. Please try again.');
        }
    }

    // ── Display results ──
    function displayResults(title, clients, type) {
        currentResults = clients;

        if (!clients || clients.length === 0) {
            showEmpty('No clients match your search criteria.');
            return;
        }

        // Summary
        document.getElementById('resultsSummary').style.display = 'block';
        document.getElementById('resultsTitle').textContent = title;
        document.getElementById('resultsCount').textContent = clients.length + ' client' + (clients.length !== 1 ? 's' : '');
        document.getElementById('exportBtn').style.display = 'inline-flex';

        // Table header
        let headHtml = '<tr>';
        headHtml += '<th>Name</th><th>Email</th><th>Phone</th><th>Postal Code</th><th>Street</th><th>City</th>';
        if (type === 'care' || type === 'area') {
            headHtml += '<th>Care Preferences</th>';
        }
        headHtml += '<th>Bookings</th>';
        headHtml += '</tr>';
        document.getElementById('resultsHead').innerHTML = headHtml;

        // Table body
        let bodyHtml = '';
        clients.forEach(client => {
            bodyHtml += '<tr>';
            bodyHtml += '<td class="font-medium text-ink">' + (client.name || '—') + '</td>';
            bodyHtml += '<td>' + (client.email || '—') + '</td>';
            bodyHtml += '<td>' + (client.phone || '—') + '</td>';
            bodyHtml += '<td>' + (client.postalCode || '—') + '</td>';
            bodyHtml += '<td>' + (client.street || '—') + '</td>';
            bodyHtml += '<td>' + (client.city || '—') + '</td>';
            if (type === 'care' || type === 'area') {
                bodyHtml += '<td class="max-w-xs">';
                if (client.carePreferences) {
                    bodyHtml += '<span class="text-xs text-ink-light">' + client.carePreferences + '</span>';
                } else {
                    bodyHtml += '<span class="text-xs text-ink-muted">None specified</span>';
                }
                bodyHtml += '</td>';
            }
            bodyHtml += '<td class="text-center">' + (client.totalBookings || 0) + '</td>';
            bodyHtml += '</tr>';
        });
        document.getElementById('resultsBody').innerHTML = bodyHtml;

        // Show/hide
        document.getElementById('resultsContainer').style.display = 'block';
        document.getElementById('emptyState').style.display = 'none';

        // Update stats
        updateStats(clients);
    }

    function showLoading() {
        document.getElementById('resultsContainer').style.display = 'none';
        document.getElementById('emptyState').style.display = 'none';
        document.getElementById('resultsSummary').style.display = 'none';
        document.getElementById('exportBtn').style.display = 'none';
    }

    function showEmpty(message) {
        document.getElementById('resultsContainer').style.display = 'none';
        document.getElementById('resultsSummary').style.display = 'none';
        document.getElementById('exportBtn').style.display = 'none';
        document.getElementById('emptyMessage').textContent = message;
        document.getElementById('emptyState').style.display = 'block';
    }

    function clearResults() {
        document.getElementById('resultsContainer').style.display = 'none';
        document.getElementById('resultsSummary').style.display = 'none';
        document.getElementById('emptyState').style.display = 'none';
        document.getElementById('exportBtn').style.display = 'none';
        currentResults = [];
    }

    function updateStats(clients) {
        document.getElementById('statTotalClients').textContent = clients.length;
        const withPrefs = clients.filter(c => c.carePreferences && c.carePreferences.trim() !== '').length;
        document.getElementById('statWithPrefs').textContent = withPrefs;
        const totalBookings = clients.reduce((sum, c) => sum + (c.totalBookings || 0), 0);
        document.getElementById('statActiveBookings').textContent = totalBookings;
    }

    // ── Export CSV ──
    function exportResults() {
        if (!currentResults || currentResults.length === 0) return;

        let csv = 'Name,Email,Phone,Postal Code,Street,City,Care Preferences,Total Bookings\n';
        currentResults.forEach(c => {
            csv += '"' + (c.name || '') + '","' + (c.email || '') + '","' + (c.phone || '') + '","' +
                   (c.postalCode || '') + '","' + (c.street || '') + '","' + (c.city || '') + '","' +
                   (c.carePreferences || '') + '",' + (c.totalBookings || 0) + '\n';
        });

        const blob = new Blob([csv], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'client_inquiry_' + new Date().toISOString().slice(0, 10) + '.csv';
        a.click();
        URL.revokeObjectURL(url);
    }

    // ── Load services dropdown ──
    async function loadServicesDropdown() {
        try {
            const response = await fetch(API_BASE + '/api/services');
            const services = await response.json();
            const select = document.getElementById('serviceSelect');
            if (Array.isArray(services)) {
                services.forEach(service => {
                    const option = document.createElement('option');
                    option.value = service.serviceId;
                    option.textContent = service.serviceName;
                    select.appendChild(option);
                });
            }
        } catch (error) { console.error('Error loading services:', error); }
    }

    // ── Init ──
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
        loadServicesDropdown();
    });
    </script>
</body>
</html>
