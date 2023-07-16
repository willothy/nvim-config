local Lines = require("willothy.lines")

local elements = {}

elements.planets = {}
elements.planets.earth = Lines:new([[
    .-:::'-':-.
  .''::::.:    '.
 /   :::::'     :\
;.    ':' `      :;
|       '..      ;|
; '      ::::.    ;
 \       '::::   /
  '.      :::  .'
    '-.___'_.-'
]])

elements.planets.earth_large = Lines:new([[
              _-o#&&*''''?d:>o-_
          _o/"`''  '',, dMF9MMMMMHo_
       .o&#'        `"MbHMMMMMMMMMMMHo.
     .o"" '         vodM*$&&HMMMMMMMMMM?.
    ,'              $M&ood,~'`(&##MMMMMMH\
   /               ,MMMMMMM#b?#bobMMMMHMMML
  &              ?MMMMMMMMMMMMMMMMM7MMM$R*Hk
 ?$.            :MMMMMMMMMMMMMMMMMMM/HMMM|`*L
|               |MMMMMMMMMMMMMMMMMMMMbMH'   T,
$H#:            `*MMMMMMMMMMMMMMMMMMMMb#}'  `?
]MMH#             ""*""""*#MMMMMMMMMMMMM'    -
MMMMMb_                   |MMMMMMMMMMMP'     :
HMMMMMMMHo                 `MMMMMMMMMT       .
?MMMMMMMMP                  9MMMMMMMM}       -
-?MMMMMMM                  |MMMMMMMMM?,d-    '
 :|MMMMMM-                 `MMMMMMMT .M|.   :
  .9MMM[                    &MMMMM*' `'    .
   :9MMk                    `MMM#"        -
     &M}                     `          .-
      `&.                             .
        `~,   .                     ./
            . _                  .-
              '`--._,dd###pp=""'
]])

elements.telescope = {}
elements.telescope.dog = Lines:new([[
       .-.              
      {}``; |==|████████|  
      / ('        /|\       
  (  /  \        / | \    
   \( )  ]      /  |  \    
]])

elements.telescope.person = Lines:new([[
            // 
           //
  ___o |==// 
 /\  \/  //|\ 
/ /        | \ 
` `        '  '
]])

elements.misc = {}

elements.misc.land_border = Lines:new([[
█████████████████████████▇▆▅▄▂▁
]])

return elements
