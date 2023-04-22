# Possible numbers:
#
# ! 0
# ! A
# ! ABC
# ! -A
# ! -ABC
#   0,abc
#   0,0...0abc
#   A,abc
#   A,0...0abc
#   ABC,abc
#   ABC,0...0abc
#   -0,abc
#   -0,0...0abc
#   -A,abc
#   -A,0...0abc
#   -ABC,abc
#   -ABC,0...0abc
# ! AE-XY
#   A,abcE-XY
#   A,0...0abcE-XY
# ! -AE-XY
#   -A,abcE-XY
#   -A,0...0abcE-XY
#
#   ** angry screeching **

# usage:
# 1. convert file to utf-8
# 2. run script and specify the target file
# 3. output will be written to output_<filename>


target = input("target file: ")

with open(target, "r", encoding="utf-8") as f_in, open("out_" + target, "w", encoding="utf-8") as f_out:
    for l_num, line in enumerate(f_in):
        line = line.replace("E", "e")
        parts = line.split(",")
        if len(parts) > 4:
            results = ["", "", ""]

            # if there are exactly 7 parts, then all numbers contain a comma
            if len(parts) == 7:
                results = [parts[2*i] + "." + parts[2*i + 1] for i in range(3)]
            # if not, then at least one number is either an integer or scientific notation with integer part
            else:
                cval = 0
                i = 0
                # each value contains an integer part and sometimes a decimal fraction part
                # the first value is always an integer part
                results[cval] = parts[0]
                i = 1

                # a decimal fraction is always followed by an integer, but an integer may be followed
                # by either a decimal part or another integer
                while i < len(parts) - 1:  # parts[-1] is always a newline
                    p = parts[i]

                    # start with the assumption that the number is a decimal fraction part
                    was_frac = True

                    # a sci-not final part is never followed by a decimal fraction
                    if "E" in parts[i - 1]:
                        was_frac = False
                    elif p[0] == "-":  # a decimal fraction never starts with a "-"
                        was_frac = False
                    elif "E" in p:     # we assume that only the first number can be an 'exact' sci-not
                        pass
                    elif len(p) >= 2 and p[0:2] == "00":  # only a fraction can start with two zeros
                        pass
                    elif p[-1] == "0": # a fraction never ends with zero (assuming we don't get to E+10 or E-10)
                        was_frac = False
                    elif len(p) > 2:   # an integer part is never 'big'
                        pass

                    if was_frac:
                        results[cval] += "." + p
                        i += 1
                    
                    # we have now added a number
                    cval += 1

                    #print("cval:", cval, "i:", i)
                    # if this was the last part, then we are done
                    if i == len(parts) - 1:
                        continue
                    
                    if cval >= 3:
                        print("FAILED to parse:", line)
                        print("   on line", l_num)
                        print("   cval overflowed at:", results)
                        exit()
                    
                    results[cval] = parts[i]
                    i += 1
            f_out.write(",".join(results) + "\n")
            if l_num % 100000 == 0:
                print("Progress:", l_num)
        else:
            f_out.write(line)

    
