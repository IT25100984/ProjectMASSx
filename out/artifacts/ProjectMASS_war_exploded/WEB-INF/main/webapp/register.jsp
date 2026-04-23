<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white text-center">
                    <h4>Create Account</h4>
                </div>
                <div class="card-body">
                    <form action="register" method="POST">
                        <div class="mb-3">
                            <label class="form-label">First Name</label>
                            <input type="text" name="firstName" class="form-control" placeholder="Enter first name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Last Name</label>
                            <input type="text" name="lastName" class="form-control" placeholder="Enter last name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email Address</label>
                            <input type="email" name="email" class="form-control" placeholder="name@example.com" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" name="password" class="form-control" placeholder="Create a password" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">I am a...</label>
                            <select name="role" class="form-select">
                                <option value="PATIENT">Patient</option>
                                <option value="DOCTOR">Doctor</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Create Account</button>
                    </form>
                </div>
                <div class="card-footer text-center">
                    <small>Already have an account? <a href="login.jsp">Login here</a></small>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>