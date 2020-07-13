--created & coded by Lyris
--フェイツ儀式術
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=aux.AddRitualProcGreater2(c,aux.FilterBoolFunction(Card.IsSetCard,0xf7a),LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,id)
end
