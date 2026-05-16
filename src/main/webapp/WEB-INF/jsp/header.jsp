<%-- 1. This line is required for JSTL to work --%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<nav class="navbar navbar-dark bg-primary shadow-sm px-4 mb-4">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="/">ProjectMASS</a>

        <div class="d-flex align-items-center">

            <%-- PUBLIC REVIEWS MODAL TRIGGER BUTTON --%>
            <button type="button" class="btn btn-sm btn-outline-warning me-3 text-white border-warning" data-bs-toggle="modal" data-bs-target="#publicReviewsModal">
                <i class="bi bi-star-fill text-warning me-1"></i> Patient Reviews
            </button>

            <c:choose>
                <%-- CASE 1: User is Logged In --%>
                <c:when test="${not empty sessionScope.user}">

                    <%-- Setup Dashboard Routing Logic --%>
                    <c:choose>
                        <c:when test="${sessionScope.user.role == 'ADMIN'}">
                            <c:set var="dashboardLink" value="adminDashboard" />
                        </c:when>
                        <c:when test="${sessionScope.user.role == 'DOCTOR'}">
                            <%-- Use toLowerCase to ensure string matching works regardless of input --%>
                            <c:choose>
                                <c:when test="${fn:toLowerCase(sessionScope.user.specialization) == 'pharmacist'}">
                                    <c:set var="dashboardLink" value="pharmacistDashboard" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="dashboardLink" value="doctorDashboard" />
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <c:set var="dashboardLink" value="patientDashboard" />
                        </c:otherwise>
                    </c:choose>

                    <%-- Show BOTH Dashboard and Logout for logged-in users --%>
                    <a href="${dashboardLink}" class="nav-link text-white me-3">Dashboard</a>
                    <a href="logout" class="btn btn-sm btn-outline-light">Logout</a>
                </c:when>

                <%-- CASE 2: No User Session --%>
                <c:otherwise>
                    <a href="login" class="btn btn-sm btn-light text-primary">Login</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<%-- INJECT THE MODAL CONTENT DYNAMICALLY AT THE BOTTOM --%>
<%@ include file="feedback.jsp" %>