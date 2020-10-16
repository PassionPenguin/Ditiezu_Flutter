void main() {
  print(RegExp(",\ '(.*)\'").firstMatch('''<root>
	<![CDATA[<script type="text/javascript" reload="1">if(typeof succeedhandle_rate=='function') {succeedhandle_rate('http://www.ditiezu.com/./', '¸ÐÐ»ÄúµÄ²ÎÓë£¬ÏÖÔÚ½«×ªÈëÆÀ·ÖÇ°Ò³Ãæ', {});}</script>]]>
</root>''').group(1));
}
