export function escape(string) {
    if (string !== undefined && string != null) {
        return String(string).replace(/[&<>'"\\/]/g, function (c) {
            return '&#' + c.codePointAt(0) + ';';
        });
    } else {
        return '';
    }
}