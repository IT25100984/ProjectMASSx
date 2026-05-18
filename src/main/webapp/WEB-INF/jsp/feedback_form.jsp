<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Submit Patient Review - ProjectMASS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<jsp:include page="header.jsp" />

<div class="container my-5">
  <div class="row justify-content-center">
    <div class="col-md-6">
      <div class="card shadow border-0 rounded-3">
        <div class="card-header bg-primary text-white text-center py-3">
          <h4 class="mb-0"><i class="bi bi-star-fill me-2"></i>Submit Your Feedback</h4>
        </div>
        <div class="card-body p-4">

          <form action="submitFeedback" method="POST">

            <input type="hidden" name="doctorId" value="${selectedDoctorId}">
            <input type="hidden" name="appointmentId" value="${selectedAppointmentId}">

            <div class="mb-3">
              <label class="form-label fw-bold text-secondary">Rating</label>
              <select name="rating" class="form-select text-warning" required>
                <option value="5">★★★★★ (Excellent)</option>
                <option value="4">★★★★☆ (Very Good)</option>
                <option value="3">★★★☆☆ (Good)</option>
                <option value="2">★★☆☆☆ (Fair)</option>
                <option value="1">★☆☆☆☆ (Poor)</option>
              </select>
            </div>

            <div class="mb-3">
              <label class="form-label fw-bold text-secondary">Your Comments</label>
              <textarea name="comment" class="form-control" rows="4" placeholder="How was your experience?" required></textarea>
            </div>

            <div class="d-grid gap-2 mt-4">
              <button type="submit" class="btn btn-primary py-2 fw-bold">Submit Review</button>
              <a href="patientDashboard" class="btn btn-outline-secondary py-2">Back to Dashboard</a>
            </div>
          </form>

        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>