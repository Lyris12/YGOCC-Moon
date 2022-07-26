--created & coded by Lyris
--剣主スクリンブロ
local s,id,o=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(function(e) return Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSetCard),e:GetHandlerPlayer(),LOCATION_MZONE,0,c,0xbb2)*100 end)
	c:RegisterEffect(e1)
end
