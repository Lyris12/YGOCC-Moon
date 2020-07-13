--created & coded by Lyris
--フェイツ・アセンション
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=aux.AddRitualProcEqual2(c,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
end
