String.prototype.firstNonSpace = function firstNonSpace() {
	for (var i = 0; i < this.length; i++) {
		if (this.charAt(i) != " ") {
			return i;
		}
	}
	return -1;
}
String.prototype.lastNonSpace = function lastNonSpace() {
	var lastNS = -1;
	for (var i = 0; i < this.length; i++) {
		if (this.charAt(i) != " ") {
			lastNS = i;
		}
	}
	return lastNS;
}
String.prototype.ltrim = function ltrim() {
	var from = this.firstNonSpace();
	return this.substring(from);
}
String.prototype.rtrim = function rtrim() {
	var to = this.lastNonSpace();
	return this.substring(0, to + 1);
}
String.prototype.trim = function trim() {
	return this.ltrim().rtrim();// TODO regular expressions could be used instead...
}