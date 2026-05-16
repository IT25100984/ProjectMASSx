package com.projectmass.model;

import java.time.LocalDateTime;

public interface UserInteraction {
    // Interfaces can only have constants, so we use methods for dynamic values
    String getInteractionType();
    LocalDateTime getTimestamp();

    // Default method to provide baseline Polymorphism
    default String getDisplaySummary() {
        return "System interaction [" + getInteractionType() + "] logged at " + getTimestamp();
    }
}