--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e0=e1:Clone()
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,2,nil) end)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,id+2000)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end
function s.sfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:GetSequence()<5
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_BEASTWARRIOR)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end
function s.xfilter(c)
	return not c:IsRace(RACE_BEAST)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetReasonCard():GetMaterial()
	return r&REASON_XYZ+REASON_SYNCHRO>0 and c:IsPreviousLocation(LOCATION_ONFIELD)
		and not mg:IsExists(s.xfilter,1,nil) and mg:FilterCount(r==REASON_SYNCHRO and Card.IsSynchroType or Card.IsXyzType,nil,TYPE_MONSTER)==#mg
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(function() local d=Duel.GetAttackTarget() return Duel.GetAttacker()==rc and d~=nil or d==rc and rc:GetFlagEffect(id)==0 end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_BATTLE,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() or Duel.Destroy(d,REASON_EFFECT)==0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.ChainAttack()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(function()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		c:RegisterEffect(e3,true)
	end)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
end
