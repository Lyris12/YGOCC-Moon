--The Invocation of the World
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cid.mfilter,3,3,cid.lcheck)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_COST)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(cid.spcost)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(cid.valop)
	c:RegisterEffect(e1)
	--maintenance
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(cid.rmcon)
	e2:SetOperation(cid.rmop)
	c:RegisterEffect(e2)
	--gain effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(cid.econ)
	e3:SetTarget(cid.etg)
	e3:SetOperation(cid.eop)
	c:RegisterEffect(e3)
end
function cid.mfilter(c)
	return not c:IsLinkType(TYPE_LINK)
end
function cid.lcheck(g)
	return g:GetClassCount(Card.GetLinkRace)==#g or g:GetClassCount(Card.GetLinkAttribute)==#g
end
--SPSUMMON CONDITION
function cid.spconfilter(c)
	return c:IsSetCard(0x5478) and not c:IsCode(id)
end
function cid.spcost(e,c,tp,st)
	if bit.band(st,SUMMON_TYPE_LINK)~=SUMMON_TYPE_LINK then return true end
	return Duel.IsExistingMatchingCard(cid.spconfilter,tp,LOCATION_GRAVE,0,1,nil)
end

--ATK
function cid.valop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_LINK) then return end
	local g=c:GetMaterial()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		local lk=tc:GetTextAttack()
		atk=atk+lk
		tc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(math.ceil(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end

--MAINTENANCE
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.rmfilter(c)
	return c:IsSetCard(0x5478) and c:IsAbleToRemove()
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	local g=Duel.GetMatchingGroup(cid.rmfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=Duel.SelectMatchingCard(tp,cid.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		if Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)==2 then res=true end
	end
	if not res then
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end

--GAIN EFFECTS
function cid.econ(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.gfilter(c)
	return c:IsSetCard(0x5478) and not c:IsCode(id,id-11)
end
function cid.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.gfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function cid.eop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cid.gfilter,tp,LOCATION_GRAVE,0,nil)
	if #g<=0 then return end
	local val=0
	if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then val=val|TYPE_MONSTER c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3)) end
	if g:IsExists(Card.IsType,1,nil,TYPE_SPELL) then val=val|TYPE_SPELL c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4)) end
	if g:IsExists(Card.IsType,1,nil,TYPE_TRAP) then val=val|TYPE_TRAP c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5)) end
	if val==0 then return end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetLabel(val)
	e3:SetValue(cid.efilter)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
function cid.efilter(e,te)
	local val=e:GetLabel()
	local st=val&(TYPE_SPELL+TYPE_TRAP)
	return (val&TYPE_MONSTER>0 and te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()) or (st>0 and te:IsActiveType(st))
end