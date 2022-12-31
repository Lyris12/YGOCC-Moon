--Geneseed Cherrypiercer
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigEvoluteType(c)
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	aux.AddEvoluteProc(c,nil,7,aux.OR(cid.filter1,cid.filter2),2,99)  
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCountLimit(1,id)
	e0:SetTarget(cid.sumtg)
	e0:SetOperation(cid.sumop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	-- e1:SetHintTiming(0,0x1c0)
	e1:SetCountLimit(1)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetTarget(cid.target2)
	c:RegisterEffect(e3)

end
function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) 
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) 
end
function cid.succfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x57b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(cid.succfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cid.succfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
	and e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST)  end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function cid.filter(c,tp,ep,val)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetSummonPlayer()~=tp and not c:IsDisabled()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(cid.filter,1,nil,tp) end
	local g=eg:Filter(cid.filter,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetChainLimit(cid.limit(Duel.GetCurrentChain()))
end
function cid.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	   local c=e:GetHandler()
	local tc=eg:GetFirst()
	if chk==0 then return rp==1-tp and e:GetHandler():GetFlagEffect(id)==0  and tc:IsFaceup() and not tc:IsDisabled() end
	Duel.SetTargetCard(tc)
	 c:RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
	Duel.SetChainLimit(cid.limit(Duel.GetCurrentChain()))
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly(tc)
		tc=g:GetNext()
	end
end
function cid.limit(ch)
	return function(e,lp,tp)
		return not Duel.GetChainInfo(ch,CHAININFO_TARGET_CARDS):IsContains(e:GetHandler())
	end
end