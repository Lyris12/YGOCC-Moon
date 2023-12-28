--Trinity Magician
function c249001249.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_SPSUMMON_COUNT)
	--xyz summon
	aux.AddXyzProcedureLevelFree(c,c249001249.mfilter,c249001249.xyzcheck,3,3)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1124)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c249001249.cost)
	e1:SetTarget(c249001249.target)
	e1:SetOperation(c249001249.operation)
	c:RegisterEffect(e1)
	--return
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c249001249.recon)
	e2:SetOperation(c249001249.reop)
	c:RegisterEffect(e2)
end
function c249001249.mfilter(c,xyzc)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)
end
function c249001249.xyzcheck(g)
	return g:GetClassCount(Card.GetLevel)==1
end
function c249001249.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c249001249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c249001249.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.Destroy(g,REASON_EFFECT)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(c249001249.getsummoncount(tp))
	e1:SetValue(c249001249.countval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetLabel(c249001249.getsummoncount(tp))
	e2:SetTarget(c249001249.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e3,tp)
end
function c249001249.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c249001249.getsummoncount(sump)>e:GetLabel()
end
function c249001249.countval(e,re,tp)
	if c249001249.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
function c249001249.getsummoncount(tp)
	return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
function c249001249.recon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0 and (e:GetHandler():IsFaceup() or e:GetHanlder():IsLocation(LOCATION_GRAVE)) and not e:GetHandler():IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
function c249001249.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED+LOCATION_GRAVE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	end
	e1:SetCountLimit(1)
	e1:SetCondition(c249001249.spcon)
	e1:SetOperation(c249001249.spop)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
function c249001249.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c249001249.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		--check
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(c249001249.checkop)
		e2:SetLabelObject(e1)
		Duel.RegisterEffect(e2,tp)
		--cannot attack
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetCondition(c249001249.atkcon)
		e3:SetTarget(c249001249.atktg)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
	Duel.SpecialSummonComplete()
end
function c249001249.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,249001249)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	Duel.RegisterFlagEffect(tp,249001249,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
function c249001249.atkcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),249001249)~=0
end
function c249001249.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end