--created by LeonDuvall
--Aerin, Magitate Divinitatum
local s,id,o=GetID()
function s.initial_effect(c)
	--If a Level 5 "Magitate" monster you control battles an opponent's monster, that opponent's monster has its effects negated during the battle phase only, also your opponent cannot activate cards or effects until the end of the Damage Step. Once per turn (Quick Effect): You can banish 1 "Concentrated Magitate" card from your GY; Special Summon 1 "Magitate" monster from your hand or GY, except "Aerin, Magitate Shade", and if you do, transform it to [REVERSE] side, then draw 1 card.
	aux.AddDoubleSidedProc(c,SIDE_REVERSE,131792008)
	aux.AddReverseSideProc(c)
end
