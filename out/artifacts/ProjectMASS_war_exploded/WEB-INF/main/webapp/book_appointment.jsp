<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.projectmass.dao.UserDAO, com.projectmass.model.User, java.util.List" %>
<%
    UserDAO userDao = new UserDAO();
    List<User> doctorList = userDao.getAllDoctors();
    request.setAttribute("doctorList", doctorList);
%>
<html>
<head>
    <title>Book Appointment | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="card shadow-sm mx-auto" style="max-width: 500px;">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Schedule Appointment</h4>
        </div>
        <div class="card-body">

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger">${errorMsg}</div>
            </c:if>

            <form action="bookAppointment" method="POST">
                <%-- REMOVED: The hidden input was causing the empty string error --%>

                <div class="mb-3">
                    <label class="form-label">Select Specialization</label>
                    <select id="specialization" class="form-select" onchange="filterDoctors()">
                        <option value="All">All Specializations</option>
                        <option value="Cardiology">Cardiology</option>
                        <option value="General Practitioner">General Practitioner</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Select Doctor</label>
                    <select name="doctorId" id="doctorSelect" class="form-select" required>
                        <option value="" selected disabled>Choose a doctor...</option>
                        <c:forEach var="doc" items="${doctorList}">
                            <option value="${doc.userID}" data-spec="${doc.specialization}">
                                Dr. ${doc.firstName} ${doc.lastName} (${doc.specialization})
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Select Date</label>
                    <input type="date" name="date" id="datePicker" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Available Time Slots</label>
                    <select name="time" class="form-select" required>
                        <option value="" selected disabled>Choose a time...</option>
                        <option value="09:00:00">09:00 AM</option>
                        <option value="10:00:00">10:00 AM</option>
                        <option value="11:00:00">11:00 AM</option>
                        <option value="14:00:00">02:00 PM</option>
                        <option value="15:00:00">03:00 PM</option>
                    </select>
                </div>

                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">Confirm Booking</button>
                    <a href="patient_dashboard.jsp" class="btn btn-link text-center mt-2">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Set date logic
    const today = new Date().toISOString().split('T')[0];
    const dateInput = document.getElementById('datePicker');
    dateInput.setAttribute('min', today);
    dateInput.value = today;

    function filterDoctors() {
        let spec = document.getElementById("specialization").value;
        let select = document.getElementById("doctorSelect");
        let options = select.options;

        // Reset selection when filtering
        select.value = "";

        for (let i = 0; i < options.length; i++) {
            let doctorSpec = options[i].getAttribute("data-spec");
            if (spec === "All" || doctorSpec === spec || options[i].disabled) {
                options[i].hidden = false;
                options[i].disabled = false;
            } else {
                options[i].hidden = true;
                options[i].disabled = true; // Disabled options aren't submitted
            }
        }
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>