--King Crimson
function c101600116.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c101600116.spco)
	e1:SetOperation(c101600116.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--cannot special summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	--cannot attack
	local ae1=Effect.CreateEffect(c)
	ae1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ae1:SetCode(EVENT_SUMMON_SUCCESS)
	ae1:SetOperation(c101600116.atklimit)
	c:RegisterEffect(ae1)
	local ae2=ae1:Clone()
	ae2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(ae2)
	local ae3=ae1:Clone()
	ae3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(ae3)
	--
	local ne1=Effect.CreateEffect(c)
	ne1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	ne1:SetCode(EVENT_SPSUMMON_SUCCESS)
	ne1:SetTarget(c101600116.distg)
	ne1:SetOperation(c101600116.disop)
	c:RegisterEffect(ne1)
	--copy
	local ce1=Effect.CreateEffect(c)
	ce1:SetDescription(aux.Stringid(101600116,0))
	ce1:SetCategory(CATEGORY_REMOVE)
	ce1:SetType(EFFECT_TYPE_QUICK_O)
	ce1:SetCode(EVENT_FREE_CHAIN)
	ce1:SetCountLimit(1)
	ce1:SetRange(LOCATION_MZONE)
	ce1:SetTarget(c101600116.target)
	ce1:SetOperation(c101600116.operation)
	c:RegisterEffect(ce1)
	--Special Summon
	local se1=Effect.CreateEffect(c)
	se1:SetDescription(aux.Stringid(101600116,1))
	se1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	se1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	se1:SetCode(EVENT_LEAVE_FIELD)
	se1:SetCountLimit(1,101600116)
	se1:SetCost(c101600116.specost)
	se1:SetTarget(c101600116.spetg)
	se1:SetOperation(c101600116.speop)
	c:RegisterEffect(se1)
end
function c101600116.str(c)
	if not (c:GetLevel()==8 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0xa3)
end
function c101600116.arc(c)
	if not (c:GetLevel()==8 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0x45)
end
function c101600116.bw(c)
	if not (c:GetLevel()==8 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsCode(9012916,101600112)
end
function c101600116.af(c)
	if not (c:GetLevel()==7 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsCode(25862681,101600113)
end
function c101600116.pwr1(c)
	if not (c:GetLevel()==7 and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0xc2) or c:IsCode(101600114,25165047)
end
function c101600116.pwr2(c)
	if not (c:GetLevel()==8 and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0xc2) or c:IsCode(101600114,25165047)
end
function c101600116.pwr3(c)
	if not (c:GetLevel()==8 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0xc2) or c:IsCode(101600114,25165047)
end
function c101600116.pwr4(c)
	if not (c:GetLevel()==7 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsSetCard(0xc2) or c:IsCode(101600114,25165047)
end
function c101600116.br(c)
	if not (c:GetLevel()==7 and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_SYNCHRO)) then return end
	return c:IsCode(73580471,101600115)
end
function c101600116.spco(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	local str=Duel.GetMatchingGroup(c101600116.str,tp,LOCATION_EXTRA,0,nil)
	local arc=Duel.GetMatchingGroup(c101600116.arc,tp,LOCATION_EXTRA,0,nil)
	local bw=Duel.GetMatchingGroup(c101600116.bw,tp,LOCATION_EXTRA,0,nil)
	local af=Duel.GetMatchingGroup(c101600116.af,tp,LOCATION_EXTRA,0,nil)
	local pwr1=Duel.GetMatchingGroup(c101600116.pwr1,tp,LOCATION_EXTRA,0,nil)
	local pwr2=Duel.GetMatchingGroup(c101600116.pwr2,tp,LOCATION_EXTRA,0,nil)
	local pwr3=Duel.GetMatchingGroup(c101600116.pwr3,tp,LOCATION_EXTRA,0,nil)
	local pwr4=Duel.GetMatchingGroup(c101600116.pwr4,tp,LOCATION_EXTRA,0,nil)
	local pwr=Group.CreateGroup()
	pwr:Merge(pwr1)
	pwr:Merge(pwr2)
	pwr:Merge(pwr3)
	pwr:Merge(pwr4)
	local br=Duel.GetMatchingGroup(c101600116.br,tp,LOCATION_EXTRA,0,nil)
	return str:GetCount()>0 and arc:GetCount()>0 and bw:GetCount()>0 and af:GetCount()>0 and pwr:GetCount()>0 and br:GetCount()>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function c101600116.spop(e,tp,eg,ep,ev,re,r,rp)
	local str=Duel.GetMatchingGroup(c101600116.str,tp,LOCATION_EXTRA,0,nil)
	local arc=Duel.GetMatchingGroup(c101600116.arc,tp,LOCATION_EXTRA,0,nil)
	local bw=Duel.GetMatchingGroup(c101600116.bw,tp,LOCATION_EXTRA,0,nil)
	local af=Duel.GetMatchingGroup(c101600116.af,tp,LOCATION_EXTRA,0,nil)
	local pwr1=Duel.GetMatchingGroup(c101600116.pwr1,tp,LOCATION_EXTRA,0,nil)
	local pwr2=Duel.GetMatchingGroup(c101600116.pwr2,tp,LOCATION_EXTRA,0,nil)
	local pwr3=Duel.GetMatchingGroup(c101600116.pwr3,tp,LOCATION_EXTRA,0,nil)
	local pwr4=Duel.GetMatchingGroup(c101600116.pwr4,tp,LOCATION_EXTRA,0,nil)
	local pwr=Group.CreateGroup()
	pwr:Merge(pwr1)
	pwr:Merge(pwr2)
	pwr:Merge(pwr3)
	pwr:Merge(pwr4)
	local br=Duel.GetMatchingGroup(c101600116.br,tp,LOCATION_EXTRA,0,nil)
	local g=Group.CreateGroup()
	if str:GetCount()==1 then
		g:AddCard(str:GetFirst())
	else
		local add=str:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	if arc:GetCount()==1 then
		g:AddCard(arc:GetFirst())
	else
		local add=arc:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	if bw:GetCount()==1 then
		g:AddCard(bw:GetFirst())
	else
		local add=bw:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	if af:GetCount()==1 then
		g:AddCard(af:GetFirst())
	else
		local add=af:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	if br:GetCount()==1 then
		g:AddCard(br:GetFirst())
	else
		local add=br:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	if pwr:GetCount()==1 then
		g:AddCard(pwr:GetFirst())
	else
		local add=pwr:Select(tp,1,1,nil):GetFirst()
		g:AddCard(add)
	end
	local tc=g:GetFirst()
	for i=1,6 do
		Duel.ConfirmCards(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		tc=g:GetNext()
	end
end
function c101600116.atklimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function c101600116.disfilter(c)
	return not (c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON))
end
function c101600116.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetSummonType()&1==1 end
end
function c101600116.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c101600116.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
function c101600116.cpfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGraveAsCost() and (c:GetLevel()==7 or c:GetLevel()==8)
end
function c101600116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(c101600116.cpfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,c101600116.cpfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c101600116.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCode()
		local reset_flag=RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END
		c:CopyEffect(code,reset_flag,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(reset_flag,2)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
	end
end
function c101600116.specost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c101600116.spefilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c101600116.spefilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c101600116.spefilter(c)
	return c:IsAbleToRemoveAsCost() and (c:GetLevel()==7 or c:GetLevel()==8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function c101600116.spetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c101600116.speop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
end
