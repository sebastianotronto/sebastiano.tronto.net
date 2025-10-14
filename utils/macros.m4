m4_divert(-1)
m4_changequote(`{{{{{', `}}}}}')

This file contains some m4 macros that can be used to preprocess md files.

m4_divert(1)

m4_define({{{{{m4_navtable}}}}},
{{{{{<table style="width: 100%; table-layout: fixed;"> <thead> <tr>
	<th style="text-align: left"> <a href="$2">$1</a> </th>
	<th style="text-align: center"> <a href="$4">$3</a> </th>
	<th style="text-align: right"> <a href="$6">$5</a> </th>
</tr> </thead> </table>}}}}})

m4_define({{{{{m4_caption}}}}}, {{{{{<p align="center"><em>$1</em></p>}}}}})

m4_divert(0)m4_dnl
