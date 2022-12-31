--Miraculum dell'Organizzazione Angeli, Sceptrum
--Script by XGlitchy30
function c16599471.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),aux.NonTuner(Card.IsRace,RACE_FAIRY),1)
	c:EnableReviveLimit()
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599471.efilter)
	c:RegisterEffect(e0)
	--adjust DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c16599471.valop)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16599471,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,16599471)
	e2:SetCondition(c16599471.rmcon)
	e2:SetCost(c16599471.rmcost)
	e2:SetTarget(c16599471.rmtg)
	e2:SetOperation(c16599471.rmop)
	c:RegisterEffect(e2)
	--enable protection
	-- local e3=Effect.CreateEffect(c)
	-- e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	-- e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	-- e3:SetCode(EVENT_BATTLE_DAMAGE)
	-- e3:SetRange(LOCATION_MZONE)
	-- e3:SetCountLimit(1,10599471)
	-- e3:SetCondition(c16599471.damcon)
	-- e3:SetOperation(c16599471.damop)
	-- c:RegisterEffect(e3)
	--gain LP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16599471,2))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCountLimit(1,11599471)
	e4:SetCondition(c16599471.lpcon)
	e4:SetCost(c16599471.lpcost)
	e4:SetTarget(c16599471.lptg)
	e4:SetOperation(c16599471.lpop)
	c:RegisterEffect(e4)
end
--filters
function c16599471.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1559)
end
function c16599471.mfilter(c,sync)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x1559)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsAbleToRemoveAsCost()
end
function c16599471.costfilter(c)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:GetDefense()>0
end
--target protection
function c16599471.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(9)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=9)) and rp==1-e:GetHandlerPlayer()
end
--adjust DEF
function c16599471.valop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_SYNCHRO) then return end
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local val=0
	while tc do
		if tc:IsType(TYPE_SYNCHRO) then
			val=val+1
		end
		tc=g:GetNext()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val*2500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
--banish
function c16599471.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c16599471.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c16599471.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial():Filter(Card.IsSetCard,nil,0x1559)
	local matc=mat:GetCount()
	if chk==0 then return matc>0 and mat:FilterCount(c16599471.mfilter,nil,c)==matc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=mat:Select(tp,matc,matc,nil)
	if g:GetCount()==matc then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599471.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function c16599471.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 and #sg>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local rg=g:Select(1-tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local rg2=sg:Select(1-tp,1,1,nil)
		rg:Merge(rg2)
		Duel.HintSelection(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_RULE)
	end
end
--enable protection
function c16599471.damcon(e,tp,eg,ep,ev,re,r,rp)
	local att=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	return ep==tp and Duel.GetTurnPlayer()==1-tp
		and att and def and ((att:GetControler()==tp and att:IsRace(RACE_FAIRY) and att:IsRelateToBattle())
		or (def:GetControler()==tp and def:IsRace(RACE_FAIRY) and def:IsRelateToBattle()))
end
function c16599471.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetTarget(c16599471.reptg)
	e1:SetValue(c16599471.repval)
	e1:SetOperation(c16599471.repop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	Duel.RegisterEffect(e1,tp)
end
function c16599471.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetFlagEffect(10599471)==0 and c:GetFlagEffect(16599471)==0
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c16599471.rmfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove()
end
function c16599471.excfilter(c,cg)
	return not cg:IsContains(c)
end
function c16599471.confirmrep(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove() and c:GetFlagEffect(10599471)~=0
end
function c16599471.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599471.rmfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and eg:IsExists(c16599471.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local ct=0
		local g=eg:Filter(c16599471.repfilter,nil,tp)
		if g:GetCount()==1 then
			g:KeepAlive()
			e:SetLabelObject(g)
			ct=1
		else
			local selection=g:GetCount()
			local availabilty=Duel.GetMatchingGroupCount(c16599471.rmfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
			if availabilty<selection then selection=availabilty end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			local cg=g:Select(tp,1,selection,nil)
			cg:KeepAlive()
			e:SetLabelObject(cg)
			ct=cg:GetCount()
			if ct<g:GetCount() then
				local exc=g:Filter(c16599471.excfilter,nil,e:GetLabelObject())
				for x in aux.Next(exc) do
					x:RegisterFlagEffect(16599471,RESET_PHASE+PHASE_END+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
				end
			end
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tg=Duel.SelectMatchingCard(tp,c16599471.rmfilter,tp,LOCATION_GRAVE,0,ct,ct,nil,e,tp)
		for i in aux.Next(tg) do
			i:RegisterFlagEffect(10599471,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
		end
		return true
	else
		local g=eg:Filter(c16599471.repfilter,nil,tp)
		for i2 in aux.Next(g) do
			i2:RegisterFlagEffect(16599471,RESET_PHASE+PHASE_END+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
		end
		return false 
	end
end
function c16599471.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end
function c16599471.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,16599471)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.GetMatchingGroup(c16599471.confirmrep,tp,LOCATION_GRAVE,0,nil,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local og=Duel.GetOperatedGroup():GetCount()
		local k=e:GetLabelObject()
		local tc=k:GetFirst()
		while tc do
			tc:RegisterFlagEffect(16599471,RESET_PHASE+PHASE_END+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			og=og-1
			if og<=0 then
				break
			end
			tc=k:GetNext()
		end
	end
end
--gain LP
function c16599471.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c16599471.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599471.costfilter,tp,LOCATION_DECK,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599471.costfilter,tp,LOCATION_DECK,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		e:SetLabel(Duel.GetOperatedGroup():GetFirst():GetDefense())
	end
end
function c16599471.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local val=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
function c16599471.lpop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if val>0 then
		Duel.Recover(tp,val,REASON_EFFECT)
	end
end