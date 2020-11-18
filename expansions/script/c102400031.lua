--created & coded by Lyris
--S・VINEの第二女王クライッシャ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,8,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	c:EnableCounterPermit(0x1)
	local ae3=Effect.CreateEffect(c)
	ae3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ae3:SetCode(EVENT_REMOVE)
	ae3:SetRange(LOCATION_MZONE)
	ae3:SetOperation(s.acop)
	c:RegisterEffect(ae3)
	local ae0=Effect.CreateEffect(c)
	ae0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ae0:SetCode(EVENT_CUSTOM+id)
	ae0:SetOperation(s.eop)
	c:RegisterEffect(ae0)
	local ae1=Effect.CreateEffect(c)
	ae1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ae1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	ae1:SetCode(EFFECT_DESTROY_REPLACE)
	ae1:SetRange(LOCATION_MZONE)
	ae1:SetTarget(s.reptg)
	ae1:SetOperation(s.repop)
	c:RegisterEffect(ae1)
	local ae2=Effect.CreateEffect(c)
	ae2:SetType(EFFECT_TYPE_QUICK_O)
	ae2:SetRange(LOCATION_MZONE)
	ae2:SetCode(EVENT_FREE_CHAIN)
	ae2:SetCountLimit(1)
	ae2:SetCost(s.cost)
	ae2:SetOperation(s.op)
	c:RegisterEffect(ae2)
end
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x285b)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsExists(s.cfilter,1,c) then
		c:AddCounter(0x1,1)
		if c:GetCounter(0x1)==3 then
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,tp,0)
		end
	end
end
function s.eop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RemoveCounter(tp,0x1,3,REASON_EFFECT)
	c:AddEC(1)
	aux.AddECounter(1)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,1,REASON_COST) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveEC(tp,1,REASON_EFFECT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) end
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x285b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil):RandomSelect(tp,1)
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:GetFirst():IsLevelAbove(1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
	end
end
