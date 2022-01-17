--created & coded by Lyris
--インライトメント・眼光炯々ゲイザー
local s,id,off=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvolveType(c)
	aux.AddEvolveProc(c,id-5,s.econ)
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,se,sp,st) return st&SUMMON_TYPE_EVOLVE==SUMMON_TYPE_EVOLVE end)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCondition(function() return c:IsSummonType(SUMMON_TYPE_EVOLVE) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetLabel(0)
	e3:SetCost(function() e3:SetLabel(1) return true end)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.econ(tp,ec,mc)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE)>1 and not Duel.IsExistingMatchingCard(aux.OR(Card.IsFacedown,aux.NOT(Card.IsAttribute)),tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_LIGHT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0x1da6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x1da6) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.sfilter(c,e,tp,rc)
	return aux.IsCodeListed(rc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ck=e:GetLabel()>0
	if chk==0 then
		e:SetLabel(0)
		return ck and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabelObject(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc),0,tp,tp,false,false,POS_FACEUP)
end
