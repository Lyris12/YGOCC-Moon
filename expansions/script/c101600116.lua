--King Crimson
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.spco)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	--cannot special summon
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(cid.atkcon)
	c:RegisterEffect(e2)
	--negate
	local ne1=Effect.CreateEffect(c)
	ne1:SetDescription(aux.Stringid(id,0))
	ne1:SetCategory(CATEGORY_DISABLE)
	ne1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	ne1:SetCode(EVENT_SPSUMMON_SUCCESS)
	ne1:SetCondition(cid.discon)
	ne1:SetTarget(cid.distg)
	ne1:SetOperation(cid.disop)
	c:RegisterEffect(ne1)
	--copy
	local ce1=Effect.CreateEffect(c)
	ce1:SetDescription(aux.Stringid(id,1))
	ce1:SetType(EFFECT_TYPE_IGNITION)
	ce1:SetCountLimit(1)
	ce1:SetRange(LOCATION_MZONE)
	ce1:SetLabel(0)
	ce1:SetCost(cid.cost)
	ce1:SetTarget(cid.target)
	ce1:SetOperation(cid.operation)
	c:RegisterEffect(ce1)
	--Special Summon
	local se1=Effect.CreateEffect(c)
	se1:SetDescription(aux.Stringid(id,3))
	se1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	se1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	se1:SetCode(EVENT_LEAVE_FIELD)
	se1:SetCountLimit(1,id)
	se1:SetCost(cid.specost)
	se1:SetTarget(cid.spetg)
	se1:SetOperation(cid.speop)
	c:RegisterEffect(se1)
end
--SPSUMMON PROC
function cid.cfilter(c,lv,exclv)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsLevel(lv) and (not exclv or not c:IsLevel(exclv))
end
function cid.customcheck(g)
	return aux.dncheck(g) and g:IsExists(cid.cfilter1,3,nil,7) and g:IsExists(cid.cfilter1,3,nil,8,7)
end
function cid.spco(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(cid.cfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,7)
	local g2=Duel.GetMatchingGroup(cid.cfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,g1,8,7)
	g1:Merge(g2)
	return g1:CheckSubGroup(cid.customcheck,6,6) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--ATK LIMIT
function cid.cfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
function cid.atkcon(e)
	return not Duel.IsExistingMatchingCard(cid.cfilter1,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--NEGATE
function cid.disfilter(c)
	return aux.disfilter1(c) and not (c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON))
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
	end
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cid.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	while tc do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
--COPY
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.cpfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost() and c:IsLevel(7,8)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(cid.cpfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.cpfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		Duel.SetTargetCard(g)
	end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		local code=tc:GetOriginalCodeRule()
		local cide=0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cide=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabelObject(e1)
		e2:SetLabel(cide)
		e2:SetOperation(cid.rstop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
function cid.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cide=e:GetLabel()
	if cide~=0 then
		c:ResetEffect(cide,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
--SPSUMMON
function cid.specost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.spefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.spefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cid.spefilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsLevel(7,8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function cid.spetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cid.speop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP)
end
