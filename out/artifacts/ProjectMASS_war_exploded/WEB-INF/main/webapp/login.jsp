<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Login | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <% if ("loggedout".equals(request.getParameter("msg"))) { %>
            <div class="alert alert-info shadow-sm text-center mb-4">
                You have been successfully logged out.
            </div>
            <% } %>

            <% if ("registered".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success">
                Account created! Please log in.
            </div>
            <% } %>

            <% if ("failed".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger shadow-sm text-center mb-4">
                Invalid Email or Password.
            </div>
            <% } %>

            <div class="card shadow">
                <div class="card-header bg-primary text-white text-center">
                    <h4>Hospital Portal Login</h4>
                </div>
                <div class="card-body">
                    <form action="login" method="POST">
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="text" name="username" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Login</button>
                    </form>
                </div>
                <div class="card-footer text-center">
                    <small>Don't have an account? <a href="register.jsp">Register here</a></small>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>