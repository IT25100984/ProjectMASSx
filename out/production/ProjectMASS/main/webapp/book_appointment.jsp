<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.projectmass.dao.UserDAO, com.projectmass.model.User, java.util.List" %>

<%
    UserDAO userDao = new UserDAO();
    List<User> doctorList = userDao.getAllDoctors();
    request.setAttribute("doctorList", doctorList);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="card shadow border-0 mx-auto" style="max-width: 500px;">
        <div class="card-header bg-primary text-white py-3">
            <h4 class="mb-0 fw-bold"><i class="bi bi-calendar-check me-2"></i>Schedule Appointment</h4>
        </div>
        <div class="card-body p-4">

            <c:if test="${not empty param.errorMsg}">
                <div class="alert alert-danger shadow-sm border-0">
                    <i class="bi bi-exclamation-octagon-fill me-1"></i> ${param.errorMsg}
                </div>
            </c:if>

            <form action="bookAppointment" method="POST">
                <div class="mb-3">
                    <label for="specializationSelect" class="form-label fw-semibold">Select Specialization</label>
                    <select id="specializationSelect" class="form-select" onchange="updateDoctorList()">
                        <option value="" selected disabled>Select Specialization</option>
                        <%-- Change value to "All Specializations" to match your JS check --%>
                        <option value="All Specializations">All Specializations</option>
                        <option value="General Practitioner">General Practitioner</option>
                        <option value="Dermatology">Dermatology</option>
                        <option value="Cardiology">Cardiology</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="doctorSelect" class="form-label fw-semibold">Select Doctor</label>
                    <select name="doctorId" id="doctorSelect" class="form-select" onchange="fetchSlots()" required>
                        <option value="" selected disabled>Choose a doctor...</option>
                        <c:forEach var="doc" items="${doctorList}">
                            <option value="${doc.userID}">Dr. ${doc.firstName} ${doc.lastName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="datePicker" class="form-label fw-semibold">Select Date</label>
                    <input type="date" name="date" id="datePicker" class="form-control" onchange="fetchSlots()" required>
                </div>

                <div class="mb-4">
                    <%-- Fixed: Added 'for' attribute linked to ID --%>
                    <label for="timeSlotSelect" class="form-label fw-semibold">Available Time Slots</label>
                    <select name="time" id="timeSlotSelect" class="form-select" required>
                        <option value="" selected disabled>Choose a date & doctor first...</option>
                    </select>
                    <div id="slotSpinner" class="form-text text-muted d-none">
                        <div class="spinner-border spinner-border-sm text-primary me-1" role="status"></div>
                        Checking doctor schedule...
                    </div>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-primary py-2 shadow-sm">Confirm Booking</button>
                    <a href="patientDashboard" class="btn btn-outline-secondary">Back to Dashboard</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Automatically set the date picker to Today's date
        const today = new Date().toISOString().split('T')[0];
        const dateInput = document.getElementById('datePicker');
        if (dateInput) {
            dateInput.setAttribute('min', today);
            dateInput.value = today;
        }
    });

    function filterDoctors() {
        const selectedSpec = document.getElementById("specialization").value;
        const doctorSelect = document.getElementById("doctorSelect");
        const options = doctorSelect.querySelectorAll("option");

        // Reset doctor selection when specialization changes
        doctorSelect.selectedIndex = 0;
        document.getElementById("timeSlotSelect").innerHTML = '<option value="" selected disabled>Choose a date & doctor first...</option>';

        options.forEach(opt => {
            if (opt.value === "") return;
            const doctorSpec = opt.getAttribute("data-spec");
            if (selectedSpec === "All" || doctorSpec === selectedSpec) {
                opt.hidden = false;
                opt.disabled = false;
            } else {
                opt.hidden = true;
                opt.disabled = true;
            }
        });
    }

   function updateDoctorList() {
       const specSelect = document.getElementById("specializationSelect");
       const doctorSelect = document.getElementById("doctorSelect");

       if (!specSelect || !doctorSelect) return;
       let spec = specSelect.value;

       // 🛑 REMOVE the return here. Instead, normalize the value:
       if (spec === "Select Specialization" || spec === "All Specializations") {
           spec = ""; // Sending an empty string tells the Servlet to fetch ALL
       }

       const url = "getDoctorsBySpec?specialization=" + encodeURIComponent(spec);

       fetch(url)
           .then(response => response.json())
           .then(doctors => {
               doctorSelect.innerHTML = '<option value="" selected disabled>Choose a doctor...</option>';

               if (doctors.length === 0) {
                   doctorSelect.innerHTML = '<option disabled>No doctors available</option>';
                   return;
               }

               doctors.forEach(doc => {
                   const option = document.createElement("option");
                   // Ensure doc.userID matches your DoctorDTO field name exactly
                   option.value = doc.userID;
                   option.textContent = "Dr. " + (doc.firstName || "Unknown") + " " + (doc.lastName || "");
                   doctorSelect.appendChild(option);
               });
           })
           .catch(err => {
               console.error("Error:", err);
               doctorSelect.innerHTML = '<option disabled>Error loading doctors</option>';
           });
   }

   function fetchSlots() {
       const doctorSelect = document.getElementById("doctorSelect");
       const dateInput = document.getElementById("datePicker");
       const timeSelect = document.getElementById("timeSlotSelect");

       // Get current values
       const doctorId = doctorSelect ? doctorSelect.value : "";
       const rawDate = dateInput ? dateInput.value : "";

       // Prepare the URL
       const sanitizedDate = rawDate.replace(/\//g, "-");

       const params = new URLSearchParams();
       params.append("doctorId", doctorId);
       params.append("date", sanitizedDate);

       // 🛑 DEBUGGING: Confirm these show in your F12 console
       console.log("Doctor ID detected:", doctorId);
       console.log("Original Date from UI:", rawDate);

       // 🛑 SAFETY GUARD: Prevent the call if data is missing
       if (!doctorId || !rawDate) {
           console.warn("Fetch blocked: Doctor or Date is missing.");
           return;
       }

       const queryString = params.toString();
       const finalUrl = "getAvailableSlots?" + queryString;

       // 🛑 DEBUGGING: This MUST show the full string now
       console.log("Query String generated:", queryString);
       console.log("Final URL being called:", finalUrl);

       timeSelect.innerHTML = '<option value="" selected disabled>Loading hours...</option>';

       fetch(finalUrl)
           .then(response => {
               if (!response.ok) throw new Error("Server Error: " + response.status);
               return response.json();
           })
           .then(slots => {
               timeSelect.innerHTML = '';
               if (!slots || slots.length === 0) {
                   timeSelect.innerHTML = '<option value="" disabled>No available hours found.</option>';
               } else {
                   timeSelect.innerHTML = '<option value="" selected disabled>Choose a time...</option>';
                   slots.forEach(slot => {
                       const option = document.createElement("option");
                       option.value = slot;
                       option.text = slot;
                       timeSelect.appendChild(option);
                   });
               }
           })
           .catch(err => {
               console.error("AJAX Error:", err);
               timeSelect.innerHTML = '<option value="" disabled>Error loading slots.</option>';
           });
   }
</script>
</body>
</html>