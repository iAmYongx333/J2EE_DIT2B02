<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*,Assignment1.CartItem" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Checkout | SilverCare</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant:ital,wght@0,400;0,500;0,600;1,400&family=Outfit:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://js.stripe.com/v3/"></script>
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
        .StripeElement {
            padding: 12px 16px;
            border: 1px solid #e8e4dc;
            background-color: white;
            transition: border-color 0.2s;
        }
        .StripeElement--focus {
            border-color: #2c2c2c;
        }
        .StripeElement--invalid {
            border-color: #dc2626;
        }
    </style>
    <%
        Object userRole = session.getAttribute("sessRole");
        if (userRole == null) {
            response.sendRedirect(request.getContextPath() + "/login?errCode=NoSession");
            return;
        }
        
        // Get checkout data
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        Double checkoutAmount = (Double) session.getAttribute("checkoutAmount");
        String customerEmail = (String) session.getAttribute("checkoutEmail");
        String customerName = (String) session.getAttribute("checkoutName");
        String userId = String.valueOf(session.getAttribute("sessId"));
        
        if (customerEmail == null) customerEmail = (String) session.getAttribute("sessEmail");
        if (customerName == null) customerName = (String) session.getAttribute("sessName");
        
        double totalAmount = 0.0;
        if (checkoutAmount != null) {
            totalAmount = checkoutAmount;
        } else if (cart != null) {
            for (CartItem item : cart) {
                totalAmount += item.getLineTotal();
            }
        }
    %>
</head>

