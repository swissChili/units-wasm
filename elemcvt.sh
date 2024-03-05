#! /bin/sh
# ******************************************************************************
#  elemcvt: convert NIST "Linear ASCII" table of elements to units(1) format
#  Usage: elemcvt [options] [<file>]
#  Author: Jeff Conrad
#  Date:  2024-01-06
# ******************************************************************************

# Adjust PATH to suit.
# For Windows w/MKS Toolkit, this assumes /bin is a symbolic link to
# $ROOTDIR/mksnt.

PATH=/bin

progname=${0##*[/\\]}
progname=${progname%.sh}
export TITLEBAR=$progname

umsg="Usage: $progname [options] [file]
Options:
  -d  Show elements for which no standard atomic mass is given and exit
  -v  Verbose"

show_no_std_atomic_mass=	# show elements for which no std atomic mass is given
verbose=
errors=
DUALCASE=1	# used in MKS Toolkit to make options case sensitive

while getopts :dv arg
do
    case $arg in
    d)
	show_no_std_atomic_mass=YES ;;
    v)
	verbose=YES ;;
    :)
	# OPTARG contains the option missing the argument
	print -ru2 -- "$progname: option $OPTARG requires an argument"
	errors=YES
	;;
    [?])
	# OPTARG contains the invalid option
	print -ru2 -- "$progname: unknown option $OPTARG"
	errors=YES
	;;
    esac
done
shift $((OPTIND - 1))
unset DUALCASE

if [ -n "$errors" ]
then
    print -ru2 -- "$umsg"
    exit 1
fi

awk '

function show_element_info(atomic_number, atomic_symbol, std_atomic_mass_str)
{
    printf("# %s: %s (%d)", names[atomic_number], atomic_symbol, atomic_number)
    if (std_atomic_mass_str)
	printf("  std atomic weight: %s", std_atomic_mass_str)
    print ""
}

# <name>_<atomic num>  <mass> # <mole fraction>
function show_isotope(name, num)
{
    printf("%-*s%*s%*.*f", max_isotope_len, sprintf("%s_%d", name, num),
	    sepwid, " ", isoprecis + 4, isoprecis, mass[num])
    if (composition[num])
	printf("   # %.*f", compprecis, composition[num])
    print ""
}

function show_element_name(name)
{
    printf("%-*s%*s", max_name_len, name, sepwid, " ")
}

# <mole fraction> <name>_<mass num>
function mole_fraction(atomic_number, names, mass_num,  mass_wid)
{
    if (composition[mass_num] == 1) {
	mass_wid = length(int(mass_number[n_isotopes]))
	# align with 1st digit of atomic mass
	printf("%*s%s_%d", sepwid + 2 - mass_wid, " ", names[atomic_number], mass_num)
    }
    else
	printf("%.*f %s_%d", compprecis, composition[mass_num],
		names[atomic_number], mass_num)
}

# add line continuation and '+' sign
function add_continuation()
{
    printf(" \\\n")
    printf("%-*s+ ", max_name_len + sepwid - 2, " ")
}

# <name>_<mass num> # most stable
function use_most_stable(atomic_number, mass,  mass_wid)
{
    mass_wid = length(int(mass_number[n_isotopes]))
    printf("%*s%-*s   # most stable", sepwid + 2 - mass_wid, " ",
	    isoprecis + 1 + mass_wid, sprintf("%s_%d", names[atomic_number], mass))
}

# <name>_<mass num> # standard atomic mass
function use_std_mass(atomic_number, mass,  mass_wid)
{
    mass_wid = length(int(mass_number[n_isotopes]))
    printf("%*s%-*s   # standard atomic mass", sepwid + 2 - mass_wid, " ",
	    isoprecis + 1 + mass_wid, sprintf("%s_%d", names[atomic_number], mass))
}

