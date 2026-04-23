<%-- 1. This line is required for JSTL to work --%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<nav class="navbar navbar-dark bg-primary shadow-sm px-4 mb-4">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="index.jsp">ProjectMASS</a>

        <div class="d-flex align-items-center">
            <c:choose>
                <%-- 2. Check if user is logged in --%>
                <c:when test="${not empty sessionScope.user}">
                    <span class="navbar-text text-white me-3">
                        Welcome, <strong>${user.firstName}</strong>
                        <span class="badge bg-light text-primary ms-1">${user.role}</span>
                    </span>
                    <a href="logout" class="btn btn-sm btn-light text-primary fw-bold">Logout</a>
                </c:when>

                <%-- 3. If not logged in, show login button --%>
                <c:otherwise>
                    <a href="login.jsp" class="btn btn-sm btn-outline-light">Login</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>