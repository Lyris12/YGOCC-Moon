--Quintus dell'Organizzazione Angeli, Magrubia
--Script by XGlitchy30
function c16599467.initial_effect(c)
	--aux.AddSynchroProcedure(c,c16599467.tunermat,aux.NonTuner(Card.IsRace,RACE_FAIRY),1)
	c:EnableReviveLimit()
	--synchro summon
	local syn0=Effect.CreateEffect(c)
	syn0:SetType(EFFECT_TYPE_SINGLE)
	syn0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	syn0:SetCode(EFFECT_SPSUMMON_CONDITION)
	syn0:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(syn0)
	local syn=Effect.CreateEffect(c)
	syn:SetDescription(1164)
	syn:SetType(EFFECT_TYPE_FIELD)
	syn:SetCode(EFFECT_SPSUMMON_PROC)
	syn:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	syn:SetRange(LOCATION_EXTRA)
	syn:SetCondition(c16599467.synchrocon)
	syn:SetTarget(c16599467.synchrotg)
	syn:SetOperation(c16599467.synchrosummon)
	syn:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(syn)
	--target protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(c16599467.efilter)
	c:RegisterEffect(e0)
	--tuner
	local tuner=Effect.CreateEffect(c)
	tuner:SetType(EFFECT_TYPE_SINGLE)
	tuner:SetCode(EFFECT_ADD_TYPE)
	tuner:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	tuner:SetRange(LOCATION_MZONE)
	tuner:SetCondition(c16599467.tunercon)
	tuner:SetValue(TYPE_TUNER)
	c:RegisterEffect(tuner)
	--wipe field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c16599467.drycon)
	e1:SetCost(c16599467.drycost)
	e1:SetTarget(c16599467.drytg)
	e1:SetOperation(c16599467.dryop)
	c:RegisterEffect(e1)
	--field effect
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16599467.tkcon)
	e2:SetTarget(c16599467.tktg)
	e2:SetOperation(c16599467.tkop)
	c:RegisterEffect(e2)
	--atk gain
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,16599467)
	e3:SetCondition(c16599467.sccon)
	e3:SetCost(c16599467.sccost)
	e3:SetTarget(c16599467.sctg)
	e3:SetOperation(c16599467.scop)
	c:RegisterEffect(e3)
end
--synchro summon
function c16599467.synchrocon(e,c,smat,mg)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	if smat and smat:IsType(TYPE_TUNER) and (not c16599467.tunermat or c16599467.tunermat(smat)) then
		return Duel.CheckTunerMaterial(c,smat,c16599467.tunermat,c16599467.nontunermat,1,99,mg) 
	end
	return Duel.CheckSynchroMaterial(c,c16599467.tunermat,c16599467.nontunermat,1,99,smat,mg)
end
function c16599467.synchrotg(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg)
	local g=nil
	if smat and smat:IsType(TYPE_TUNER) and (not c16599467.tunermat or c16599467.tunermat(smat)) then
		g=Duel.SelectTunerMaterial(c:GetControler(),c,smat,c16599467.tunermat,c16599467.nontunermat,1,99,mg)
	else
		g=Duel.SelectSynchroMaterial(c:GetControler(),c,c16599467.tunermat,c16599467.nontunermat,1,99,smat,mg)
	end
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else 
		return false 
	end
end
function c16599467.synchrosummon(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	g:DeleteGroup()
end
--filters
function c16599467.tunermat(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)
end
function c16599467.nontunermat(c)
	return not c:IsType(TYPE_TUNER) and c:IsRace(RACE_FAIRY)
end
function c16599467.dfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_FAIRY)
end
function c16599467.mfilter(c,sync)
	return c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsAbleToRemoveAsCost()
end
function c16599467.tunerchk(c)
	return c:IsType(TYPE_TOKEN) and c:IsFaceup() and c:GetAttack()==0
end
function c16599467.wpfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_FAIRY)
end
function c16599467.costfilter(c)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:GetLevel()>=7 and c:IsAbleToRemoveAsCost()
end
function c16599467.thfilter(c)
	return c:IsSetCard(0x1559) and c:IsAbleToHand()
end
--target protection
function c16599467.efilter(e,re,rp)
	return ((re:GetHandler():GetLevel()>0 and re:GetHandler():IsLevelBelow(10)) or (re:GetHandler():GetRank()>0 and re:GetHandler():GetRank()<=10)) and rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--tuner
function c16599467.tunercon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c16599467.tunerchk,tp,LOCATION_MZONE,0,1,nil)
end
--wipe field
function c16599467.drycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c16599467.drycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local matc=mat:GetCount()
	if chk==0 then return matc>0 and mat:FilterCount(c16599467.mfilter,nil,c)==matc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=mat:Select(tp,matc,matc,nil)
	if g:GetCount()==matc then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599467.drytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599467.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(c16599467.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function c16599467.dryop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(c16599467.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
--gain atk
function c16599467.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local att=Duel.GetAttacker()
	local def=Duel.GetAttackTarget()
	return ep==tp and att and def
		and ((att:GetControler()==tp and att:IsRace(RACE_FAIRY) and att:IsRelateToBattle())
		or (def:GetControler()==tp and def:IsRace(RACE_FAIRY) and def:IsRelateToBattle()))
end
function c16599467.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,16599449,0,0x4011,0,1900,1,RACE_FAIRY,ATTRIBUTE_LIGHT) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c16599467.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,16599449,0,0x4011,0,1900,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,16599449)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local op=Duel.GetOperatedGroup():GetFirst()
		if not op then return end
		Duel.BreakEffect()
		if Duel.SelectYesNo(tp,aux.Stringid(16599467,0)) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			op:RegisterEffect(e1)
		else
			return
		end
	end
end
--recover resources
function c16599467.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsRace(RACE_FAIRY) and re:GetHandler():IsType(TYPE_SYNCHRO)
end
function c16599467.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16599467.costfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599467.costfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c16599467.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsLocation(LOCATION_MZONE) and re:GetHandler():IsFaceup() and re:GetHandler():GetDefense()>0 end
end
function c16599467.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if tc and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end