--Primalgeddon Wave Divider
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DINOSAUR+RACE_DRAGON+RACE_SEASERPENT+RACE_WYRM),2)
end

                -- ,^.__.>--"~~'_.--~_)~^.  
              -- _L^~   ~    (~ _.-~ \. |\     
           -- ,-~    __    __,^"/\_A_/ /' \ 
         -- _/    ,-"  "~~" __) \  ~_,^   /\  
        -- //    /  ,-~\ x~"  \._"-~     ~ _Y  
        -- Y'   Y. (__.//     /  " , "\_r ' ]   
        -- J-.__l_>---r{      ~    \__/ \_ _/  
       -- (_ (   (~  (  ~"---   _.-~ `\ / \ !   
        -- (_"~--^----^--------"  _.-c Y  /Y'  
         -- l~---v----.,______.--"  /  !_/ |   
          -- \.__!.____./~-.      _/  /  \ !  
           -- `x._\_____\__,>---"~___Y\__/Y'  
               -- ~     ~(_~~(_)"~___)/ /\|   
                      -- (_~~   ~~___)  \_t  
--			             (_~~   ~~___)\_/ |  
--                       (_~~   ~~___)\_/ |   
                      -- { ~~   ~~   }/ \ l
													
-- ______            _     
-- | ___ \          | |    
-- | |_/ /_ __ _   _| |__  
-- | ___ \ '__| | | | '_ \ 
-- | |_/ / |  | |_| | | | |
-- \____/|_|   \__,_|_| |_|
                        