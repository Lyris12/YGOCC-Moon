--High-Cost-Summoner Master
function c249000121.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249000121.spcost)
	e1:SetTarget(c249000121.sptg)
	e1:SetOperation(c249000121.spop)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--immune spell/trap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c249000121.efilter)
	c:RegisterEffect(e2)
end
function c249000121.costfilter(c)
	return c:IsSetCard(0x15D) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and not c:IsCode(249000121)
end
function c249000121.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	local g=Duel.SelectMatchingCard(tp,c249000121.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000121.filter(c)
	return c:IsLevelAbove(7)
end
function c249000121.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(c249000121.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
c249000121.used_table_size=1
c249000121.used_table={
-1,
}
function c249000121.nottablematch(id)
	for i=1,c249000121.used_table_size do
		if c249000121.used_table[i]==id then return false end
	end
	return true
end
function c249000121.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249000119.filter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	local ac=Duel.AnnounceCard(tp)
	local cc=Duel.CreateToken(tp,ac)
	while not (cc:GetOriginalLevel()<=10 and cc:IsType(TYPE_MONSTER) and cc:IsCanBeSpecialSummoned(e,0,tp,true,true) and (not cc:IsSummonableCard())
		and c249000120.nottablematch(ac))
	do
		ac=Duel.AnnounceCard(tp)
		cc=Duel.CreateToken(tp,ac)
	end
	if Duel.SpecialSummon(cc,0,tp,tp,true,true,POS_FACEUP) then
		c249000121.used_table[c249000121.used_table_size+1]=ac
		c249000121.used_table_size=c249000121.used_table_size+1
		local e1=Effect.CreateEffect(cc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c249000121.efilter)
		cc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(cc)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCountLimit(1)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		e2:SetRange(LOCATION_MZONE)
		e2:SetOperation(c249000121.deckop)
		e2:SetLabel(0)
		cc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(cc)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(c249000121.efilter2)
		e3:SetReset(RESET_EVENT+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1+0x1fe0000)
		cc:RegisterEffect(e3,true)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e4:SetCode(EFFECT_CANNOT_SUMMON)
		e4:SetReset(RESET_PHASE+PHASE_END)
		e4:SetTargetRange(1,0)
		Duel.RegisterEffect(e4,tp)
		local e6=Effect.CreateEffect(cc)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetCode(EFFECT_IMMUNE_EFFECT)
		e6:SetRange(LOCATION_MZONE)
		e6:SetTargetRange(0,LOCATION_HAND)
		e6:SetReset(RESET_EVENT+0x1fe0000)
		e6:SetValue(c249000121.efilter2)
		cc:RegisterEffect(e6)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c249000121.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c249000121.efilter(e,re)
	return e:GetHandlerPlayer()==re:GetHandlerPlayer() and e:GetHandler()~=re:GetHandler()
end
function c249000121.efilter2(e,re)
	return e:GetHandler()==re:GetHandler()
end
function c249000121.damval(e,re,val,r,rp,rc)
	return val/2
end
function c249000121.deckop(e,tp,eg,ep,ev,re,r,rp)
	if tp~=Duel.GetTurnPlayer() then return end
	local c=e:GetHandler()
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	if ct==2 then
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c249000121.efilter2(e,te)
	return (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP)) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end