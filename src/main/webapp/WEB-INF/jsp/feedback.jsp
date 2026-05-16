<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<div class="modal fade" id="publicReviewsModal" tabindex="-1" aria-labelledby="reviewsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-md">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header bg-dark text-white p-3">
                <h5 class="modal-title" id="reviewsModalLabel">
                    <i class="bi bi-chat-square-heart-fill me-2 text-warning"></i>What Our Patients Say
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body p-3" style="max-height: 400px; overflow-y: auto; background-color: #f8f9fa;">
                <c:choose>
                    <c:when test="${not empty publicReviews}">
                        <c:forEach var="rev" items="${publicReviews}">
                            <div class="bg-white p-3 mb-3 rounded shadow-sm border-start border-primary border-4">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="fw-bold text-dark small">
                                        <i class="bi bi-person text-primary"></i> ${rev.patientName}
                                    </span>
                                    <span class="text-muted small">To: Dr. ${rev.doctorName}</span>
                                </div>
                                <div class="mb-2">
                                    <span class="text-warning small">${rev.getStars()}</span>
                                </div>
                                <p class="mb-0 text-secondary font-monospace small italic">"${rev.comment}"</p>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <i class="bi bi-chat-left-text fs-2 d-block mb-2 text-secondary"></i>
                            No public reviews written to the file system yet.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="modal-footer bg-light justify-content-center py-2">
                <small class="text-muted">Logged-in patients can submit a new review via their dashboard.</small>
            </div>
        </div>
    </div>
</div>