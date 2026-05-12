<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prescriptions | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow border-0">
                <div class="card-header bg-primary text-white p-3">
                    <h4 class="mb-0"><i class="bi bi-capsule-pill me-2"></i>Order Prescription</h4>
                </div>
                <div class="card-body p-4">

                    <%-- Medicine Selection Area --%>
                    <div class="mb-4">
                        <label class="form-label fw-bold">Select Medicine</label>
                        <div class="input-group">
                            <select id="medSelect" class="form-select">
                                <option value="" disabled selected>Choose medicine...</option>
                                <option value="Panadol|50.00">Panadol (LKR 50.00)</option>
                                <option value="Amoxicillin|450.00">Amoxicillin (LKR 450.00)</option>
                                <option value="Metformin|120.00">Metformin (LKR 120.00)</option>
                                <option value="Salbutamol|300.00">Salbutamol (LKR 300.00)</option>
                            </select>
                            <input type="number" id="medQty" class="form-control" placeholder="Qty" min="1" value="1" style="max-width: 100px;">
                            <button type="button" class="btn btn-primary" onclick="addItem()">
                                <i class="bi bi-plus-lg"></i> Add
                            </button>
                        </div>
                    </div>

                    <%-- Cart Table --%>
                    <div class="table-responsive">
                        <table class="table table-hover border">
                            <thead class="table-light">
                            <tr>
                                <th>Medicine</th>
                                <th class="text-center">Qty</th>
                                <th class="text-end">Price (LKR)</th>
                                <th class="text-center">Action</th>
                            </tr>
                            </thead>
                            <tbody id="orderList">
                            <%-- JS will inject items here --%>
                            <tr>
                                <td colspan="4" class="text-center text-muted py-4">Your prescription list is empty.</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                    <%-- Total Display --%>
                    <div class="d-flex justify-content-between align-items-center mt-3 p-3 bg-light rounded border">
                        <span class="fw-bold text-uppercase small text-muted">Estimated Total:</span>
                        <span id="grandTotal" class="fs-4 fw-bold text-success">LKR 0.00</span>
                    </div>

                    <%-- Main Form Submission --%>
                    <form id="prescriptionForm" action="submitPrescription" method="POST">
                        <%-- The Hidden Input Trick --%>
                        <input type="hidden" name="cartData" id="cartData">

                        <div class="d-grid gap-2 mt-4">
                            <button type="button" id="submitBtn" class="btn btn-success btn-lg" onclick="openConfirmModal()" disabled>
                                <i class="bi bi-check2-circle me-1"></i> Submit Prescription
                            </button>
                            <a href="patientDashboard" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Confirmation Modal --%>
<div class="modal fade" id="confirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title">Confirm Prescription Order</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 text-center">
                <i class="bi bi-question-circle text-success mb-3" style="font-size: 3rem;"></i>
                <p class="mb-0">Are you sure you want to submit this prescription? Once submitted, the pharmacist will begin processing your order.</p>
            </div>
            <div class="modal-footer bg-light border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Wait, I need to check</button>
                <button type="button" class="btn btn-success px-4" onclick="finalSubmit()">Yes, Submit</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let cart = [];

    function addItem() {
        const medSelect = document.getElementById('medSelect');
        const medData = medSelect.value.split('|');
        const qty = parseInt(document.getElementById('medQty').value);

        if (!medData[0] || qty < 1) {
            alert("Please select a medicine and valid quantity.");
            return;
        }

        const item = {
            name: medData[0],
            price: parseFloat(medData[1]),
            qty: qty,
            total: parseFloat(medData[1]) * qty
        };

        cart.push(item);

        // UI Clean up after adding
        medSelect.selectedIndex = 0;
        document.getElementById('medQty').value = 1;

        renderTable();
    }

    function renderTable() {
        const tbody = document.getElementById('orderList');
        const submitBtn = document.getElementById('submitBtn');
        let total = 0;

        if (cart.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-4">Your prescription list is empty.</td></tr>';
            submitBtn.disabled = true;
            document.getElementById('grandTotal').innerText = "LKR 0.00";
            return;
        }

        tbody.innerHTML = '';
        submitBtn.disabled = false;

        cart.forEach((item, index) => {
            total += item.total;
            tbody.innerHTML += `
            <tr>
                <td class="fw-bold">\${item.name}</td>
                <td class="text-center">\${item.qty}</td>
                <td class="text-end">\${item.total.toFixed(2)}</td>
                <td class="text-center">
                    <button class="btn btn-sm btn-outline-danger" onclick="removeItem(\${index})">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>`;
        });
        document.getElementById('grandTotal').innerText = "LKR " + total.toFixed(2);
    }

    function removeItem(index) {
        cart.splice(index, 1);
        renderTable();
    }

    function openConfirmModal() {
        const modal = new bootstrap.Modal(document.getElementById('confirmModal'));
        modal.show();
    }

    function finalSubmit() {
        // 1. Generate the string
        const cartString = cart.map(item => `\${item.name},\${item.qty},\${item.price}`).join(';');
        // 2. PRINT to console (Press F12 in your browser to see this)
        console.log("--- PRE-SUBMISSION DATA CHECK ---");
        console.log("Raw String: " + cartString);
        console.table(cart); // This prints the cart in a nice table format in the console

        if (cart.length === 0) {
            alert("Cannot submit an empty cart.");
            return;
        }

        document.getElementById('cartData').value = cartString;
        document.getElementById('prescriptionForm').submit();
    }
</script>
</body>
</html>