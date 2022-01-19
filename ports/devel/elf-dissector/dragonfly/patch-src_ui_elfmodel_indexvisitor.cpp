--- src/ui/elfmodel/indexvisitor.cpp.orig	2021-07-21 10:44:26 UTC
+++ src/ui/elfmodel/indexvisitor.cpp
@@ -15,6 +15,8 @@
     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
+#include "elfdefinitions.h" // must come first before <elf.h>
+#define _ELF_H_
 #include "indexvisitor.h"
 
 #include <elf/elffile.h>