# show isotopes and the sum of mole fraction-mass products
function show_element_data(atomic_number, names)
{
    # isotopes and relative abundances
    for (ndx = 1; ndx <= n_isotopes; ndx++) {
	mass_num = mass_number[ndx]
	show_isotope(names[atomic_number], mass_num)
    }

    # show a value for atomic mass if one of these is available;
    # otherwise, show only isotope masses.
    if (total_composition > 0 || most_stable_mass || std_atomic_mass)
	show_element = 1
    else
	show_element = 0

    # atomic mass: sum of mole fraction-mass products
    # element name
    if (show_element)
	show_element_name(names[atomic_number])

    mass_num = mass_number[1]
    firstval = 0

    # first isotope
    if (composition[mass_num] > 0) {
	mole_fraction(atomic_number, names, mass_num)
	firstval = 1
    }
    if (n_isotopes > 1) {
	for (ndx = 2; ndx < n_isotopes; ndx++) {
	    mass_num = mass_number[ndx]
	    if (composition[mass_num] > 0) {
		if (firstval == 1)
		    add_continuation()
		mole_fraction(atomic_number, names, mass_num)
		firstval = 1
	    }
	}
	# last isotope
	mass_num = mass_number[n_isotopes]
	if (composition[mass_num] > 0) {
	    if (firstval == 1)
		add_continuation()
	    mole_fraction(atomic_number, names, mass_num)
	    print ""
	}
    }
    else
	print ""

    # options if mole fraction is not given for any isotope
    if (total_composition == 0) {
	if (most_stable_mass)
	    use_most_stable(atomic_number, most_stable_mass)
	else if (std_atomic_mass)
	    use_std_mass(atomic_number, std_atomic_mass)
    }

    if (! composition[mass_number[n_isotopes]])
	print ""
}

function output(atomic_number)
{
    sepwid = 5		# width of column separation
    compprecis = 8	# for mole fraction
    isoprecis = 10	# for isotope mass

    # NIST show H, D, and T
    if (atomic_number == 1)
	atomic_symbol = "H"

    show_element_info(atomic_number, atomic_symbol, std_atomic_mass_str)

    if (am_names[atomic_number])
	print "# IUPAC spelling"

    show_element_data(atomic_number, names)

    # show American spelling if different from IUPAC
    if (am_names[atomic_number]) {
	print "# American spelling"
	show_element_data(atomic_number, am_names)
    }
    if (show_element)
	print ""	# blank line between elements

    most_stable_mass = 0
    total_composition = 0
}

function gnu_notes()
{
    print "\
# This file is the elements database for use with GNU units, a units\n\
# conversion program by Adrian Mariano adrianm@gnu.org\n\
#\n\
# January 2024 Version 1.0\n\
#\n\
# Copyright (C) 2024\n\
# Free Software Foundation, Inc\n\
#\n\
# This program is free software; you can redistribute it and/or modify\n\
# it under the terms of the GNU General Public License as published by\n\
# the Free Software Foundation; either version 3 of the License, or\n\
# (at your option) any later version.\n\
#\n\
# This data is distributed in the hope that it will be useful,\n\
# but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
# GNU General Public License for more details.\n\
#\n\
# You should have received a copy of the GNU General Public License\n\
# along with this program; if not, write to the Free Software\n\
# Foundation, Inc., 51 Franklin Street, Fifth Floor,\n\
# Boston, MA  02110-1301  USA\n"
}

function nist_notes()
{
    print "# From https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-relative-atomic-masses\n"

    # notes from https://www.nist.gov/pml/atomic-weights-and-isotopic-compositions-column-descriptions
    print "\
#   For several elements, the standard atomic weight A_r is given as an\n\
#   atomic-weight interval with the symbol [a,b] to denote the set of\n\
#   atomic-weight values in normal materials; thus, [a <= A_r(E) <= b].\n\
#   The symbols a and b denote the lower and upper bounds of the\n\
#   interval [a,b], respectively.  The values in parentheses, following\n\
#   the last significant digit to which they are attributed, are\n\
#   uncertainties.\n\
#\n\
#   Brackets [ ] enclosing a single value indicate the mass number of\n\
#   the most stable isotope.  For radioactive elements with atomic\n\
#   numbers 95 or greater, the mass number of the most stable isotope is\n\
#   not specified, as the list of studied isotopes is still\n\
#   incomplete.\n"
}

