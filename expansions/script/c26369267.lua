--Psychostizia Maresciallo
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.proton,1,1,s.electron,1,99)
	c:EnableReviveLimit()
	--cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.proton(c)
	return c:IsRace(RACE_PSYCHO) and c:GetVibe()==1
end
function s.electron(c)
	return c:IsSetCard(0x2c2) and c:GetVibe()==-1
end

function s.rmcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.rfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_SZONE)) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x2c2) and c:IsReleasableByEffect()
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	local g1=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	if #g~=0 then
		Duel.HintSelection(g)
		if Duel.Release(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,2,nil)
			if #rg>0 then
				local check=false
				for rc in aux.Next(rg) do
					if Duel.Remove(rc,rc:GetPosition(),REASON_EFFECT+REASON_TEMPORARY)>0 and rc:IsLocation(LOCATION_REMOVED) then
						check=true
					end
				end
				if not check then return end
				local og=rg:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
				local fid=c:GetFieldID()
				for tc1 in aux.Next(og) do
					tc1:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				end
				og:KeepAlive()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetLabel(fid)
				e1:SetLabelObject(og)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				e1:SetReset(RESET_EVENT+RESET_TOFIELD+RESET_TURN_SET)
				c:RegisterEffect(e1)
			end
		end
	end
end
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		Duel.ReturnToField(tc)
		tc=sg:GetNext()
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or ep==tp then return false end
	local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex2,g2,gc2,dp2,dv2=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	return ((ex1 and (dv1==LOCATION_GRAVE or dv1==LOCATION_DECK or g1 and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_DECK))))
		or (ex2 and gc2>0)
end
function s.ngfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x2c2) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp):Filter(s.ngfilter,nil,tp)
	local g2=Duel.GetMatchingGroup(s.ngfilter,tp,LOCATION_SZONE,0,g1)
	g1:Merge(g2)
	if chk==0 then return #g1>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g1:Select(tp,1,1,nil)
	local tc=rg:GetFirst()
	aux.UseExtraReleaseCount(rg,tp)
	Duel.Release(tc,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable(e) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end