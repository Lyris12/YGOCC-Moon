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
	e1:SetValue(function(e) return Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSetCard),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil,0xbb2)*100 end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsSetCard(0xbb2) and rc:IsSetCard(0xbb2) and rc~=c then
		Duel.SetChainLimit(s.chainlim)
	end
end
function s.chainlim(e,rp,tp)
	return not e:IsActiveType(TYPE_MONSTER) or e:GetHandler():IsDefensePos()
end
