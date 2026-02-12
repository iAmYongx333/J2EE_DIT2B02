<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful - Care Service</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .success-icon {
            font-size: 60px;
            margin-bottom: 20px;
        }
        h1 {
            font-size: 28px;
            color: #333;
            margin-bottom: 10px;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .details {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: left;
            border-left: 4px solid #28a745;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            font-size: 14px;
        }
        .detail-label {
            font-weight: 600;
            color: #333;
        }
        .detail-value {
            color: #666;
        }
        .button-group {
            display: flex;
            gap: 10px;
            flex-direction: column;
        }
        button, a {
            padding: 14px;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
            display: inline-block;
            border: none;
            cursor: pointer;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
            border: 1px solid #ddd;
        }
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        .footer {
            color: #666;
            font-size: 12px;
            margin-top: 20px;
            border-top: 1px solid #ddd;
            padding-top: 20px;
        }
        .footer a {
            color: #667eea;
            text-decoration: none;
        }
        .footer a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">✅</div>
        <h1>Payment Successful!</h1>
        <p class="subtitle">Your care service booking has been confirmed</p>
        
        <div class="details">
            <div class="detail-row">
                <span class="detail-label">Booking ID:</span>
                <span class="detail-value"><%=request.getParameter("bookingId") != null ? request.getParameter("bookingId") : "N/A"%></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Payment ID:</span>
                <span class="detail-value"><%=request.getParameter("paymentId") != null ? request.getParameter("paymentId").substring(0, Math.min(20, request.getParameter("paymentId").length())) + "..." : "N/A"%></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value" style="color: #28a745; font-weight: 600;">Confirmed</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Time:</span>
                <span class="detail-value"><%=new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm:ss").format(new java.util.Date())%></span>
            </div>
        </div>

        <div class="button-group">
            <button class="btn-primary" onclick="window.location.href='/'">Back to Home</button>
            <a href="/bookings" class="btn-secondary">View My Bookings</a>
        </div>

        <div class="footer">
            <p>A confirmation email has been sent to your registered email address.</p>
            <p>If you have any questions, <a href="/support">contact our support team</a></p>
        </div>
    </div>

    <script>
        // Log for debugging
        console.log('[Success] Payment confirmed');
        console.log('[Success] Booking ID:', '<%=request.getParameter("bookingId")%>');
        console.log('[Success] Payment ID:', '<%=request.getParameter("paymentId")%>');
    </script>
</body>
</html>
