--created & coded by Lyris, art by Harpiedancer214 of DeviantArt
--機氷竜クリサ
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(0x10000000+id)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(function() return c:IsPublic() or c:IsSummonType(SUMMON_TYPE_SPECIAL) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(function(_,tp) return Duel.GetTurnPlayer()~=tp end)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		s[0]={}
		s[1]={}
		local race=1
		while race<RACE_ALL do
			s[0][race]=0
			s[1][race]=0
			race=race<<1
		end
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.rchk)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetCode(EFFECT_UPDATE_ATTACK)
		ge2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		ge2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd76))
		ge2:SetValue(s.atkval)
		Duel.RegisterEffect(ge2,0)
	end
end
function s.cfilter(c,tp,rc)
	return c:IsSummonPlayer(tp) and c:IsRace(rc)
end
function s.rchk(e,tp,eg)
	for p=0,1 do if Duel.GetFlagEffect(p,id)>0 then
		local rc=1
		while rc<RACE_ALL do
			if eg:IsExists(s.cfilter,1,nil,p,rc) then s[p][rc]=s[p][rc]+1 end
			rc=rc<<1
		end
	end end
end
function s.atkval(e,c)
	if Duel.IsExistingMatchingCard(function(tc) return tc:GetFlagEffect(id)>0 end,0,LOCATION_HAND+LOCATION_MZONE,LOCATION_HAND+LOCATION_MZONE,1,nil) then return c:GetBaseDefense()
	else return 0 end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd76)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lim(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	local tp=sump
	if targetp then tp=targetp end
	return s[tp][c:GetRace()]>1
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local rc=1
		while rc<RACE_ALL do s[tp][rc]=0 rc=rc<<1 end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.lim)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(s.efilter)
		tc:RegisterEffect(e2)
	end
end
function s.efilter(e,te)
	local tc=te:GetHandler()
	return te:GetOwner()~=e:GetOwner() and (te:IsActiveType(TYPE_SPELL+TYPE_TRAP) or Duel.GetTurnPlayer()~=tp
		and tc:GetAttackedCount()==0 and not tc:IsStatus(STATUS_JUST_POS))
end
