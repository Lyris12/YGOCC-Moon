--Forbidden Pharaohnic Papyrus
local id,cod=23251033,c23251033
function cod.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(cod.condition)
	e1:SetTarget(cod.target)
	e1:SetOperation(cod.activate)
	c:RegisterEffect(e1)
end
function cod.cfilter(c,tp)
	return c:GetControler()==tp and ((c:IsLocation(LOCATION_SZONE) and c:IsFacedown()) or (c:IsCode(23251026) or c:IsCode(23251030) or c:IsCode(23251031) or c:IsCode(23251032) or c:IsCode(23251033)))
end
function cod.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(cod.cfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cod.sfilter(c)
	return (c:IsCode(23251030) or c:IsCode(23251031) or c:IsCode(23251032) or c:IsCode(23251033)) and c:IsSSetable()
end
function cod.afilter(c,tp)
	return c:IsCode(23251017) and c:GetActivateEffect():IsActivatable(tp)
end
function cod.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0xd3e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cod.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT) then
		local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
			and Duel.IsExistingMatchingCard(cod.sfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.GetFieldCard(tp,LOCATION_SZONE,5)==nil 
			and Duel.IsExistingMatchingCard(cod.afilter,tp,LOCATION_DECK,0,1,nil,tp)
		local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(cod.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		local op=0
		if b1 or b2 or b3 then
			local m={}
			local n={}
			local ct=1
			if b1 then m[ct]=aux.Stringid(id,0) n[ct]=1 ct=ct+1 end
			if b2 then m[ct]=aux.Stringid(id,1) n[ct]=2 ct=ct+1 end
			if b3 then m[ct]=aux.Stringid(id,2) n[ct]=3 ct=ct+1 end
			local sp=Duel.SelectOption(tp,table.unpack(m))
			op=n[sp+1]
		end
		e:SetLabel(op)
		if op==1 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.SelectMatchingCard(tp,cod.sfilter,tp,LOCATION_DECK,0,1,1,nil)
			local tc=g:GetFirst()
			if not tc then return end
			Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
		elseif op==2 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local tc=Duel.SelectMatchingCard(tp,cod.afilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
			if not tc then return end
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(tc,EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
		elseif op==3 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,cod.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()<=0 then return end
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
