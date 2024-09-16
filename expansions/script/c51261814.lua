--created by Zarc, coded by Lyris
--Elflair - Fairy's Aroma
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetOperation(s.act)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x355))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0x355) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),1109) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x355)
end
function s.val(e,c)
	return 100*Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end
