<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Object userRole = session.getAttribute("sessRole");
    if (userRole == null) {
        response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
        return;
    }
    String userId = session.getAttribute("sessId").toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Care Visit Status | SilverCare</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
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

        .visit-card {
            transition: transform 0.2s ease, border-color 0.2s ease;
        }
        .visit-card:hover {
            transform: translateY(-2px);
            border-color: #2c2c2c;
        }

        /* Status badge colors */
        .status-scheduled { background: #e8e4dc; color: #5a5a5a; }
        .status-en_route { background: #fef3c7; color: #92400e; }
        .status-checked_in { background: #dbeafe; color: #1e40af; }
        .status-in_progress { background: rgba(61,79,61,0.1); color: #3d4f3d; border: 1px solid rgba(61,79,61,0.2); }
        .status-checked_out { background: #e0e7ff; color: #3730a3; }
        .status-completed { background: rgba(61,79,61,0.15); color: #3d4f3d; border: 1px solid rgba(61,79,61,0.3); }
        .status-cancelled { background: #fee2e2; color: #991b1b; }

        /* Progress bar */
        .progress-track { height: 3px; background: #e8e4dc; }
        .progress-fill { height: 100%; background: #3d4f3d; transition: width 0.6s ease; }

        /* Timeline */
        .timeline-dot { width: 10px; height: 10px; border-radius: 50%; border: 2px solid #d4cec3; background: #f5f3ef; flex-shrink: 0; }
        .timeline-dot.active { border-color: #3d4f3d; background: #3d4f3d; }
        .timeline-dot.current { border-color: #b87a4b; background: #b87a4b; box-shadow: 0 0 0 3px rgba(184,122,75,0.2); }
        .timeline-line { width: 2px; height: 20px; background: #e8e4dc; margin: 2px auto; }
        .timeline-line.active { background: #3d4f3d; }

        /* Notification toast */
        .notification-toast {
            position: fixed; top: 80px; right: 20px; z-index: 200;
            background: #fff; border: 1px solid #e8e4dc;
            padding: 16px 20px; max-width: 380px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            transform: translateX(120%); transition: transform 0.4s ease;
        }
        .notification-toast.show { transform: translateX(0); }

        /* Live indicator */
        .live-dot {
            width: 8px; height: 8px; border-radius: 50%; background: #3d4f3d;
            animation: pulse 2s ease infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.5; transform: scale(1.3); }
        }

        .tab-btn { transition: all 0.2s ease; }
        .tab-btn.active { background-color: #2c2c2c; color: #f5f3ef; }
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

    <!-- Notification Toast -->
    <div class="notification-toast" id="notificationToast">
        <div class="flex items-start gap-3">
            <div class="mt-0.5">
                <svg class="w-5 h-5 text-copper" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
                </svg>
            </div>
            <div>
                <p class="text-sm font-medium text-ink" id="toastTitle">Status Update</p>
                <p class="text-xs text-ink-light mt-1" id="toastMessage"></p>
                <p class="text-xs text-ink-muted mt-2" id="toastTime"></p>
            </div>
            <button onclick="hideToast()" class="text-ink-muted hover:text-ink ml-auto">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>
        </div>
    </div>

    <div class="page-content" id="pageContent">
    <%@ include file="../includes/header.jsp" %>

    <main class="pt-24 pb-20 px-5 md:px-12">
        <div class="max-w-6xl mx-auto">

            <!-- Page Header -->
            <header class="mb-10">
                <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
                    <div>
                        <span class="text-copper text-xs uppercase tracking-[0.2em] stagger-1">Real-Time Monitoring</span>
                        <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink leading-tight mt-2 mb-3 stagger-2">
                            Care Visit Status
                        </h1>
                        <p class="text-ink-light text-base max-w-xl leading-relaxed stagger-3">
                            Track the progress of your scheduled care visits in real-time. Receive instant notifications when your caregiver checks in or out.
                        </p>
                    </div>
                    <div class="stagger-3 flex items-center gap-3">
                        <div class="flex items-center gap-2 bg-white border border-stone-mid px-4 py-2">
                            <div class="live-dot" id="liveDot"></div>
                            <span class="text-xs text-ink-light" id="connectionStatus">Connecting...</span>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Filter Tabs -->
            <div class="mb-8 stagger-3">
                <div class="flex gap-3 flex-wrap">
                    <button onclick="filterVisits('today')" class="tab-btn active px-5 py-2 border border-stone-mid text-sm" id="tab-today">
                        Today's Visits
                    </button>
                    <button onclick="filterVisits('active')" class="tab-btn px-5 py-2 border border-stone-mid text-sm" id="tab-active">
                        Active Now
                    </button>
                    <button onclick="filterVisits('all')" class="tab-btn px-5 py-2 border border-stone-mid text-sm" id="tab-all">
                        All Visits
                    </button>
                </div>
            </div>

            <!-- Visits Container -->
            <div id="visitsContainer">
                <div class="text-center py-12">
                    <p class="text-ink-muted text-sm">Loading your visits...</p>
                </div>
            </div>

            <!-- Notification History -->
            <div class="mt-12" id="notificationHistorySection" style="display:none;">
                <h2 class="font-serif text-xl font-medium text-ink mb-4">Recent Notifications</h2>
                <div id="notificationHistory" class="space-y-3"></div>
            </div>

        </div>
    </main>

    <%@ include file="../includes/footer.jsp" %>
    </div>

    <script>
    const API_BASE = '<%= request.getContextPath() %>';
    const CUSTOMER_ID = '<%= userId %>';
    const WS_URL = 'http://localhost:8081/api/ws';
    let stompClient = null;
    let currentFilter = 'today';
    let allVisits = [];
    let notificationLog = [];

    // ── Status helpers ──
    const STATUS_ORDER = ['SCHEDULED','EN_ROUTE','CHECKED_IN','IN_PROGRESS','CHECKED_OUT','COMPLETED','CANCELLED'];
    const STATUS_LABEL = {
        'SCHEDULED': 'Scheduled',
        'EN_ROUTE': 'Caregiver En Route',
        'CHECKED_IN': 'Checked In',
        'IN_PROGRESS': 'In Progress',
        'CHECKED_OUT': 'Checked Out',
        'COMPLETED': 'Completed',
        'CANCELLED': 'Cancelled'
    };

    function getStatusProgress(status) {
        const idx = STATUS_ORDER.indexOf(status);
        if (status === 'CANCELLED') return 0;
        if (status === 'COMPLETED') return 100;
        return Math.round((idx / (STATUS_ORDER.length - 2)) * 100);
    }

    function formatDateTime(ts) {
        if (!ts) return '—';
        const d = new Date(ts);
        return d.toLocaleDateString('en-SG', { day: 'numeric', month: 'short', year: 'numeric' }) +
               ' at ' + d.toLocaleTimeString('en-SG', { hour: '2-digit', minute: '2-digit' });
    }

    function formatTime(ts) {
        if (!ts) return '—';
        return new Date(ts).toLocaleTimeString('en-SG', { hour: '2-digit', minute: '2-digit' });
    }

    function isToday(ts) {
        if (!ts) return false;
        const d = new Date(ts);
        const now = new Date();
        return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate() === now.getDate();
    }

    // ── Render visits ──
    function renderVisits(visits) {
        const container = document.getElementById('visitsContainer');

        if (!visits || visits.length === 0) {
            container.innerHTML = `
                <div class="bg-white border border-stone-mid p-8 md:p-12 text-center">
                    <svg class="w-12 h-12 mx-auto text-stone-deep mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                    <h2 class="font-serif text-xl font-medium text-ink mb-2">No visits found</h2>
                    <p class="text-sm text-ink-light max-w-md mx-auto">
                        \${currentFilter === 'today' ? "You don't have any care visits scheduled for today." :
                          currentFilter === 'active' ? "No visits are currently active." :
                          "You don't have any care visits yet."}
                    </p>
                </div>`;
            return;
        }

        let html = '<div class="space-y-5">';
        visits.forEach(visit => {
            const statusKey = visit.status ? visit.status.toLowerCase() : 'scheduled';
            const progress = getStatusProgress(visit.status);
            const isActive = ['EN_ROUTE','CHECKED_IN','IN_PROGRESS'].includes(visit.status);
            const activeSteps = STATUS_ORDER.filter(s => s !== 'CANCELLED');

            html += `
            <div class="visit-card bg-white border border-stone-mid p-5 md:p-7" id="visit-\${visit.visitId}">
                <!-- Top row -->
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-5">
                    <div>
                        <div class="flex items-center gap-3">
                            <span class="text-xs uppercase tracking-[0.15em] text-ink-muted">
                                Visit <span class="text-ink">#\${visit.visitId}</span>
                            </span>
                            \${isActive ? '<div class="live-dot"></div>' : ''}
                        </div>
                        <p class="mt-1 text-sm text-ink-light">
                            Booking <span class="text-ink">#\${visit.bookingId}</span>
                        </p>
                    </div>
                    <div class="flex items-center gap-3">
                        <span class="inline-flex items-center px-3 py-1 text-xs font-normal status-\${statusKey}">
                            \${STATUS_LABEL[visit.status] || visit.status}
                        </span>
                    </div>
                </div>

                <!-- Progress bar -->
                \${visit.status !== 'CANCELLED' ? `
                <div class="mb-6">
                    <div class="progress-track">
                        <div class="progress-fill" style="width: \${progress}%"></div>
                    </div>
                    <div class="flex justify-between mt-2">
                        \${activeSteps.map((s, i) => {
                            const done = STATUS_ORDER.indexOf(visit.status) >= STATUS_ORDER.indexOf(s);
                            const isCurrent = visit.status === s;
                            return `<div class="text-center" style="flex:1;">
                                <div class="timeline-dot \${done ? 'active' : ''} \${isCurrent ? 'current' : ''}" style="margin:0 auto;"></div>
                                <p class="text-[10px] mt-1 \${done ? 'text-ink' : 'text-ink-muted'} hidden md:block">\${STATUS_LABEL[s]}</p>
                            </div>`;
                        }).join('')}
                    </div>
                </div>` : ''}

                <!-- Details grid -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-5 border-t border-stone-mid pt-5">
                    <!-- Caregiver -->
                    <div>
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Caregiver</h3>
                        <div class="flex items-center gap-3">
                            <div class="w-9 h-9 bg-stone-mid flex items-center justify-center flex-shrink-0">
                                <span class="font-serif text-sm text-ink">\${visit.caregiverName ? visit.caregiverName.charAt(0).toUpperCase() : '?'}</span>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-ink">\${visit.caregiverName || 'Unassigned'}</p>
                                \${isActive ? '<p class="text-xs text-forest">Currently on duty</p>' : ''}
                            </div>
                        </div>
                    </div>

                    <!-- Schedule -->
                    <div>
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Schedule</h3>
                        <p class="text-sm text-ink">\${formatDateTime(visit.scheduledStartTime)}</p>
                        <p class="text-xs text-ink-light mt-1">to \${formatTime(visit.scheduledEndTime)}</p>
                    </div>

                    <!-- Check-in/out times -->
                    \${visit.actualCheckInTime || visit.actualCheckOutTime ? `
                    <div>
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Check-In/Out</h3>
                        <div class="space-y-1">
                            \${visit.actualCheckInTime ? `
                                <p class="text-sm text-ink">
                                    <span class="text-ink-muted">In:</span> \${formatDateTime(visit.actualCheckInTime)}
                                    \${visit.isLate ? '<span class="text-xs text-copper ml-1">(Late)</span>' : ''}
                                </p>` : ''}
                            \${visit.actualCheckOutTime ? `
                                <p class="text-sm text-ink">
                                    <span class="text-ink-muted">Out:</span> \${formatDateTime(visit.actualCheckOutTime)}
                                </p>` : ''}
                        </div>
                    </div>` : ''}

                    <!-- Duration -->
                    \${visit.durationMinutes ? `
                    <div>
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Duration</h3>
                        <p class="text-sm text-ink">\${visit.durationMinutes} minutes</p>
                    </div>` : ''}

                    <!-- Location -->
                    \${visit.location ? `
                    <div>
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Location</h3>
                        <p class="text-sm text-ink-light">\${visit.location}</p>
                    </div>` : ''}

                    <!-- Notes -->
                    \${visit.notes ? `
                    <div class="md:col-span-2">
                        <h3 class="text-xs uppercase tracking-[0.15em] text-ink-muted mb-3">Notes</h3>
                        <p class="text-sm text-ink-light">\${visit.notes}</p>
                    </div>` : ''}
                </div>
            </div>`;
        });
        html += '</div>';
        container.innerHTML = html;
    }

    // ── Filter logic ──
    function filterVisits(tab) {
        currentFilter = tab;
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.getElementById('tab-' + tab).classList.add('active');

        let filtered;
        if (tab === 'today') {
            filtered = allVisits.filter(v => isToday(v.scheduledStartTime));
        } else if (tab === 'active') {
            filtered = allVisits.filter(v => ['EN_ROUTE','CHECKED_IN','IN_PROGRESS'].includes(v.status));
        } else {
            filtered = allVisits;
        }
        renderVisits(filtered);
    }

    // ── Load visits from API ──
    async function loadVisits() {
        try {
            const response = await fetch(API_BASE + '/api/service-visits/customer/' + CUSTOMER_ID);
            const data = await response.json();
            if (data.success && data.data) {
                allVisits = data.data;
                filterVisits(currentFilter);
            } else {
                allVisits = [];
                filterVisits(currentFilter);
            }
        } catch (error) {
            console.error('Error loading visits:', error);
            document.getElementById('visitsContainer').innerHTML =
                '<div class="bg-white border border-stone-mid p-8 text-center">' +
                '<p class="text-ink-muted text-sm">Unable to load visits. Please try again later.</p></div>';
        }
    }

    // ── WebSocket connection ──
    function connectWebSocket() {
        try {
            const socket = new SockJS(WS_URL);
            stompClient = Stomp.over(socket);
            stompClient.debug = null; // Disable debug logging

            stompClient.connect({}, function(frame) {
                document.getElementById('connectionStatus').textContent = 'Live Updates Active';
                document.getElementById('liveDot').style.background = '#3d4f3d';

                // Subscribe to customer-specific updates
                stompClient.subscribe('/topic/customer/' + CUSTOMER_ID + '/visits', function(message) {
                    const notification = JSON.parse(message.body);
                    handleNotification(notification);
                });
            }, function(error) {
                console.error('WebSocket error:', error);
                document.getElementById('connectionStatus').textContent = 'Reconnecting...';
                document.getElementById('liveDot').style.background = '#b87a4b';
                setTimeout(connectWebSocket, 5000);
            });
        } catch (e) {
            console.error('WebSocket connection failed:', e);
            document.getElementById('connectionStatus').textContent = 'Offline';
            document.getElementById('liveDot').style.background = '#8a8a8a';
        }
    }

    // ── Handle incoming notification ──
    function handleNotification(notification) {
        // Show toast
        showToast(notification);

        // Add to notification history
        addNotificationToHistory(notification);

        // Refresh visits data
        loadVisits();
    }

    function showToast(notification) {
        const toast = document.getElementById('notificationToast');
        document.getElementById('toastTitle').textContent = notification.eventType === 'CHECK_IN' ? 'Caregiver Checked In' :
            notification.eventType === 'CHECK_OUT' ? 'Caregiver Checked Out' : 'Visit Status Update';
        document.getElementById('toastMessage').textContent = notification.message || 'Visit status has been updated.';
        document.getElementById('toastTime').textContent = formatDateTime(notification.timestamp || new Date().toISOString());

        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 6000);
    }

    function hideToast() {
        document.getElementById('notificationToast').classList.remove('show');
    }

    function addNotificationToHistory(notification) {
        notificationLog.unshift(notification);
        if (notificationLog.length > 20) notificationLog.pop();

        const section = document.getElementById('notificationHistorySection');
        section.style.display = 'block';

        const container = document.getElementById('notificationHistory');
        const typeIcon = notification.eventType === 'CHECK_IN' ? '&#8594;' :
                         notification.eventType === 'CHECK_OUT' ? '&#8592;' : '&#8226;';

        const item = document.createElement('div');
        item.className = 'bg-white border border-stone-mid p-4 flex items-start gap-3';
        item.style.animation = 'fadeSlideIn 0.4s ease both';
        item.innerHTML = `
            <span class="text-copper text-lg mt-0.5">\${typeIcon}</span>
            <div class="flex-1">
                <p class="text-sm text-ink">\${notification.message || 'Status updated'}</p>
                <p class="text-xs text-ink-muted mt-1">\${formatDateTime(notification.timestamp || new Date().toISOString())}</p>
            </div>
            <span class="inline-flex items-center px-2 py-0.5 text-[10px] status-\${(notification.currentStatus || 'scheduled').toLowerCase()}">
                \${STATUS_LABEL[notification.currentStatus] || notification.currentStatus}
            </span>`;

        container.insertBefore(item, container.firstChild);

        // Keep max 10 visible
        while (container.children.length > 10) {
            container.removeChild(container.lastChild);
        }
    }

    // ── Auto-refresh every 30 seconds ──
    setInterval(loadVisits, 30000);

    // ── Init ──
    window.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => {
            document.getElementById('loader').classList.add('hidden');
            document.getElementById('pageContent').classList.add('visible');
        }, 400);
        loadVisits();
        connectWebSocket();
    });
    </script>
</body>
</html>
