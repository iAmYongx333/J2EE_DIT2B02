<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Integration Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        h1 { color: #333; }
        .test-section {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
            border-left: 4px solid #667eea;
        }
        .test-result {
            padding: 10px;
            margin-top: 10px;
            border-radius: 3px;
            font-family: monospace;
        }
        .success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .loading {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        button {
            background: #667eea;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
        }
        button:hover { background: #5568d3; }
        button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .link-button {
            display: inline-block;
            background: #28a745;
            padding: 10px 20px;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 10px;
        }
        .link-button:hover { background: #218838; }
        input {
            padding: 8px;
            margin: 5px 0;
            border: 1px solid #ddd;
            border-radius: 3px;
            width: 100%;
            max-width: 400px;
        }
        code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <h1>🧪 Payment Integration Test Dashboard</h1>
    
    <div class="test-section">
        <h2>1. Backend Connectivity</h2>
        <p>Check if Spring Boot backend is running and accessible</p>
        <button onclick="testBackendConnection()">Test Backend Connection</button>
        <div id="backend-result"></div>
    </div>

    <div class="test-section">
        <h2>2. Get Stripe Config</h2>
        <p>Fetch Stripe publishable key from backend</p>
        <button onclick="testGetStripeConfig()">Get Stripe Config</button>
        <div id="config-result"></div>
    </div>

    <div class="test-section">
        <h2>3. Create Payment Intent</h2>
        <p>Test creating a PaymentIntent (requires valid booking)</p>
        <div>
            <label>Booking ID:</label>
            <input type="text" id="bookingId" placeholder="e.g., 1" value="1">
            <label>Email:</label>
            <input type="email" id="email" placeholder="test@example.com" value="test@example.com">
        </div>
        <button onclick="testCreatePaymentIntent()">Create Payment Intent</button>
        <div id="payment-result"></div>
    </div>

    <div class="test-section">
        <h2>4. Go to Checkout Page</h2>
        <p>Open the actual checkout page</p>
        <div>
            <label>Booking ID:</label>
            <input type="text" id="checkoutBookingId" placeholder="e.g., 1" value="1">
            <label>Email:</label>
            <input type="email" id="checkoutEmail" placeholder="test@example.com" value="test@example.com">
            <label>Name:</label>
            <input type="text" id="checkoutName" placeholder="John Doe" value="John Doe">
        </div>
        <button onclick="goToCheckout()">Go to Checkout Page</button>
    </div>

    <div class="test-section">
        <h2>5. Test Status Codes</h2>
        <p>Various backend endpoints status</p>
        <button onclick="testAllEndpoints()">Test All Endpoints</button>
        <div id="status-result"></div>
    </div>

    <script>
        const BACKEND_URL = 'http://localhost:8081/api';

        function showResult(elementId, message, type = 'loading') {
            const el = document.getElementById(elementId);
            el.innerHTML = `<div class="test-result ${type}">${message}</div>`;
        }

        function appendResult(elementId, message, type = 'loading') {
            const el = document.getElementById(elementId);
            el.innerHTML += `<div class="test-result ${type}" style="margin-top: 5px;">${message}</div>`;
        }

        async function testBackendConnection() {
            showResult('backend-result', '⏳ Testing connection...', 'loading');
            try {
                const response = await fetch(`${BACKEND_URL}/payments/config`, {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/json' }
                });
                
                if (response.ok) {
                    showResult('backend-result', '✅ Backend is running and accessible!', 'success');
                    appendResult('backend-result', `URL: ${BACKEND_URL}`, 'success');
                    appendResult('backend-result', `Status: ${response.status}`, 'success');
                } else {
                    showResult('backend-result', `❌ HTTP Error ${response.status}`, 'error');
                }
            } catch (error) {
                showResult('backend-result', `❌ Connection failed: ${error.message}`, 'error');
                appendResult('backend-result', 'Make sure Spring Boot backend is running on port 8081', 'error');
            }
        }

        async function testGetStripeConfig() {
            showResult('config-result', '⏳ Fetching Stripe config...', 'loading');
            try {
                const response = await fetch(`${BACKEND_URL}/payments/config`);
                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                
                const data = await response.json();
                showResult('config-result', '✅ Stripe config retrieved!', 'success');
                appendResult('config-result', `Publishable Key: ${data.publishableKey.substring(0, 20)}...`, 'success');
            } catch (error) {
                showResult('config-result', `❌ Failed: ${error.message}`, 'error');
            }
        }

        async function testCreatePaymentIntent() {
            const bookingId = document.getElementById('bookingId').value;
            const email = document.getElementById('email').value;
            
            if (!bookingId || !email) {
                showResult('payment-result', '❌ Please fill in all fields', 'error');
                return;
            }
            
            showResult('payment-result', '⏳ Creating PaymentIntent...', 'loading');
            try {
                const response = await fetch(`${BACKEND_URL}/payments/intents`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        bookingId: bookingId,
                        currency: 'sgd',
                        customerEmail: email,
                        description: 'Test Payment'
                    })
                });
                
                if (!response.ok) throw new Error(`HTTP ${response.status}`);
                
                const data = await response.json();
                showResult('payment-result', '✅ PaymentIntent created!', 'success');
                appendResult('payment-result', `Payment ID: ${data.paymentIntentId}`, 'success');
                appendResult('payment-result', `Amount: SGD ${(data.amount / 100).toFixed(2)}`, 'success');
                appendResult('payment-result', `Status: ${data.status}`, 'success');
            } catch (error) {
                showResult('payment-result', `❌ Failed: ${error.message}`, 'error');
            }
        }

        function goToCheckout() {
            const bookingId = document.getElementById('checkoutBookingId').value;
            const email = encodeURIComponent(document.getElementById('checkoutEmail').value);
            const name = encodeURIComponent(document.getElementById('checkoutName').value);
            
            if (!bookingId) {
                alert('Please enter a booking ID');
                return;
            }
            
            window.location.href = `/checkout?bookingId=${bookingId}&email=${email}&name=${name}`;
        }

        async function testAllEndpoints() {
            showResult('status-result', '⏳ Testing all endpoints...', 'loading');
            
            const endpoints = [
                { name: 'Config', url: '/payments/config', method: 'GET' },
                { name: 'Payment Intents', url: '/payments/intents', method: 'POST' },
                { name: 'Webhook', url: '/payments/webhook', method: 'POST' }
            ];
            
            let results = '';
            for (const endpoint of endpoints) {
                try {
                    const response = await fetch(`${BACKEND_URL}${endpoint.url}`, {
                        method: endpoint.method,
                        headers: { 'Content-Type': 'application/json' },
                        body: endpoint.method === 'POST' ? '{}' : undefined
                    });
                    results += `✅ ${endpoint.name}: ${response.status}<br>`;
                } catch (error) {
                    results += `❌ ${endpoint.name}: ${error.message}<br>`;
                }
            }
            
            showResult('status-result', results, 'success');
        }

        // Test on page load
        window.addEventListener('DOMContentLoaded', () => {
            console.log('Test Dashboard loaded');
            console.log('Backend URL:', BACKEND_URL);
        });
    </script>
</body>
</html>
