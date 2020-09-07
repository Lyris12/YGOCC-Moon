--Data Manipulator
function c249000969.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	--gain skill effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,2490009691)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c249000969.cost)
	e1:SetOperation(c249000969.operation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73341839,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,2490009692)
	e2:SetCost(c249000969.spcost)
	e2:SetTarget(c249000969.sptg)
	e2:SetOperation(c249000969.spop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c249000969.disop)
	c:RegisterEffect(e3)
end
function c249000969.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_CYBERSE) and c:IsCode(645087,11674673,11738489,14505685,24731391,25200959,36033786,42717221,46104361,52698008,56337500,60279710,63533837,86784733,89238128,91269402,249000967,249000968,269000024,249001108)
end
function c249000969.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000969.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249000969.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249000969.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local lp=Duel.GetLP(tp)
	c:RegisterFlagEffect(99988871,RESET_EVENT,0,1)
	local an=Duel.AnnounceNumber(tp,1000,2000,3000)
	local ac=Duel.AnnounceCardFilter(tp,0x1000001,OPCODE_ISTYPE,0x2889,OPCODE_ISSETCARD,OPCODE_AND)
	c:ResetFlagEffect(ac)
	Duel.ResetFlagEffect(tp,ac)
	local token=Duel.CreateToken(tp,ac)
	Duel.ConfirmCards(1-tp,Group.FromCards(token))
	for key,value in pairs(global_card_effect_table[token]) do
		if value:IsHasProperty(EFFECT_FLAG_SET_AVAILABLE) and value:GetCode()~=EFFECT_IMMUNE_EFFECT and value:GetCode()~=EFFECT_CANNOT_USE_AS_COST then
			local etemp=value:Clone()
			etemp:SetCost(aux.TRUE)
			etemp:SetProperty(0)
			etemp:SetCountLimit(1)
			etemp:SetRange(LOCATION_MZONE)
			etemp:SetReset(RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(etemp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
			e2:SetReset(RESET_PHASE+PHASE_END)
			e2:SetLabel(lp)
			e2:SetOperation(c249000969.lpop)
			Duel.RegisterEffect(e2,tp)
			local e3=e2:Clone()
			e3:SetCode(EVENT_PHASE_START+PHASE_END)
			Duel.RegisterEffect(e3,tp)
			Duel.SetLP(tp,an)
		end
	end
end
function c249000969.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,e:GetLabel())
end
function c249000969.costfilter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function c249000969.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c249000969.costfilter,2,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c249000969.costfilter,2,2,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c249000969.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c249000969.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function c249000969.filter(c)
	return c:IsRace(RACE_CYBERSE) and not c:IsPublic()
end
function c249000969.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	if e:GetHandler():GetFlagEffect(249000969)==0 and Duel.IsExistingMatchingCard(c249000969.filter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,1131) then
		local g=Duel.SelectMatchingCard(tp,c249000969.filter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		e:GetHandler():RegisterFlagEffect(249000969,RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,249000969)
		Duel.NegateEffect(ev)
	end
end