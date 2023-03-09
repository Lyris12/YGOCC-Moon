--created by LeonDuvall, coded by Lyris
--Exodice Bob
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetTarget(aux.SearchTarget(s.filter))
	e1:SetOperation(aux.SearchOperation(s.filter))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0xd18) and c:IsType(TYPE_MONSTER)
end
function s.repfilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
		and c:IsOnField() and c:GetDestination()&(LOCATION_HAND+LOCATION_DECK)>0
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and eg:FilterCount(s.repfilter,nil,tp)==1 end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.Damage(1-tp,100,REASON_EFFECT)
end
function s.val(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
