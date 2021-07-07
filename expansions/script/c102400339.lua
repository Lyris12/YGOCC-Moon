--created & coded by Lyris
--リージル・リセット
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xaaa)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and rp~=tp and eg:IsExists(function(tc) local mg=tc:GetMaterial() return mg and mg:IsExists(s.mfilter,1,nil) end,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsSetCard,Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,1,nil,0xaaa) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,#eg+1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.NegateSummon(eg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(eg+Duel.SelectMatchingCard(tp,aux.AND(Card.IsSetCard,Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,1,1,nil,0xaaa),nil,2,REASON_EFFECT)
end