function units_notes()
{
    print "\
# When composition mole fractions of isotopes are given, the atomic mass\n\
# of an element is given as the sum of the product(s) of mole\n\
# fraction(s) and the atomic masses of the relevant isotopes.  When composition\n\
# mole fractions are not given, the atomic mass is given as\n\
#\n\
#   * the mass of the most stable isotope, if available, or\n\
#   * the standard atomic mass of the element, if available.\n\
#\n\
# If neither the most stable isotope nore a standard atomic mass is\n\
# available, no atomic mass for the element is given; the user must\n\
# select the isotope most suitable for their purposes.\n\
#\n\
# If the standard atomic mass is a range, the value given is the\n\
# midpoint of that range, which may differ from the value determined\n\
# from the sum of the products of composition mole fraction and isotope\n\
# atomic mass.\n"
}

BEGIN {
    FS = " *= *"
    show_no_std_atomic_mass = "'"$show_no_std_atomic_mass"'"
    verbose = "'"$verbose"'"
    console = "/dev/console"

    # IUPAC spellings
    names[1] = "hydrogen"
    names[2] = "helium"
    names[3] = "lithium"
    names[4] = "beryllium"
    names[5] = "boron"
    names[6] = "carbon"
    names[7] = "nitrogen"
    names[8] = "oxygen"
    names[9] = "fluorine"
    names[10] = "neon"
    names[11] = "sodium"
    names[12] = "magnesium"
    names[13] = "aluminium"
    names[14] = "silicon"
    names[15] = "phosphorus"
    names[16] = "sulfur"
    names[17] = "chlorine"
    names[18] = "argon"
    names[19] = "potassium"
    names[20] = "calcium"
    names[21] = "scandium"
    names[22] = "titanium"
    names[23] = "vanadium"
    names[24] = "chromium"
    names[25] = "manganese"
    names[26] = "iron"
    names[27] = "cobalt"
    names[28] = "nickel"
    names[29] = "copper"
    names[30] = "zinc"
    names[31] = "gallium"
    names[32] = "germanium"
    names[33] = "arsenic"
    names[34] = "selenium"
    names[35] = "bromine"
    names[36] = "krypton"
    names[37] = "rubidium"
    names[38] = "strontium"
    names[39] = "yttrium"
    names[40] = "zirconium"
    names[41] = "niobium"
    names[42] = "molybdenum"
    names[43] = "technetium"
    names[44] = "ruthenium"
    names[45] = "rhodium"
    names[46] = "palladium"
    names[47] = "silver"
    names[48] = "cadmium"
    names[49] = "indium"
    names[50] = "tin"
    names[51] = "antimony"
    names[52] = "tellurium"
    names[53] = "iodine"
    names[54] = "xenon"
    names[55] = "caesium"
    names[56] = "barium"
    names[57] = "lanthanum"
    names[58] = "cerium"
    names[59] = "praseodymium"
    names[60] = "neodymium"
    names[61] = "promethium"
    names[62] = "samarium"
    names[63] = "europium"
    names[64] = "gadolinium"
    names[65] = "terbium"
    names[66] = "dysprosium"
    names[67] = "holmium"
    names[68] = "erbium"
    names[69] = "thulium"
    names[70] = "ytterbium"
    names[71] = "lutetium"
    names[72] = "hafnium"
    names[73] = "tantalum"
    names[74] = "tungsten"
    names[75] = "rhenium"
    names[76] = "osmium"
    names[77] = "iridium"
    names[78] = "platinum"
    names[79] = "gold"
    names[80] = "mercury"
    names[81] = "thallium"
    names[82] = "lead"
    names[83] = "bismuth"
    names[84] = "polonium"
    names[85] = "astatine"
    names[86] = "radon"
    names[87] = "francium"
    names[88] = "radium"
    names[89] = "actinium"
    names[90] = "thorium"
    names[91] = "protactinium"
    names[92] = "uranium"
    names[93] = "neptunium"
    names[94] = "plutonium"
    names[95] = "americium"
    names[96] = "curium"
    names[97] = "berkelium"
    names[98] = "californium"
    names[99] = "einsteinium"
    names[100] = "fermium"
    names[101] = "mendelevium"
    names[102] = "nobelium"
    names[103] = "lawrencium"
    names[104] = "rutherfordium"
    names[105] = "dubnium"
    names[106] = "seaborgium"
    names[107] = "bohrium"
    names[108] = "hassium"
    names[109] = "meitnerium"
    names[110] = "darmstadtium"
    names[111] = "roentgenium"
    names[112] = "copernicium"
    names[113] = "nihonium"
    names[114] = "flerovium"
    names[115] = "moscovium"
    names[116] = "livermorium"
    names[117] = "tennessine"
    names[118] = "oganesson"

    # American spellings
    am_names[13] = "aluminum"
    am_names[55] = "cesium"

    max_name_len = 0		# length of longest element name
    for (i = 1; i <= 118; i++) {
	len = length(names[i])
	if (len > max_name_len) {
	    max_name_len = len;
	    longestname = names[i]
	}
    }
    max_isotope_len = max_name_len + 4	# allow for "_xxx" suffix

    if (! show_no_std_atomic_mass) {
	gnu_notes()
	nist_notes()
	units_notes()
    }

    if (verbose)
	printf("Longest element name: %s (%d)\n\n", longestname, max_name_len)

    n_isotopes = 0
    mass_number[1] = 0
}

