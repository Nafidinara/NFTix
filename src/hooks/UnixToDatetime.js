/**
 * Converts a UNIX timestamp to a formatted date string.
 * @param {number} unixTimestamp - The UNIX timestamp to convert.
 * @returns {string} - Formatted date string, e.g., "Tuesday, January 7, 2025 3:38:12 PM".
 */
export function unixToDatetime(unixTimestamp) {
    const date = new Date(unixTimestamp * 1000); // Convert to milliseconds
    const options = {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: 'numeric',
        second: 'numeric',
        hour12: true,
    };

    return date.toLocaleString('en-US', options);
}