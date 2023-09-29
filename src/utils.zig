pub fn containsNonNullValues(array: anytype) bool {
    for (array) |value| {
        if (value != null) {
            return true;
        }
    }

    return false;
}