# begin file processing

# skip JavaScript and HTML before data
NR == 1, $0 ~ /<pre/ { next }
# skip HTML after data
$0 ~ /<\/pre>/ { exit }

# remove trailing space and unpaddable spaces
{ 
  gsub(/&nbsp;/, "")
  gsub(/ +$/, "")
}

$1 ~ /Atomic Number/ {
    last_atomic_number = atomic_number
    atomic_number = $2 + 0
    if (atomic_number != last_atomic_number && atomic_number > 1) {
	if (show_no_std_atomic_mass) {
	    if (! std_atomic_mass_str)
		print names[last_atomic_number]
	}
	else
	    output(last_atomic_number)
    }
}

$1 ~ /Atomic Symbol/ {
    atomic_symbol = $2
}

$1 ~ /Mass Number/ {
    if (atomic_number != last_atomic_number) {
	for (i = 1; i <= n_isotopes; i++)
	    delete mass_number[i]
	n_isotopes = 0
    }
    mass_number[++n_isotopes] = $2
}

$1 ~ /Relative Atomic Mass/ {
    atomic_mass = $2
    sub(/\([[:digit:]#]+\)/, "", atomic_mass)
    mass[mass_number[n_isotopes]] = atomic_mass
}

$1 ~ /Isotopic Composition/ {
    isotopic_composition = $2
    sub(/\([[:digit:]#]+\)/, "", isotopic_composition)
    composition[mass_number[n_isotopes]] = isotopic_composition
    total_composition += isotopic_composition
}

$1 ~ /Standard Atomic Weight/ {
    std_atomic_mass = std_atomic_mass_str = $2
    gsub(/\([^)]+\)/, "", std_atomic_mass)
    gsub(/[][]/, "", std_atomic_mass)
    if (std_atomic_mass ~ /,/) {
	split(std_atomic_mass, range, /,/)
	std_atomic_mass = (range[1] + range[2]) / 2
    }
    if (std_atomic_mass_str ~ /\[[[:digit:].]+\]/)
	most_stable_mass = std_atomic_mass
    last_atomic_number = atomic_number
}

END {
    if (show_no_std_atomic_mass) {
	if (! std_atomic_mass_str)
	    print names[last_atomic_number]
    }
    else
	output(last_atomic_number)
} ' $*
