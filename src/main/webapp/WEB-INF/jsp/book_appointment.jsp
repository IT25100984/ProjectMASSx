<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

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

            <form action="bookAppointment" method="post">

                <div class="mb-3">
                    <label class="form-label fw-semibold">Appointment Type</label>
                    <select class="form-select border-primary-subtle" id="typeSelect" name="appointmentType"
                            onchange="toggleSurgeryOptions(); updatePricePreview();" required>
                        <option value="CONSULTATION" selected>General Consultation</option>
                        <option value="SURGERY">Surgery / Operation</option>
                    </select>
                </div>

                <div class="mb-3 p-3 bg-warning-subtle rounded border border-warning" id="surgeryOptions" style="display:none;">
                    <label for="extraCharge" class="form-label fw-semibold text-warning-emphasis">Select Surgical Service</label>
                    <select class="form-select" id="extraCharge" name="additionalCharge" onchange="updatePricePreview()">
                        <option value="none" selected>Standard Surgery</option>
                        <option value="anesthesia">Anesthesia Service (+LKR 2500)</option>
                        <option value="facility">Facility/Hospital Charges (+LKR 1500)</option>
                        <option value="equipment">Specialized Equipment (+LKR 3000)</option>
                    </select>
                    <div class="form-text">Base Surgery Fee: LKR 5000.00</div>
                </div>

                <div class="mb-3">
                    <label for="specializationSelect" class="form-label fw-semibold">Select Specialization</label>
                    <select id="specializationSelect" class="form-select" onchange="updateDoctorList()">
                        <option value="" selected disabled>Select Specialization</option>
                        <%-- Change value to "All Specializations" to match your JS check --%>
                        <option value="All Specializations">All Specializations</option>
                        <option value="General Practitioner">General Practitioner</option>
                        <option value="Pharmacist">Pharmacist</option>
                        <option value="Dermatology">Dermatology</option>
                        <option value="Cardiology">Cardiology</option>
                        <option value="Pediatric">Pediatric</option>
                        <option value="Neurology">Neurology</option>
                        <option value="Orthopedic">Orthopedic</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="doctorSelect" class="form-label fw-semibold">Select Doctor</label>
                    <div class="input-group">
                        <select name="doctorId" id="doctorSelect" class="form-select" onchange="onDoctorChange()" required>
                            <option value="" selected disabled>Choose a doctor...</option>
                            <c:forEach var="doc" items="${doctorList}">
                                <option value="${doc.userID}">Dr. ${doc.firstName} ${doc.lastName}</option>
                            </c:forEach>
                        </select>
                        <button class="btn btn-outline-primary" type="button" id="viewHistoryBtn"
                                onclick="fetchAppointmentHistory()" disabled>
                            <i class="bi bi-clock-history"></i> History
                        </button>
                    </div>
                </div>

                <div id="historyDisplay" class="mt-2 mb-3 shadow-sm p-3 bg-white border rounded" style="display:none;">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="mb-0">Billing History</h6>
                        <button type="button" class="btn-close" style="font-size: 0.7rem;" onclick="document.getElementById('historyDisplay').style.display='none'"></button>
                    </div>
                    <ul id="historyList" class="list-group list-group-flush small"></ul>
                </div>

                <div class="mb-3">
                    <label for="datePicker" class="form-label fw-semibold">Select Date</label>
                    <input type="date" name="date" id="datePicker" class="form-control" onchange="fetchSlots()" required>
                </div>

                <div class="mb-4">
                    <label for="timeSlotSelect" class="form-label fw-semibold">Available Time Slots</label>
                    <select name="time" id="timeSlotSelect" class="form-select" required>
                        <option value="" selected disabled>Choose a date & doctor first...</option>
                    </select>
                </div>

                <div class="alert alert-info py-2 shadow-sm d-flex justify-content-between align-items-center mb-3">
                    <span class="fw-bold text-uppercase small"><i class="bi bi-cash-stack me-1"></i> Estimated Total:</span>
                    <span id="pricePreview" class="fs-5 fw-bold text-primary">LKR 2000.00</span>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-success fw-bold">Confirm Booking</button>
                    <a href="patientDashboard" class="btn btn-outline-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>

    function updatePricePreview() {
        const type = document.getElementById('typeSelect').value;
        const extra = document.getElementById('extraCharge').value;
        const preview = document.getElementById('pricePreview');

        if (type === 'SURGERY') {
            let base = 5000;
            let extraCost = 0;

            // Match the logic in your Surgery.java calculateFee()
            if (extra === 'anesthesia') extraCost = 2500;
            else if (extra === 'facility') extraCost = 1500;
            else if (extra === 'equipment') extraCost = 3000;
            else extraCost = 500; // Default misc

            preview.innerText = "LKR " + (base + extraCost).toFixed(2);
        } else {
            preview.innerText = "LKR 2000.00";
        }
    }
    // Logic to toggle Surgery Dropdown
    function toggleSurgeryOptions() {
        const type = document.getElementById('typeSelect').value;
        const surgeryDiv = document.getElementById('surgeryOptions');
        surgeryDiv.style.display = (type === 'SURGERY') ? 'block' : 'none';
    }

    // Helper to handle doctor change (Update slots + enable history button)
    function onDoctorChange() {
        const doctorSelect = document.getElementById('doctorSelect');
        const historyBtn = document.getElementById('viewHistoryBtn');

        historyBtn.disabled = (doctorSelect.value === "");
        fetchSlots();
    }

    document.addEventListener("DOMContentLoaded", function() {
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

    function toggleHistoryButton() {
        const doctorSelect = document.getElementById('doctorSelect');
        const historyBtn = document.getElementById('viewHistoryBtn');
        historyBtn.disabled = (doctorSelect.value === "");
    }

    function fetchAppointmentHistory() {
        const doctorID = document.getElementById('doctorSelect').value;
        const historyDisplay = document.getElementById('historyDisplay');
        const historyList = document.getElementById('historyList');

        historyDisplay.style.display = 'block';
        historyList.innerHTML = '<li class="list-group-item text-muted">Scanning billHistory.txt...</li>';

        fetch('/history?doctorID=' + doctorID)
            .then(response => response.json())
            .then(data => {
                historyList.innerHTML = "";
                if (data.length === 0) {
                    historyList.innerHTML = '<li class="list-group-item text-center">No previous history found.</li>';
                } else {
                    data.forEach(line => {
                        const parts = line.split('|');
                        const li = document.createElement('li');
                        li.className = 'list-group-item px-0';

                        // Convert the raw timestamp (parts[5]) into a readable date using JS
                        const rawDate = parts[5];
                        const formattedDate = new Date(rawDate).toLocaleDateString();

                        li.innerHTML = `
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="badge bg-secondary me-1">` + parts[3] + `</span>
                                    <small class="text-muted">` + formattedDate + `</small>
                                </div>
                                <span class="fw-bold text-success">LKR ` + parseFloat(parts[4]).toFixed(2) + `</span>
                            </div>
                        `;
                        historyList.appendChild(li);
                    });
                }
            })
            .catch(err => {
                historyList.innerHTML = '<li class="list-group-item text-danger">Error loading history.</li>';
            });
    }

    function updateDoctorList() {
        const specSelect = document.getElementById("specializationSelect");
        const doctorSelect = document.getElementById("doctorSelect");
        const timeSelect = document.getElementById("timeSlotSelect");
        const historyBtn = document.getElementById('viewHistoryBtn'); // Added this

        // Reset everything to a clean state
        timeSelect.innerHTML = '<option value="" selected disabled>Choose a date & doctor first...</option>';
        if (historyBtn) historyBtn.disabled = true; // Disable history until a new doctor is picked

        if (!specSelect || !doctorSelect) return;
        let spec = specSelect.value;

        if (spec === "Select Specialization" || spec === "All Specializations") {
            spec = "";
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
                    option.value = doc.userID;
                    option.textContent = "Dr. " + (doc.firstName || "") + " " + (doc.lastName || "");
                    doctorSelect.appendChild(option);
                });

                // Trigger a slot refresh check (optional, but good for UX)
                fetchSlots();
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

       // DEBUGGING: Confirm these show in your F12 console
       console.log("Doctor ID detected:", doctorId);
       console.log("Original Date from UI:", rawDate);

       // SAFETY GUARD: Prevent the call if data is missing
       if (!doctorId || !rawDate) {
           console.warn("Fetch blocked: Doctor or Date is missing.");
           return;
       }

       const queryString = params.toString();
       const finalUrl = "getAvailableSlots?" + queryString;

       // DEBUGGING: This MUST show the full string now
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