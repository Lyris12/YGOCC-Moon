--Marsmooth Farcoat
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--place as Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.pccon)
	e1:SetTarget(s.pctg)
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
--PLACE AS TRAP
function s.pccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		local check=false
		local incr=(tp==0) and 1 or -1
		for p=tp,1-tp,incr do
			if check then break end
			for i=0,6 do
				local index
				if i<5 then
					index=(p==tp) and i or 4-i
				else
					if p==tp then
						index = (i==5) and 1 or 3
					end
				end
				local refg = (i<5) and Duel.GetFieldGroup(p,LOCATION_MZONE,0) or Duel.GetFieldGroup(p,LOCATION_MZONE,LOCATION_MZONE)
				if index and not Duel.CheckLocation(p,LOCATION_MZONE,i) and not refg:IsExists(s.zcheck,1,nil,i,p) and Duel.CheckLocation(tp,LOCATION_SZONE,index) then
					check=true
					break
				end
			end
		end
		return check and not e:GetHandler():IsForbidden()
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,e:GetHandler(),1,0,0)
end
function s.zcheck(c,i,tp)
	if i<5 then
		local zone=0x1<<i
		return aux.IsZone(c,zone,tp)
	else
		return c:GetSequence()==i
	end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain(0) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsForbidden() then return end
	local zone=0
	local incr=(tp==0) and 1 or -1
	for p=tp,1-tp,incr do
		for i=0,6 do
			local index
			if i<5 then
				index=(p==tp) and i or 4-i
			else
				if p==tp then
					index = (i==5) and 1 or 3
				end
			end
			local refg = (i<5) and Duel.GetFieldGroup(p,LOCATION_MZONE,0) or Duel.GetFieldGroup(p,LOCATION_MZONE,LOCATION_MZONE)
			if index and not Duel.CheckLocation(p,LOCATION_MZONE,i) and not refg:IsExists(s.zcheck,1,nil,i,p) and Duel.CheckLocation(tp,LOCATION_SZONE,index) then
				zone=zone|aux.GLSetValueDependingOnNumber(index,6,0x1,0x2,0x4,0x8,0x10,0x2,0x8)
			end
		end
	end
	if zone==0 then return end
	if not c:IsImmuneToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetOperation(s.spop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffectLabel(id)==e:GetLabel() and c:IsLocation(LOCATION_SZONE) and c:IsControler(tp) and c:GetType()&0x20004==0x20004 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
		

--NEGATE
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACE_BEAST==RACE_BEAST
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToChain(0) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToChain(ev) then
			Duel.SendtoGrave(eg,REASON_EFFECT)
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 then
		local dis=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE)
		Duel.Hint(HINT_ZONE,tp,dis)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetLabel(dis)
		e1:SetOperation(s.disop0)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.disop0(e,tp)
	return e:GetLabel()
end