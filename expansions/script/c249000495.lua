--Chroma-Distortion Synchro Distorter
function c249000495.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(0xFF)
	e1:SetCondition(c249000495.spcon)
	e1:SetTarget(c249000495.sptg)
	e1:SetOperation(c249000495.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,249000495)
	e2:SetCost(c249000495.cost)
	e2:SetOperation(c249000495.op)
	c:RegisterEffect(e2)
end
function c249000495.spcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return rp==tp and de and dp==1-tp and e:GetHandler()==re:GetHandler() and e:GetHandler():GetReasonEffect()==de
end
function c249000495.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c249000495.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000495.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000495.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000495.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c249000495.spcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return rp==tp and de and dp==1-tp and e:GetHandler()==re:GetHandler() and e:GetHandler():GetReasonEffect()==de
end
function c249000495.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEU) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c249000495.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000495.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000495.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000495.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c249000495.costfilter(c)
	return c:IsSetCard(0x1C4) and c:IsAbleToRemoveAsCost()
end
function c249000495.costfilter2(c)
	return c:IsSetCard(0x1C4) and not c:IsPublic()
end
function c249000495.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and (Duel.IsExistingMatchingCard(c249000495.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000495.costfilter2,tp,LOCATION_HAND,0,1,c)) end
	local option
	if Duel.IsExistingMatchingCard(c249000495.costfilter2,tp,LOCATION_HAND,0,1,c)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000495.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000495.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000495.costfilter2,tp,LOCATION_HAND,0,1,c) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000495.costfilter2,tp,LOCATION_HAND,0,1,1,c)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000495.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c249000495.edfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()<=10 and c:GetLevel()%2==0
end
function c249000495.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c249000495.edfilter,tp,LOCATION_EXTRA,0,nil,tp)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1102)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetValue(SUMMON_TYPE_SYNCHRO)
		e1:SetCondition(c249000495.syncon)
		e1:SetOperation(c249000495.synop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)	
		tc=g:GetNext()
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c249000495.edop)
	Duel.RegisterEffect(e2,tp)
end
function c249000495.edop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(c249000495.edfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1102)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetValue(SUMMON_TYPE_SYNCHRO)
		e1:SetCondition(c249000495.syncon)
		e1:SetOperation(c249000495.synop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)	
		tc=g:GetNext()
	end
end
function c249000495.mfilter(c,lv)
	return c:GetLevel()==lv and c:IsAbleToRemove()
end
function c249000495.syncon(e,c,og)
	if c==nil then return true end
	if c:IsFaceup() then return false end
	local tp=c:GetControler()
	local lv=c:GetLevel()
	local mg=Duel.GetMatchingGroup(c249000495.mfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,lv/2)
	if mg:GetCount() < 2 then return false end
	return Duel.GetLocationCountFromEx(tp)>0
end
function c249000495.synop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	local mg=Duel.GetMatchingGroup(c249000495.mfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,lv/2)
	local g1=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local g1=mg:Select(tp,2,2,nil)
	Duel.Remove(g1,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
	c:SetMaterial(g1)
end