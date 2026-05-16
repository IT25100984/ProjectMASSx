<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="adminFeedbackModal" tabindex="-1" aria-labelledby="adminFeedbackLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl"> <div class="modal-content border-0 shadow-lg">

    <div class="modal-header bg-dark text-white p-3">
      <h5 class="modal-title" id="adminFeedbackLabel">
        <i class="bi bi-shield-lock-fill me-2 text-warning"></i>System Feedback Management Portal
      </h5>
      <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>

    <div class="modal-body p-0" style="max-height: 550px; overflow-y: auto; background-color: #f8f9fa;">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-secondary sticky-top">
        <tr>
          <th class="ps-3">#</th>
          <th>Patient</th>
          <th>Doctor</th>
          <th>Rating</th>
          <th>Comment</th>
          <th>Date Processed</th>
          <th class="text-center pe-3">Actions</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
          <c:when test="${empty allFeedback}">
            <tr>
              <td colspan="7" class="text-center py-5 text-muted">
                <i class="bi bi-chat-left-x fs-2 d-block mb-2 text-secondary"></i>
                No patient feedback records currently stored in the system database.
              </td>
            </tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="fb" items="${allFeedback}">
              <tr>
                <td class="text-muted ps-3">#${fb.feedbackId}</td>
                <td class="fw-semibold text-dark">${fb.patientName}</td>
                <td>Dr. ${fb.doctorName}</td>
                <td>
                  <span class="text-warning fw-bold">${fb.getStars()}</span>
                  <span class="ms-1 text-muted small">(${fb.rating}/5)</span>
                </td>
                <td class="text-secondary small text-wrap" style="max-width: 320px;">
                  <c:choose>
                    <c:when test="${not empty fb.comment}">
                      <c:out value="${fb.comment}" />
                    </c:when>
                    <c:otherwise><em class="text-muted">No text comment provided</em></c:otherwise>
                  </c:choose>
                </td>
                <td><span class="badge bg-light text-dark border">${fb.createdAt}</span></td>
                <td class="text-center pe-3">
                  <form action="${pageContext.request.contextPath}/deleteFeedback" method="POST" class="d-inline"
                        onsubmit="return confirm('Are you sure you want to permanently delete this feedback record? This action cannot be undone.');">
                    <input type="hidden" name="feedbackId" value="${fb.feedbackId}" />
                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-2 px-2 py-1">
                      <i class="bi bi-trash3-fill"></i> Delete
                    </button>
                  </form>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>

    <div class="modal-footer bg-light py-2">
      <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close Monitor</button>
    </div>
  </div>
  </div>
</div>