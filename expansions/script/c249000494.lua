--Chroma-Distortion Xyz Distorter
function c249000494.initial_effect(c)
if Auxiliary.AddXyzProcedure then
	if not c249000494_AddXyzProcedure then
		c249000494_AddXyzProcedure=Auxiliary.AddXyzProcedure
		Auxiliary.AddXyzProcedure = function (c,f,lv,ct,alterf,desc,maxct,op)
			local code=c:GetOriginalCode()
			local mt=_G["c" .. code]
			mt.xyz_minct=ct
			c249000494_AddXyzProcedure(c,f,lv,ct,alterf,desc,maxct,op)
		end
	end
end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,249000494)
	e1:SetCost(c249000494.cost)
	e1:SetOperation(c249000494.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(0xFF)
	e4:SetCondition(c249000494.spcon)
	e4:SetTarget(c249000494.sptg)
	e4:SetOperation(c249000494.spop)
	c:RegisterEffect(e4)
end
function c249000494.costfilter(c)
	return c:IsSetCard(0x1C4) and c:IsAbleToRemoveAsCost()
end
function c249000494.costfilter2(c,e)
	return c:IsSetCard(0x1C4) and not c:IsPublic() and c~=e:GetHandler()
end
function c249000494.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(c249000494.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	or Duel.IsExistingMatchingCard(c249000494.costfilter2,tp,LOCATION_HAND,0,1,nil,e)) end
	local option
	if Duel.IsExistingMatchingCard(c249000494.costfilter2,tp,LOCATION_HAND,0,1,nil,e)  then option=0 end
	if Duel.IsExistingMatchingCard(c249000494.costfilter,tp,LOCATION_GRAVE,0,1,nil) then option=1 end
	if Duel.IsExistingMatchingCard(c249000494.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(c249000494.costfilter2,tp,LOCATION_HAND,0,1,nil,e) then
		option=Duel.SelectOption(tp,526,1102)
	end
	if option==0 then
		g=Duel.SelectMatchingCard(tp,c249000494.costfilter2,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
	if option==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c249000494.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c249000494.edfilter(c,tp)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	return c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:GetRank() < 12 and mt.xyz_minct and not (c:IsRace(RACE_WINDBEAST) and c:GetRank()==10)
end
function c249000494.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c249000494.edfilter,tp,LOCATION_EXTRA,0,nil,tp)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1102)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetValue(SUMMON_TYPE_XYZ)
		e1:SetCondition(c249000494.xyzcon)
		e1:SetOperation(c249000494.xyzop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()	
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c249000494.edop)
	Duel.RegisterEffect(e2,tp)
end
function c249000494.edop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(c249000494.edfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetDescription(1102)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_EXTRA)
		e1:SetValue(SUMMON_TYPE_XYZ)
		e1:SetCondition(c249000494.xyzcon)
		e1:SetOperation(c249000494.xyzop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
function c249000494.mfilter(c,rk)
	return c:GetLevel() < rk and c:GetLevel() > 0 and c:IsAbleToRemove()
end
function c249000494.xyzcon(e,c,og)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local rk=c:GetRank()
	local mg=Duel.GetMatchingGroup(c249000494.mfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,rk)
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and mg:CheckWithSumEqual(Card.GetLevel,rk,mt.xyz_minct,mt.xyz_minct,c)
end
function c249000494.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local c=e:GetHandler()
	local rk=c:GetRank()
	local mg=Duel.GetMatchingGroup(c249000494.mfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,rk)
	local g1=Group.CreateGroup()
	local code=c:GetOriginalCode()
	local mt=_G["c" .. code]
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=mg:SelectWithSumEqual(tp,Card.GetLevel,rk,mt.xyz_minct,mt.xyz_minct,c)
    Duel.Remove(g1,POS_FACEUP,REASON_MATERIAL+REASON_XYZ)
    c:SetMaterial(g1)
    local g2=Group.CreateGroup()
    local tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
	if tc2 then
		Duel.Overlay(c,tc2)
	end
	tc2=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
	if tc2 then
		Duel.Overlay(c,tc2)
	end
end
function c249000494.spcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return rp==tp and de and dp==1-tp and e:GetHandler()==re:GetHandler() and e:GetHandler():GetReasonEffect()==de
end
function c249000494.filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c249000494.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000494.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249000494.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249000494.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end