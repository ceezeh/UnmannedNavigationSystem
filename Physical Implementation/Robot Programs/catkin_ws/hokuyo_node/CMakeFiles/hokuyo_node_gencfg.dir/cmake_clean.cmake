FILE(REMOVE_RECURSE
  "CMakeFiles/hokuyo_node_gencfg"
  "../devel/include/hokuyo_node/HokuyoConfig.h"
  "../devel/share/hokuyo_node/docs/HokuyoConfig.dox"
  "../devel/share/hokuyo_node/docs/HokuyoConfig-usage.dox"
  "../devel/lib/python2.7/dist-packages/hokuyo_node/cfg/HokuyoConfig.py"
  "../devel/share/hokuyo_node/docs/HokuyoConfig.wikidoc"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/hokuyo_node_gencfg.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