<body class="bg-stone-warm text-ink font-sans font-light min-h-screen">
    <%@ include file="includes/header.jsp" %>

    <main class="pt-24 max-w-4xl mx-auto px-5 md:px-12 py-12 md:py-16">
        <div class="mb-10">
            <span class="text-copper text-xs uppercase tracking-[0.2em]">Complete Your Booking</span>
            <h1 class="font-serif text-3xl md:text-4xl font-medium text-ink mt-2">Secure Checkout</h1>
            <p class="mt-3 text-ink-light text-base max-w-xl">
                Enter your payment details below to confirm your care service booking.
            </p>
        </div>

        <div class="grid md:grid-cols-5 gap-8">
            <!-- Payment Form -->
            <div class="md:col-span-3">
                <div class="bg-white border border-stone-mid p-6 md:p-8">
                    <h2 class="font-serif text-xl font-medium text-ink mb-6">Payment Details</h2>
                    
                    <form id="payment-form" class="space-y-5">
                        <div>
                            <label class="block text-sm text-ink mb-2">
                                Email Address <span class="text-copper">*</span>
                            </label>
                            <input type="email" id="email" required
                                   value="<%= customerEmail != null ? customerEmail : "" %>"
                                   placeholder="your@email.com"
                                   class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                        </div>

                        <div>
                            <label class="block text-sm text-ink mb-2">
                                Full Name <span class="text-copper">*</span>
                            </label>
                            <input type="text" id="name" required
                                   value="<%= customerName != null ? customerName : "" %>"
                                   placeholder="John Doe"
                                   class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                        </div>

                        <div>
                            <label class="block text-sm text-ink mb-2">Phone Number</label>
                            <input type="tel" id="phone" placeholder="+65 1234 5678"
                                   class="w-full border border-stone-mid px-4 py-3 text-sm focus:outline-none focus:border-ink bg-white">
                        </div>

                        <div>
                            <label class="block text-sm text-ink mb-2">
                                Card Details <span class="text-copper">*</span>
                            </label>
                            <div id="card-element"></div>
                            <div id="card-errors" class="text-red-600 text-xs mt-2"></div>
                        </div>

                        <button type="submit" id="submit-btn"
                                class="w-full bg-ink text-stone-warm px-6 py-4 text-sm font-normal hover:bg-ink-light transition-colors flex items-center justify-center gap-2 mt-6">
                            <span id="button-text">Pay $<%= String.format("%.2f", totalAmount) %></span>
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                            </svg>
                        </button>
                    </form>

                    <!-- Loading State -->
                    <div id="loading" class="hidden mt-6 text-center">
                        <div class="inline-block w-6 h-6 border-2 border-stone-mid border-t-ink animate-spin"></div>
                        <p class="text-ink-muted text-sm mt-3">Processing your payment...</p>
                    </div>

                    <!-- Message Display -->
                    <div id="message" class="hidden mt-6 p-4 border text-sm"></div>

                    <div class="mt-6 pt-6 border-t border-stone-mid">
                        <a href="<%=request.getContextPath()%>/cart" 
                           class="text-ink-muted text-sm hover:text-ink transition-colors inline-flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 16l-4-4m0 0l4-4m-4 4h18"/>
                            </svg>
                            Back to Cart
                        </a>
                    </div>
                </div>
            </div>

            <!-- Order Summary -->
            <div class="md:col-span-2">
                <div class="bg-white border border-stone-mid p-6 md:p-8">
                    <h2 class="font-serif text-xl font-medium text-ink mb-6">Order Summary</h2>
                    
                    <% if (cart != null && !cart.isEmpty()) { %>
                        <div class="space-y-4 mb-6">
                            <% for (CartItem item : cart) { %>
                                <div class="flex justify-between text-sm">
                                    <div>
                                        <div class="text-ink"><%= item.getServiceName() %></div>
                                        <div class="text-ink-muted text-xs">Qty: <%= item.getQuantity() %></div>
                                    </div>
                                    <div class="text-ink font-medium">$<%= String.format("%.2f", item.getLineTotal()) %></div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                    
                    <div class="border-t border-stone-mid pt-4">
                        <div class="flex justify-between text-sm text-ink-light mb-2">
                            <span>Subtotal</span>
                            <span>$<%= String.format("%.2f", totalAmount) %></span>
                        </div>
                        <div class="flex justify-between text-sm text-ink-light mb-2">
                            <span>Tax</span>
                            <span>$0.00</span>
                        </div>
                        <div class="flex justify-between font-medium text-ink mt-4 pt-4 border-t border-stone-mid">
                            <span class="font-serif text-lg">Total</span>
                            <span class="font-serif text-xl" id="total-display">$<%= String.format("%.2f", totalAmount) %></span>
                        </div>
                    </div>

                    <div class="mt-6 pt-6 border-t border-stone-mid">
                        <div class="flex items-center gap-2 text-xs text-ink-muted mb-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                            </svg>
                            Secure payment powered by Stripe
                        </div>
                        <div class="flex items-center gap-2 text-xs text-ink-muted">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                            </svg>
                            256-bit SSL encryption
                        </div>
                    </div>
                </div>

                <!-- Test Card Notice -->
                <div class="bg-stone-mid/50 border border-stone-mid p-4 mt-4">
                    <div class="text-xs text-ink-muted">
                        <span class="font-medium text-ink block mb-1">Test Mode</span>
                        Use card: <span class="font-mono">4242 4242 4242 4242</span><br>
                        Any future date, any CVC
                    </div>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

    <script>
        // Configuration
        const BACKEND_URL = 'http://localhost:8081/api';
        const FRONTEND_URL = '<%=request.getContextPath()%>';
        const USER_ID = '<%= userId %>';
        const TOTAL_AMOUNT = <%= (int)(totalAmount * 100) %>;
        
        let stripe;
        let elements;
        let cardElement;

        // Initialize Stripe
        async function initStripe() {
            try {
                console.log('[Stripe] Initializing...');
                
                const response = await fetch(BACKEND_URL + '/payments/config');
                if (!response.ok) throw new Error('Failed to fetch Stripe config');
                
                const { publishableKey } = await response.json();
                console.log('[Stripe] Publishable key loaded');
                
                stripe = Stripe(publishableKey);
                elements = stripe.elements();
                
                cardElement = elements.create('card', {
                    style: {
                        base: {
                            fontFamily: 'Outfit, system-ui, sans-serif',
                            fontSize: '14px',
                            color: '#2c2c2c',
                            '::placeholder': { color: '#8a8a8a' }
                        },
                        invalid: { color: '#dc2626' }
                    }
                });
                cardElement.mount('#card-element');

                cardElement.addEventListener('change', (event) => {
                    const displayError = document.getElementById('card-errors');
                    displayError.textContent = event.error ? event.error.message : '';
                });

                console.log('[Stripe] Initialization complete');
            } catch (error) {
                console.error('[Stripe] Init error:', error);
                showMessage('Failed to load payment system. Please refresh.', 'error');
            }
        }

        // Create PaymentIntent
        async function createPaymentIntent() {
            const email = document.getElementById('email').value;
            
            const response = await fetch(BACKEND_URL + '/payments/intents', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    amount: TOTAL_AMOUNT,
                    currency: 'sgd',
                    customerId: USER_ID,
                    description: 'SilverCare Service Booking'
                })
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(errorText);
            }
            
            return await response.json();
        }

        // Complete booking after payment
        async function completeBooking(paymentIntentId) {
            try {
                const response = await fetch(FRONTEND_URL + '/payment/complete', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'paymentIntentId=' + paymentIntentId
                });
                return await response.json();
            } catch (error) {
                console.error('[Booking] Error:', error);
                return { success: true };
            }
        }

        // Handle form submission
        document.getElementById('payment-form').addEventListener('submit', async (e) => {
            e.preventDefault();

            const email = document.getElementById('email').value;
            const name = document.getElementById('name').value;

            if (!email || !name) {
                showMessage('Please fill in all required fields.', 'error');
                return;
            }

            const submitBtn = document.getElementById('submit-btn');
            const buttonText = document.getElementById('button-text');
            const loading = document.getElementById('loading');
            
            submitBtn.disabled = true;
            submitBtn.classList.add('opacity-50', 'cursor-not-allowed');
            buttonText.textContent = 'Processing...';
            loading.classList.remove('hidden');

            try {
                const { clientSecret, paymentIntentId } = await createPaymentIntent();

                const { paymentIntent, error } = await stripe.confirmCardPayment(clientSecret, {
                    payment_method: {
                        card: cardElement,
                        billing_details: {
                            name: name,
                            email: email,
                            phone: document.getElementById('phone').value || undefined
                        }
                    }
                });

                loading.classList.add('hidden');

                if (error) {
                    showMessage(error.message, 'error');
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                    buttonText.textContent = 'Pay $<%= String.format("%.2f", totalAmount) %>';
                } else if (paymentIntent.status === 'succeeded') {
                    await completeBooking(paymentIntentId);
                    showMessage('Payment successful! Redirecting...', 'success');
                    buttonText.textContent = 'Payment Complete';
                    
                    setTimeout(() => {
                        window.location.href = FRONTEND_URL + '/success?paymentId=' + paymentIntentId;
                    }, 1500);
                } else {
                    showMessage('Payment status: ' + paymentIntent.status, 'warning');
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                    buttonText.textContent = 'Pay $<%= String.format("%.2f", totalAmount) %>';
                }
            } catch (error) {
                console.error('[Payment] Error:', error);
                loading.classList.add('hidden');
                submitBtn.disabled = false;
                submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                buttonText.textContent = 'Pay $<%= String.format("%.2f", totalAmount) %>';
                showMessage('An error occurred. Please try again.', 'error');
            }
        });

        function showMessage(text, type) {
            const messageEl = document.getElementById('message');
            messageEl.classList.remove('hidden', 'border-green-500', 'bg-green-50', 'text-green-800',
                                       'border-red-500', 'bg-red-50', 'text-red-800',
                                       'border-yellow-500', 'bg-yellow-50', 'text-yellow-800');
            
            if (type === 'success') {
                messageEl.classList.add('border-green-500', 'bg-green-50', 'text-green-800');
            } else if (type === 'error') {
                messageEl.classList.add('border-red-500', 'bg-red-50', 'text-red-800');
            } else {
                messageEl.classList.add('border-yellow-500', 'bg-yellow-50', 'text-yellow-800');
            }
            
            messageEl.textContent = text;
        }

        window.addEventListener('DOMContentLoaded', initStripe);
    </script>
</body>
</html>
